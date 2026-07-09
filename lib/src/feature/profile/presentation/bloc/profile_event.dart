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

/// Quiet refetch after my listings/reels changed elsewhere in the app.
final class ProfileRefreshed extends ProfileEvent {
  const ProfileRefreshed();
}

/// Append the next page of the Products tab (infinite scroll).
final class ProfileProductsLoadMore extends ProfileEvent {
  const ProfileProductsLoadMore();
}

/// Append the next page of the Reels tab (infinite scroll).
final class ProfileReelsLoadMore extends ProfileEvent {
  const ProfileReelsLoadMore();
}

/// User-initiated pull-to-refresh (distinct from the quiet EventBus-driven
/// [ProfileRefreshed]). Resets page counters and refetches the first page of
/// the currently-visible tab, emitting a value-distinct state first so the
/// RefreshIndicator settles.
final class ProfilePullToRefresh extends ProfileEvent {
  const ProfilePullToRefresh();
}
