import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_tab.dart';

@immutable
sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileStarted extends ProfileEvent {
  /// Null → my own profile.
  final String? userId;

  const ProfileStarted({this.userId});

  @override
  List<Object?> get props => [userId];
}

final class ProfileTabChanged extends ProfileEvent {
  final ProfileTab tab;

  const ProfileTabChanged(this.tab);

  @override
  List<Object?> get props => [tab];
}

final class ProfileFollowToggled extends ProfileEvent {
  const ProfileFollowToggled();
}

final class ProfileReported extends ProfileEvent {
  const ProfileReported();
}

final class ProfileBlocked extends ProfileEvent {
  const ProfileBlocked();
}
