import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

final class SettingsStarted extends SettingsEvent {
  const SettingsStarted();
}

final class SettingsToggleNotification extends SettingsEvent {
  final bool? push;
  final bool? email;

  const SettingsToggleNotification({this.push, this.email});

  @override
  List<Object?> get props => [push, email];
}

final class SettingsLoggedOut extends SettingsEvent {
  const SettingsLoggedOut();
}

final class SettingsAccountDeleted extends SettingsEvent {
  const SettingsAccountDeleted();
}
