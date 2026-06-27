import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/app/push/push_service.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';
import 'package:klozy/src/domain/config/entity/contact_info.dart';
import 'package:klozy/src/domain/config/public_config_repository.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/entity/notification_settings.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/settings/presentation/bloc/settings_bloc.dart';
import 'package:klozy/src/feature/settings/presentation/bloc/settings_event.dart';
import 'package:klozy/src/feature/settings/presentation/bloc/settings_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockMeRepository extends Mock implements MeRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockPublicConfigRepository extends Mock
    implements PublicConfigRepository {}

class _MockPushService extends Mock implements PushService {}

Future<List<SettingsState>> _collectStates(
  SettingsBloc bloc,
  SettingsEvent event,
) async {
  final states = <SettingsState>[];
  final sub = bloc.stream.listen(states.add);
  bloc.add(event);
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

const _kMe = MeProfile(id: 'u1', firstName: 'Alice', lastName: 'Smith');
const _kSettings = NotificationSettings(push: true, email: true);
const _kContact = ContactInfo(supportEmail: 'support@klozy.com');

void main() {
  late _MockMeRepository mockMe;
  late _MockAuthRepository mockAuth;
  late _MockPublicConfigRepository mockConfig;
  late _MockPushService mockPush;
  late SettingsBloc bloc;

  setUp(() {
    mockMe = _MockMeRepository();
    mockAuth = _MockAuthRepository();
    mockConfig = _MockPublicConfigRepository();
    mockPush = _MockPushService();
    when(() => mockPush.unregister()).thenAnswer((_) async {});
    bloc = SettingsBloc(mockMe, mockAuth, mockConfig, mockPush);
  });

  tearDown(() => bloc.close());

  test('initial state is SettingsLoadingState', () {
    expect(bloc.state, const SettingsLoadingState());
  });

  group('SettingsStarted', () {
    test('emits [loading, loaded] on success', () async {
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);
      when(
        () => mockMe.getNotificationSettings(),
      ).thenAnswer((_) async => _kSettings);
      when(() => mockConfig.getContact()).thenAnswer((_) async => _kContact);

      final states = await _collectStates(bloc, const SettingsStarted());

      expect(states.first, const SettingsLoadingState());
      final loaded = states.last as SettingsLoadedState;
      expect(loaded.me, _kMe);
      expect(loaded.settings, _kSettings);
      expect(loaded.contact, _kContact);
    });

    test('proceeds with empty contact when getContact throws', () async {
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);
      when(
        () => mockMe.getNotificationSettings(),
      ).thenAnswer((_) async => _kSettings);
      when(() => mockConfig.getContact()).thenThrow(Exception('network'));

      final states = await _collectStates(bloc, const SettingsStarted());

      final loaded = states.last as SettingsLoadedState;
      expect(loaded.contact, const ContactInfo());
    });

    test('emits [loading, error] when getMe throws', () async {
      when(() => mockMe.getMe()).thenThrow(Exception('auth'));

      final states = await _collectStates(bloc, const SettingsStarted());

      expect(states.first, const SettingsLoadingState());
      expect(states.last, isA<SettingsErrorState>());
    });
  });

  group('SettingsToggleNotification', () {
    Future<void> loadSettings() async {
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);
      when(
        () => mockMe.getNotificationSettings(),
      ).thenAnswer((_) async => _kSettings);
      when(() => mockConfig.getContact()).thenAnswer((_) async => _kContact);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const SettingsStarted());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('optimistically updates and calls repo', () async {
      await loadSettings();
      when(
        () => mockMe.updateNotificationSettings(
          push: any(named: 'push'),
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async {});

      final states = await _collectStates(
        bloc,
        const SettingsToggleNotification(push: false),
      );

      final updated = states.first as SettingsLoadedState;
      expect(updated.settings.push, isFalse);
      verify(
        () => mockMe.updateNotificationSettings(push: false, email: null),
      ).called(1);
    });

    test('reverts on repo error', () async {
      await loadSettings();
      when(
        () => mockMe.updateNotificationSettings(
          push: any(named: 'push'),
          email: any(named: 'email'),
        ),
      ).thenThrow(Exception('server'));

      final states = await _collectStates(
        bloc,
        const SettingsToggleNotification(push: false),
      );

      // Last state is the reverted original
      final reverted = states.last as SettingsLoadedState;
      expect(reverted.settings.push, isTrue); // reverted
    });

    test('does nothing when state is not loaded', () async {
      final states = await _collectStates(
        bloc,
        const SettingsToggleNotification(push: false),
      );
      expect(states, isEmpty);
    });
  });

  group('SettingsLoggedOut', () {
    test('emits SettingsSignedOutState after unregister and signOut', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      final states = await _collectStates(bloc, const SettingsLoggedOut());

      expect(states.last, const SettingsSignedOutState());
      verify(() => mockPush.unregister()).called(1);
      verify(() => mockAuth.signOut()).called(1);
    });

    test('proceeds to signed out even when signOut throws', () async {
      when(() => mockAuth.signOut()).thenThrow(Exception('server'));

      final states = await _collectStates(bloc, const SettingsLoggedOut());

      expect(states.last, const SettingsSignedOutState());
    });

    test('emits isBusy=true first when loaded', () async {
      when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);
      when(
        () => mockMe.getNotificationSettings(),
      ).thenAnswer((_) async => _kSettings);
      when(() => mockConfig.getContact()).thenAnswer((_) async => _kContact);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const SettingsStarted());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      final states = await _collectStates(bloc, const SettingsLoggedOut());

      expect((states.first as SettingsLoadedState).isBusy, isTrue);
      expect(states.last, const SettingsSignedOutState());
    });
  });

  group('SettingsAccountDeleted', () {
    test('emits SettingsSignedOutState', () async {
      when(() => mockMe.deleteAccount()).thenAnswer((_) async {});
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      final states = await _collectStates(bloc, const SettingsAccountDeleted());

      expect(states.last, const SettingsSignedOutState());
      verify(() => mockPush.unregister()).called(1);
    });

    test('proceeds even when deleteAccount throws', () async {
      when(() => mockMe.deleteAccount()).thenThrow(Exception('server'));
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      final states = await _collectStates(bloc, const SettingsAccountDeleted());

      expect(states.last, const SettingsSignedOutState());
    });
  });
}
