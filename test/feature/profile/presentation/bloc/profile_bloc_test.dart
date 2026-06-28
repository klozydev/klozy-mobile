import 'package:event_bus/event_bus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/social/entity/profile_reel.dart';
import 'package:klozy/src/domain/social/entity/social_profile.dart';
import 'package:klozy/src/domain/social/entity/user_review.dart';
import 'package:klozy/src/domain/social/social_repository.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_bloc.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_event.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_state.dart';
import 'package:klozy/src/feature/profile/presentation/bloc/profile_tab.dart';
import 'package:mocktail/mocktail.dart';

class _MockSocialRepository extends Mock implements SocialRepository {}

class _MockMeRepository extends Mock implements MeRepository {}

Future<List<ProfileState>> _collectStates(
  ProfileBloc bloc,
  ProfileEvent event,
) async {
  final states = <ProfileState>[];
  final sub = bloc.stream.listen(states.add);
  bloc.add(event);
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

const _kProfile = SocialProfile(id: 'u1', displayName: 'Alice');
const _kMyProfile = SocialProfile(
  id: 'u1',
  displayName: 'Alice',
  isMe: true,
  followers: 10,
);
const _kProduct = Product(id: 'p1', title: 'Shirt', price: 50);

void main() {
  late _MockSocialRepository mockSocial;
  late _MockMeRepository mockMe;
  late ProfileBloc bloc;

  setUp(() {
    mockSocial = _MockSocialRepository();
    mockMe = _MockMeRepository();
    bloc = ProfileBloc(mockSocial, mockMe, EventBus());
  });

  tearDown(() => bloc.close());

  test('initial state is ProfileLoadingState', () {
    expect(bloc.state, const ProfileLoadingState());
  });

  group('ProfileStarted', () {
    test('emits [loading, loaded] for another user on success', () async {
      when(
        () => mockSocial.getProfile(any()),
      ).thenAnswer((_) async => _kProfile);
      when(
        () => mockSocial.getUserProducts(any(), page: any(named: 'page')),
      ).thenAnswer((_) async => const <Product>[_kProduct]);

      final states = await _collectStates(
        bloc,
        const ProfileStarted(userId: 'u1'),
      );

      expect(states.first, const ProfileLoadingState());
      final loaded = states.last as ProfileLoadedState;
      expect(loaded.profile, _kProfile);
      expect(loaded.products, [_kProduct]);
    });

    test('emits [loading, loaded] for my own profile (no userId)', () async {
      when(
        () => mockSocial.getMyProfile(),
      ).thenAnswer((_) async => _kMyProfile);
      when(
        () => mockSocial.getUserProducts(any(), page: any(named: 'page')),
      ).thenAnswer((_) async => const <Product>[]);

      final states = await _collectStates(bloc, const ProfileStarted());

      final loaded = states.last as ProfileLoadedState;
      expect(loaded.profile, _kMyProfile);
    });

    test('proceeds with empty products when getUserProducts throws', () async {
      when(
        () => mockSocial.getProfile(any()),
      ).thenAnswer((_) async => _kProfile);
      when(
        () => mockSocial.getUserProducts(any(), page: any(named: 'page')),
      ).thenThrow(Exception('network'));

      final states = await _collectStates(
        bloc,
        const ProfileStarted(userId: 'u1'),
      );

      final loaded = states.last as ProfileLoadedState;
      expect(loaded.products, isEmpty);
    });

    test('emits [loading, error] when getProfile throws', () async {
      when(
        () => mockSocial.getProfile(any()),
      ).thenThrow(Exception('not found'));

      final states = await _collectStates(
        bloc,
        const ProfileStarted(userId: 'u1'),
      );

      expect(states.first, const ProfileLoadingState());
      expect(states.last, isA<ProfileErrorState>());
    });
  });

  group('ProfileTabChanged', () {
    Future<void> loadProfile({bool mine = false}) async {
      if (mine) {
        when(
          () => mockSocial.getMyProfile(),
        ).thenAnswer((_) async => _kMyProfile);
      } else {
        when(
          () => mockSocial.getProfile(any()),
        ).thenAnswer((_) async => _kProfile);
      }
      when(
        () => mockSocial.getUserProducts(any(), page: any(named: 'page')),
      ).thenAnswer((_) async => const <Product>[]);
      final sub = bloc.stream.listen((_) {});
      bloc.add(
        mine ? const ProfileStarted() : const ProfileStarted(userId: 'u1'),
      );
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('switches to reels tab and fetches reels lazily', () async {
      await loadProfile();
      when(
        () => mockSocial.getUserReels(any(), mine: any(named: 'mine')),
      ).thenAnswer((_) async => const <ProfileReel>[]);

      final states = await _collectStates(
        bloc,
        const ProfileTabChanged(ProfileTab.reels),
      );

      // First emits tab switch, then tabLoading=true, then loaded with reels
      expect(
        states.any((s) => s is ProfileLoadedState && s.tab == ProfileTab.reels),
        isTrue,
      );
      verify(
        () => mockSocial.getUserReels(any(), mine: any(named: 'mine')),
      ).called(1);
    });

    test('switches to reviews tab and fetches reviews lazily', () async {
      await loadProfile();
      when(
        () => mockSocial.getReviews(any()),
      ).thenAnswer((_) async => const <UserReview>[]);

      final states = await _collectStates(
        bloc,
        const ProfileTabChanged(ProfileTab.reviews),
      );

      expect(
        states.any(
          (s) => s is ProfileLoadedState && s.tab == ProfileTab.reviews,
        ),
        isTrue,
      );
      verify(() => mockSocial.getReviews(any())).called(1);
    });

    test('does not re-fetch reels if already loaded', () async {
      await loadProfile();
      // Load reels first
      when(
        () => mockSocial.getUserReels(any(), mine: any(named: 'mine')),
      ).thenAnswer((_) async => const <ProfileReel>[]);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const ProfileTabChanged(ProfileTab.reels));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      clearInteractions(mockSocial);

      // Switch to reels again — should not refetch
      await _collectStates(bloc, const ProfileTabChanged(ProfileTab.reels));

      verifyNever(
        () => mockSocial.getUserReels(any(), mine: any(named: 'mine')),
      );
    });

    test('settles tabLoading=false on fetch error', () async {
      await loadProfile();
      when(
        () => mockSocial.getUserReels(any(), mine: any(named: 'mine')),
      ).thenThrow(Exception('network'));

      final states = await _collectStates(
        bloc,
        const ProfileTabChanged(ProfileTab.reels),
      );

      final last = states.last as ProfileLoadedState;
      expect(last.tabLoading, isFalse);
    });

    test('does nothing when state is not loaded', () async {
      final states = await _collectStates(
        bloc,
        const ProfileTabChanged(ProfileTab.reels),
      );
      expect(states, isEmpty);
    });
  });

  group('ProfileFollowToggled', () {
    Future<void> loadProfile() async {
      when(
        () => mockSocial.getProfile(any()),
      ).thenAnswer((_) async => _kProfile);
      when(
        () => mockSocial.getUserProducts(any(), page: any(named: 'page')),
      ).thenAnswer((_) async => const <Product>[]);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const ProfileStarted(userId: 'u1'));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('optimistically follows and calls repo', () async {
      await loadProfile();
      when(() => mockSocial.follow(any())).thenAnswer((_) async {});

      final states = await _collectStates(bloc, const ProfileFollowToggled());

      final optimistic = states.first as ProfileLoadedState;
      expect(optimistic.profile.isFollowing, isTrue);
      verify(() => mockSocial.follow('u1')).called(1);
    });

    test('reverts on follow error', () async {
      await loadProfile();
      when(() => mockSocial.follow(any())).thenThrow(Exception('server'));

      final states = await _collectStates(bloc, const ProfileFollowToggled());

      final reverted = states.last as ProfileLoadedState;
      expect(reverted.profile.isFollowing, isFalse); // reverted
    });

    test('optimistically unfollows and calls repo', () async {
      // Load a followed profile
      const followedProfile = SocialProfile(
        id: 'u1',
        displayName: 'Alice',
        isFollowing: true,
        followers: 5,
      );
      when(
        () => mockSocial.getProfile(any()),
      ).thenAnswer((_) async => followedProfile);
      when(
        () => mockSocial.getUserProducts(any(), page: any(named: 'page')),
      ).thenAnswer((_) async => const <Product>[]);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const ProfileStarted(userId: 'u1'));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      when(() => mockSocial.unfollow(any())).thenAnswer((_) async {});

      final states = await _collectStates(bloc, const ProfileFollowToggled());

      final optimistic = states.first as ProfileLoadedState;
      expect(optimistic.profile.isFollowing, isFalse);
      expect(optimistic.profile.followers, 4);
      verify(() => mockSocial.unfollow('u1')).called(1);
    });

    test('does nothing when isMe=true', () async {
      // Load my own profile
      when(
        () => mockSocial.getMyProfile(),
      ).thenAnswer((_) async => _kMyProfile);
      when(
        () => mockSocial.getUserProducts(any(), page: any(named: 'page')),
      ).thenAnswer((_) async => const <Product>[]);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const ProfileStarted());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      final states = await _collectStates(bloc, const ProfileFollowToggled());
      expect(states, isEmpty);
    });
  });

  group('ProfileReported', () {
    test('calls reportUser silently (no state change)', () async {
      when(
        () => mockSocial.getProfile(any()),
      ).thenAnswer((_) async => _kProfile);
      when(
        () => mockSocial.getUserProducts(any(), page: any(named: 'page')),
      ).thenAnswer((_) async => const <Product>[]);
      final sub1 = bloc.stream.listen((_) {});
      bloc.add(const ProfileStarted(userId: 'u1'));
      await Future<void>.delayed(Duration.zero);
      await sub1.cancel();

      when(() => mockSocial.reportUser(any(), any())).thenAnswer((_) async {});

      final states = await _collectStates(bloc, const ProfileReported());

      expect(states, isEmpty); // no state change
      verify(() => mockSocial.reportUser('u1', any())).called(1);
    });
  });

  group('ProfileBlocked', () {
    test('calls block silently when not own profile', () async {
      when(
        () => mockSocial.getProfile(any()),
      ).thenAnswer((_) async => _kProfile);
      when(
        () => mockSocial.getUserProducts(any(), page: any(named: 'page')),
      ).thenAnswer((_) async => const <Product>[]);
      final sub1 = bloc.stream.listen((_) {});
      bloc.add(const ProfileStarted(userId: 'u1'));
      await Future<void>.delayed(Duration.zero);
      await sub1.cancel();

      when(() => mockMe.block(any())).thenAnswer((_) async {});

      final states = await _collectStates(bloc, const ProfileBlocked());

      expect(states, isEmpty); // no state change
      verify(() => mockMe.block('u1')).called(1);
    });
  });
}
