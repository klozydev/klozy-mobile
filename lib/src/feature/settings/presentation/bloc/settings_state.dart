import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/config/entity/contact_info.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/entity/notification_settings.dart';

@immutable
sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

final class SettingsLoadingState extends SettingsState {
  const SettingsLoadingState();
}

final class SettingsErrorState extends SettingsState {
  final AppErrorType type;

  const SettingsErrorState({required this.type});

  @override
  List<Object?> get props => [type];
}

final class SettingsLoadedState extends SettingsState {
  final MeProfile me;
  final NotificationSettings settings;
  final ContactInfo contact;
  final bool isBusy;

  const SettingsLoadedState({
    required this.me,
    required this.settings,
    required this.contact,
    this.isBusy = false,
  });

  SettingsLoadedState copyWith({NotificationSettings? settings, bool? isBusy}) {
    return SettingsLoadedState(
      me: me,
      settings: settings ?? this.settings,
      contact: contact,
      isBusy: isBusy ?? this.isBusy,
    );
  }

  @override
  List<Object?> get props => [me, settings, contact, isBusy];
}

/// Emitted after logout or account deletion — the page returns to Welcome.
final class SettingsSignedOutState extends SettingsState {
  const SettingsSignedOutState();
}
