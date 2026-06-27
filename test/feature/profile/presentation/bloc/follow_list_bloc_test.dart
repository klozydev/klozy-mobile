import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/social/entity/follow_user.dart';
import 'package:klozy/src/domain/social/social_repository.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/follow_list_bloc.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/follow_list_event.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/follow_list_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockSocialRepository extends Mock implements SocialRepository {}

Future<List<FollowListState>> _collectStates(
  FollowListBloc bloc,
  FollowListEvent event,
) async {
  final states = <FollowListState>[];
  final sub = bloc.stream.listen(states.add);
  bloc.add(event);
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

const _kFollower = FollowUser(
  id: 'f1',
  displayName: 'Follower',
  isFollowing: false,
);
const _kFollowing = FollowUser(
  id: 'g1',
  displayName: 'Following',
  isFollowing: true,
);

void main() {
  late _MockSocialRepository mockRepo;
  late FollowListBloc bloc;

  setUp(() {
    mockRepo = _MockSocialRepository();
    bloc = FollowListBloc(mockRepo);
  });

  tearDown(() => bloc.close());

  test('initial state is FollowListLoadingState', () {
    expect(bloc.state, const FollowListLoadingState());
  });

  group('FollowListStarted', () {
    test(
      'emits [loading, loaded] with followers and following on success',
      () async {
        when(
          () => mockRepo.getFollowers(any()),
        ).thenAnswer((_) async => <FollowUser>[_kFollower]);
        when(
          () => mockRepo.getFollowing(any()),
        ).thenAnswer((_) async => <FollowUser>[_kFollowing]);

        final states = await _collectStates(
          bloc,
          const FollowListStarted('user1'),
        );

        expect(states.first, const FollowListLoadingState());
        final last = states.last as FollowListLoadedState;
        expect(last.followers, [_kFollower]);
        expect(last.following, [_kFollowing]);
      },
    );

    test('emits [loading, error] on failure', () async {
      when(() => mockRepo.getFollowers(any())).thenThrow(Exception('network'));
      when(
        () => mockRepo.getFollowing(any()),
      ).thenAnswer((_) async => <FollowUser>[]);

      final states = await _collectStates(
        bloc,
        const FollowListStarted('user1'),
      );

      expect(states.last, isA<FollowListErrorState>());
    });
  });

  group('FollowListRowToggled', () {
    Future<void> loadList() async {
      when(
        () => mockRepo.getFollowers(any()),
      ).thenAnswer((_) async => <FollowUser>[_kFollower]);
      when(
        () => mockRepo.getFollowing(any()),
      ).thenAnswer((_) async => <FollowUser>[_kFollowing]);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const FollowListStarted('user1'));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('optimistically flips isFollowing, calls follow on success', () async {
      await loadList();
      when(() => mockRepo.follow(any())).thenAnswer((_) async {});

      final states = await _collectStates(
        bloc,
        const FollowListRowToggled('f1'),
      );

      // Optimistic update: follower.isFollowing flips to true
      final updated = states.first as FollowListLoadedState;
      expect(updated.followers.first.isFollowing, isTrue);
      verify(() => mockRepo.follow('f1')).called(1);
    });

    test('reverts on repository error (unfollow case)', () async {
      await loadList();
      when(() => mockRepo.unfollow(any())).thenThrow(Exception('server'));

      // _kFollowing has isFollowing=true so toggling it calls unfollow
      final states = await _collectStates(
        bloc,
        const FollowListRowToggled('g1'),
      );

      // First emit is optimistic (isFollowing=false), last is reverted
      final reverted = states.last as FollowListLoadedState;
      expect(reverted.following.first.isFollowing, isTrue);
    });

    test('does nothing when state is not loaded', () async {
      // State is still FollowListLoadingState
      final states = await _collectStates(
        bloc,
        const FollowListRowToggled('x'),
      );
      expect(states, isEmpty);
    });
  });
}
