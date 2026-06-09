import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/social/entity/follow_user.dart';

@immutable
sealed class FollowListState extends Equatable {
  const FollowListState();

  @override
  List<Object?> get props => [];
}

final class FollowListLoadingState extends FollowListState {
  const FollowListLoadingState();
}

final class FollowListErrorState extends FollowListState {
  final AppErrorType type;

  const FollowListErrorState({required this.type});

  @override
  List<Object?> get props => [type];
}

final class FollowListLoadedState extends FollowListState {
  final List<FollowUser> followers;
  final List<FollowUser> following;

  const FollowListLoadedState({
    required this.followers,
    required this.following,
  });

  FollowListLoadedState copyWith({
    List<FollowUser>? followers,
    List<FollowUser>? following,
  }) {
    return FollowListLoadedState(
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }

  @override
  List<Object?> get props => [followers, following];
}
