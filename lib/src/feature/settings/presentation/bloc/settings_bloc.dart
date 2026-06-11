import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/app/notifications/notifications_cubit.dart';
import 'package:klozy/src/app/push/push_service.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';
import 'package:klozy/src/domain/config/entity/contact_info.dart';
import 'package:klozy/src/domain/config/public_config_repository.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/settings/presentation/bloc/settings_event.dart';
import 'package:klozy/src/feature/settings/presentation/bloc/settings_state.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final MeRepository _meRepository;
  final AuthRepository _authRepository;
  final PublicConfigRepository _configRepository;

  final PushService _pushService;
  final WishlistCubit _wishlistCubit;
  final NotificationsCubit _notificationsCubit;

  SettingsBloc(
    this._meRepository,
    this._authRepository,
    this._configRepository,
    this._pushService,
    this._wishlistCubit,
    this._notificationsCubit,
  ) : super(const SettingsLoadingState()) {
    on<SettingsStarted>(_onStarted);
    on<SettingsToggleNotification>(_onToggle);
    on<SettingsLoggedOut>(_onLoggedOut);
    on<SettingsAccountDeleted>(_onDeleted);
  }

  Future<void> _onStarted(
    SettingsStarted event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoadingState());
    try {
      final me = await _meRepository.getMe();
      final settings = await _meRepository.getNotificationSettings();
      ContactInfo contact;
      try {
        contact = await _configRepository.getContact();
      } catch (_) {
        contact = const ContactInfo();
      }
      emit(SettingsLoadedState(me: me, settings: settings, contact: contact));
    } catch (error) {
      emit(SettingsErrorState(type: AppErrorType.fromException(error)));
    }
  }

  Future<void> _onToggle(
    SettingsToggleNotification event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state;
    if (current is! SettingsLoadedState) return;
    final updated = current.settings.copyWith(
      push: event.push,
      email: event.email,
    );
    emit(current.copyWith(settings: updated));
    try {
      await _meRepository.updateNotificationSettings(
        push: event.push,
        email: event.email,
      );
    } catch (_) {
      emit(current);
    }
  }

  Future<void> _onLoggedOut(
    SettingsLoggedOut event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state;
    if (current is SettingsLoadedState) emit(current.copyWith(isBusy: true));
    await _pushService.unregister();
    try {
      await _authRepository.signOut();
    } catch (_) {}
    _clearSessionState();
    emit(const SettingsSignedOutState());
  }

  Future<void> _onDeleted(
    SettingsAccountDeleted event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state;
    if (current is SettingsLoadedState) emit(current.copyWith(isBusy: true));
    await _pushService.unregister();
    try {
      await _meRepository.deleteAccount();
    } catch (_) {}
    try {
      await _authRepository.signOut();
    } catch (_) {}
    _clearSessionState();
    emit(const SettingsSignedOutState());
  }

  /// The lazy-singleton cubits outlive the session — without this a guest
  /// browsing after logout still sees the previous account's wishlist hearts
  /// and unread-notification badge.
  void _clearSessionState() {
    _wishlistCubit.clear();
    _notificationsCubit.clear();
  }
}
