import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/social/entity/follow_user.dart';
import 'package:klozy/src/domain/social/social_repository.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/follow_list_event.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/follow_list_state.dart';

@injectable
class FollowListBloc extends Bloc<FollowListEvent, FollowListState> {
  final SocialRepository _repository;

  FollowListBloc(this._repository) : super(const FollowListLoadingState()) {
    on<FollowListStarted>(_onStarted);
    on<FollowListRowToggled>(_onToggled);
  }

  Future<void> _onStarted(
    FollowListStarted event,
    Emitter<FollowListState> emit,
  ) async {
    emit(const FollowListLoadingState());
    try {
      final results =
          await Future.wait<List<FollowUser>>(<Future<List<FollowUser>>>[
            _repository.getFollowers(event.userId),
            _repository.getFollowing(event.userId),
          ]);
      emit(FollowListLoadedState(followers: results[0], following: results[1]));
    } catch (error) {
      emit(FollowListErrorState(type: AppErrorType.fromException(error)));
    }
  }

  Future<void> _onToggled(
    FollowListRowToggled event,
    Emitter<FollowListState> emit,
  ) async {
    final current = state;
    if (current is! FollowListLoadedState) return;
    bool? wasFollowing;
    List<FollowUser> flip(List<FollowUser> list) {
      return list.map((FollowUser u) {
        if (u.id != event.targetUserId) return u;
        wasFollowing = u.isFollowing;
        return u.copyWith(isFollowing: !u.isFollowing);
      }).toList();
    }

    emit(
      current.copyWith(
        followers: flip(current.followers),
        following: flip(current.following),
      ),
    );
    if (wasFollowing == null) return;
    try {
      if (wasFollowing!) {
        await _repository.unfollow(event.targetUserId);
      } else {
        await _repository.follow(event.targetUserId);
      }
    } catch (_) {
      emit(current);
    }
  }
}
