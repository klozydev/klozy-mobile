import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class FollowListEvent extends Equatable {
  const FollowListEvent();

  @override
  List<Object?> get props => [];
}

final class FollowListStarted extends FollowListEvent {
  final String userId;

  const FollowListStarted(this.userId);

  @override
  List<Object?> get props => [userId];
}

final class FollowListRowToggled extends FollowListEvent {
  final String targetUserId;

  const FollowListRowToggled(this.targetUserId);

  @override
  List<Object?> get props => [targetUserId];
}
