import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/events/products_changed_event.dart';
import 'package:klozy/src/core/events/profile_changed_event.dart';
import 'package:klozy/src/core/events/reels_changed_event.dart';
import 'package:klozy/src/core/pagination/paginated_list.dart';
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
  late EventBus eventBus;
  late ProfileBloc bloc;

  setUp(() {
    mockSocial = _MockSocialRepository();
    mockMe = _MockMeRepository();
    eventBus = EventBus();
    bloc = ProfileBloc(mockSocial, mockMe, eventBus);
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
        () => mockSocial.getUserProducts(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Product>(data: <Product>[_kProduct]),
      );

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
        () => mockSocial.getUserProducts(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Product>(data: <Product>[]),
      );

      final states = await _collectStates(bloc, const ProfileStarted());

      final loaded = states.last as ProfileLoadedState;
      expect(loaded.profile, _kMyProfile);
    });

    test('proceeds with empty products when getUserProducts throws', () async {
      when(
        () => mockSocial.getProfile(any()),
      ).thenAnswer((_) async => _kProfile);
      when(
        () => mockSocial.getUserProducts(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
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
        () => mockSocial.getUserProducts(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Product>(data: <Product>[]),
      );
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
        () => mockSocial.getUserReels(
          any(),
          mine: any(named: 'mine'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<ProfileReel>(data: <ProfileReel>[]),
      );

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
        () => mockSocial.getUserReels(
          any(),
          mine: any(named: 'mine'),
          limit: any(named: 'limit'),
        ),
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
        () => mockSocial.getUserReels(
          any(),
          mine: any(named: 'mine'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<ProfileReel>(data: <ProfileReel>[]),
      );
      final sub = bloc.stream.listen((_) {});
      bloc.add(const ProfileTabChanged(ProfileTab.reels));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      clearInteractions(mockSocial);

      // Switch to reels again — should not refetch
      await _collectStates(bloc, const ProfileTabChanged(ProfileTab.reels));

      verifyNever(
        () => mockSocial.getUserReels(
          any(),
          mine: any(named: 'mine'),
          limit: any(named: 'limit'),
        ),
      );
    });

    test('settles tabLoading=false on fetch error', () async {
      await loadProfile();
      when(
        () => mockSocial.getUserReels(
          any(),
          mine: any(named: 'mine'),
          limit: any(named: 'limit'),
        ),
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
        () => mockSocial.getUserProducts(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Product>(data: <Product>[]),
      );
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
        () => mockSocial.getUserProducts(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Product>(data: <Product>[]),
      );
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
        () => mockSocial.getUserProducts(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Product>(data: <Product>[]),
      );
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
        () => mockSocial.getUserProducts(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Product>(data: <Product>[]),
      );
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
        () => mockSocial.getUserProducts(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Product>(data: <Product>[]),
      );
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

  group('ProfileProductsLoadMore', () {
    Future<void> startBloc({int itemCount = 20}) async {
      final products = List.generate(
        itemCount,
        (i) => Product(id: 'p$i', title: 'P$i', price: i.toDouble()),
      );
      when(
        () => mockSocial.getProfile(any()),
      ).thenAnswer((_) async => _kProfile);
      when(
        () => mockSocial.getUserProducts(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => PaginatedList<Product>(data: products));
      final sub = bloc.stream.listen((_) {});
      bloc.add(const ProfileStarted(userId: 'u1'));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('appends next page on success', () async {
      await startBloc(); // 20 items -> productsHasMore=true

      when(
        () => mockSocial.getUserProducts(any(), page: 2, limit: 20),
      ).thenAnswer(
        (_) async => const PaginatedList<Product>(data: <Product>[_kProduct]),
      );

      final states = await _collectStates(
        bloc,
        const ProfileProductsLoadMore(),
      );

      expect((states.first as ProfileLoadedState).productsLoadingMore, isTrue);
      final last = states.last as ProfileLoadedState;
      expect(last.products.length, 21);
      expect(last.productsLoadingMore, isFalse);
    });

    test('does nothing when productsHasMore is false', () async {
      await startBloc(itemCount: 5); // 5 < 20 -> productsHasMore=false

      final states = await _collectStates(
        bloc,
        const ProfileProductsLoadMore(),
      );
      expect(states, isEmpty);
    });

    test('settles productsLoadingMore=false on error', () async {
      await startBloc();
      when(
        () => mockSocial.getUserProducts(any(), page: 2, limit: 20),
      ).thenThrow(Exception('network'));

      final states = await _collectStates(
        bloc,
        const ProfileProductsLoadMore(),
      );

      expect((states.last as ProfileLoadedState).productsLoadingMore, isFalse);
    });

    test('does nothing when state is not ProfileLoadedState', () async {
      final states = await _collectStates(
        bloc,
        const ProfileProductsLoadMore(),
      );
      expect(states, isEmpty);
    });

    test('does not fetch again while productsLoadingMore is true', () async {
      await startBloc();
      final completer = Completer<PaginatedList<Product>>();
      when(
        () => mockSocial.getUserProducts(any(), page: 2, limit: 20),
      ).thenAnswer((_) => completer.future);

      final states = <ProfileState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const ProfileProductsLoadMore());
      await Future<void>.delayed(Duration.zero); // first fetch now in-flight
      bloc.add(const ProfileProductsLoadMore()); // guarded, should be a no-op
      await Future<void>.delayed(Duration.zero);

      completer.complete(
        const PaginatedList<Product>(data: <Product>[_kProduct]),
      );
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      verify(
        () => mockSocial.getUserProducts(any(), page: 2, limit: 20),
      ).called(1);
    });
  });

  group('ProfileReelsLoadMore', () {
    Future<void> startBloc({int itemCount = 30}) async {
      when(
        () => mockSocial.getProfile(any()),
      ).thenAnswer((_) async => _kProfile);
      when(
        () => mockSocial.getUserProducts(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Product>(data: <Product>[]),
      );
      final reels = List.generate(itemCount, (i) => ProfileReel(id: 'r$i'));
      when(
        () => mockSocial.getUserReels(
          any(),
          mine: any(named: 'mine'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => PaginatedList<ProfileReel>(data: reels));
      final sub1 = bloc.stream.listen((_) {});
      bloc.add(const ProfileStarted(userId: 'u1'));
      await Future<void>.delayed(Duration.zero);
      await sub1.cancel();
      final sub2 = bloc.stream.listen((_) {});
      bloc.add(const ProfileTabChanged(ProfileTab.reels));
      await Future<void>.delayed(Duration.zero);
      await sub2.cancel();
    }

    test('appends next page on success', () async {
      await startBloc(); // 30 reels -> reelsHasMore=true

      when(
        () => mockSocial.getUserReels(
          any(),
          mine: any(named: 'mine'),
          page: 2,
          limit: 30,
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<ProfileReel>(
          data: <ProfileReel>[ProfileReel(id: 'extra')],
        ),
      );

      final states = await _collectStates(bloc, const ProfileReelsLoadMore());

      expect((states.first as ProfileLoadedState).reelsLoadingMore, isTrue);
      final last = states.last as ProfileLoadedState;
      expect(last.reels?.length, 31);
      expect(last.reelsLoadingMore, isFalse);
    });

    test('does nothing when reelsHasMore is false', () async {
      await startBloc(itemCount: 5); // 5 < 30 -> reelsHasMore=false

      final states = await _collectStates(bloc, const ProfileReelsLoadMore());
      expect(states, isEmpty);
    });

    test('settles reelsLoadingMore=false on error', () async {
      await startBloc();
      when(
        () => mockSocial.getUserReels(
          any(),
          mine: any(named: 'mine'),
          page: 2,
          limit: 30,
        ),
      ).thenThrow(Exception('network'));

      final states = await _collectStates(bloc, const ProfileReelsLoadMore());

      expect((states.last as ProfileLoadedState).reelsLoadingMore, isFalse);
    });

    test('does nothing when state is not ProfileLoadedState', () async {
      final states = await _collectStates(bloc, const ProfileReelsLoadMore());
      expect(states, isEmpty);
    });
  });

  group('ProfilePullToRefresh', () {
    Future<void> startBloc() async {
      when(
        () => mockSocial.getProfile(any()),
      ).thenAnswer((_) async => _kProfile);
      when(
        () => mockSocial.getUserProducts(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Product>(data: <Product>[_kProduct]),
      );
      final sub = bloc.stream.listen((_) {});
      bloc.add(const ProfileStarted(userId: 'u1'));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('emits a value-distinct state first (productsLoadingMore=true) then '
        'fresh data when on the products tab', () async {
      await startBloc();
      const refreshedProduct = Product(id: 'p2', title: 'Pants', price: 80);
      when(
        () => mockSocial.getUserProducts(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async =>
            const PaginatedList<Product>(data: <Product>[refreshedProduct]),
      );

      final states = await _collectStates(bloc, const ProfilePullToRefresh());

      expect((states.first as ProfileLoadedState).productsLoadingMore, isTrue);
      final last = states.last as ProfileLoadedState;
      expect(last.products, [refreshedProduct]);
      expect(last.productsLoadingMore, isFalse);
      verifyNever(
        () => mockSocial.getUserReels(
          any(),
          mine: any(named: 'mine'),
          limit: any(named: 'limit'),
        ),
      );
    });

    test(
      'also refetches reels page 1 when reels were already loaded',
      () async {
        await startBloc();
        when(
          () => mockSocial.getUserReels(
            any(),
            mine: any(named: 'mine'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => const PaginatedList<ProfileReel>(data: <ProfileReel>[]),
        );
        // Load reels once so `reels` is non-null on the state.
        final sub = bloc.stream.listen((_) {});
        bloc.add(const ProfileTabChanged(ProfileTab.reels));
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        clearInteractions(mockSocial);

        const refreshedReel = ProfileReel(id: 'r-new');
        when(
          () => mockSocial.getUserReels(
            any(),
            mine: any(named: 'mine'),
            page: 1,
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => const PaginatedList<ProfileReel>(
            data: <ProfileReel>[refreshedReel],
          ),
        );

        final states = await _collectStates(bloc, const ProfilePullToRefresh());

        final last = states.last as ProfileLoadedState;
        expect(last.reels, [refreshedReel]);
        verify(
          () => mockSocial.getUserReels(
            any(),
            mine: any(named: 'mine'),
            page: 1,
            limit: any(named: 'limit'),
          ),
        ).called(1);
      },
    );

    test('settles the spinner and keeps stale data on error', () async {
      await startBloc();
      when(
        () => mockSocial.getUserProducts(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('network'));

      final states = await _collectStates(bloc, const ProfilePullToRefresh());

      final last = states.last as ProfileLoadedState;
      expect(last.productsLoadingMore, isFalse);
      expect(last.reelsLoadingMore, isFalse);
      expect(last.products, [_kProduct]); // stale data preserved
    });

    test('does nothing when state is not ProfileLoadedState', () async {
      final states = await _collectStates(bloc, const ProfilePullToRefresh());
      expect(states, isEmpty);
    });

    test('refetches via getMyProfile (not getProfile) when refreshing my own '
        'profile', () async {
      when(
        () => mockSocial.getMyProfile(),
      ).thenAnswer((_) async => _kMyProfile);
      when(
        () => mockSocial.getUserProducts(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Product>(data: <Product>[_kProduct]),
      );
      final sub = bloc.stream.listen((_) {});
      bloc.add(const ProfileStarted());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      clearInteractions(mockSocial);
      when(
        () => mockSocial.getMyProfile(),
      ).thenAnswer((_) async => _kMyProfile);
      when(
        () => mockSocial.getUserProducts(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Product>(data: <Product>[_kProduct]),
      );

      final states = await _collectStates(bloc, const ProfilePullToRefresh());

      expect((states.last as ProfileLoadedState).profile, _kMyProfile);
      verify(() => mockSocial.getMyProfile()).called(1);
      verifyNever(() => mockSocial.getProfile(any()));
    });
  });

  group('ProfileRefreshed', () {
    Future<void> startBlocAsMe() async {
      when(
        () => mockSocial.getMyProfile(),
      ).thenAnswer((_) async => _kMyProfile);
      when(
        () => mockSocial.getUserProducts(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Product>(data: <Product>[_kProduct]),
      );
      final sub = bloc.stream.listen((_) {});
      bloc.add(const ProfileStarted());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('does nothing when state is not ProfileLoadedState', () async {
      final states = await _collectStates(bloc, const ProfileRefreshed());
      expect(states, isEmpty);
    });

    test('does nothing when the loaded profile is not mine', () async {
      when(
        () => mockSocial.getProfile(any()),
      ).thenAnswer((_) async => _kProfile);
      when(
        () => mockSocial.getUserProducts(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Product>(data: <Product>[_kProduct]),
      );
      final sub = bloc.stream.listen((_) {});
      bloc.add(const ProfileStarted(userId: 'u1'));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      final states = await _collectStates(bloc, const ProfileRefreshed());
      expect(states, isEmpty);
    });

    test('quietly refetches profile and products, leaving reels untouched when '
        'not yet loaded', () async {
      await startBlocAsMe();
      const refreshedProduct = Product(id: 'p2', title: 'Pants', price: 80);
      when(
        () => mockSocial.getMyProfile(),
      ).thenAnswer((_) async => _kMyProfile);
      when(
        () => mockSocial.getUserProducts(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async =>
            const PaginatedList<Product>(data: <Product>[refreshedProduct]),
      );

      final states = await _collectStates(bloc, const ProfileRefreshed());

      expect(states, hasLength(1));
      final loaded = states.single as ProfileLoadedState;
      expect(loaded.products, [refreshedProduct]);
      expect(loaded.reels, isNull);
      verifyNever(
        () => mockSocial.getUserReels(
          any(),
          mine: any(named: 'mine'),
          limit: any(named: 'limit'),
        ),
      );
    });

    test('also quietly refetches reels page 1 when already loaded', () async {
      await startBlocAsMe();
      when(
        () => mockSocial.getUserReels(
          any(),
          mine: any(named: 'mine'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<ProfileReel>(data: <ProfileReel>[]),
      );
      final sub = bloc.stream.listen((_) {});
      bloc.add(const ProfileTabChanged(ProfileTab.reels));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      clearInteractions(mockSocial);

      const refreshedReel = ProfileReel(id: 'r-new');
      when(
        () => mockSocial.getMyProfile(),
      ).thenAnswer((_) async => _kMyProfile);
      when(
        () => mockSocial.getUserProducts(
          any(),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Product>(data: <Product>[_kProduct]),
      );
      when(
        () => mockSocial.getUserReels(
          any(),
          mine: any(named: 'mine'),
          page: 1,
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<ProfileReel>(
          data: <ProfileReel>[refreshedReel],
        ),
      );

      final states = await _collectStates(bloc, const ProfileRefreshed());

      expect(states, hasLength(1));
      final loaded = states.single as ProfileLoadedState;
      expect(loaded.reels, [refreshedReel]);
    });

    test('emits nothing and keeps state as-is on error', () async {
      await startBlocAsMe();
      when(() => mockSocial.getMyProfile()).thenThrow(Exception('network'));

      final states = await _collectStates(bloc, const ProfileRefreshed());

      expect(states, isEmpty);
    });

    test(
      'ProductsChangedEvent on the app EventBus triggers a quiet refresh',
      () async {
        await startBlocAsMe();
        const refreshedProduct = Product(id: 'p2', title: 'Pants', price: 80);
        when(
          () => mockSocial.getMyProfile(),
        ).thenAnswer((_) async => _kMyProfile);
        when(
          () => mockSocial.getUserProducts(
            any(),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async =>
              const PaginatedList<Product>(data: <Product>[refreshedProduct]),
        );

        final states = <ProfileState>[];
        final sub = bloc.stream.listen(states.add);
        eventBus.fire(const ProductsChangedEvent());
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();

        final loaded = states.last as ProfileLoadedState;
        expect(loaded.products, [refreshedProduct]);
      },
    );

    test(
      'ReelsChangedEvent on the app EventBus triggers a quiet refresh',
      () async {
        await startBlocAsMe();
        const refreshedProduct = Product(id: 'p2', title: 'Pants', price: 80);
        when(
          () => mockSocial.getMyProfile(),
        ).thenAnswer((_) async => _kMyProfile);
        when(
          () => mockSocial.getUserProducts(
            any(),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async =>
              const PaginatedList<Product>(data: <Product>[refreshedProduct]),
        );

        final states = <ProfileState>[];
        final sub = bloc.stream.listen(states.add);
        eventBus.fire(const ReelsChangedEvent());
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();

        final loaded = states.last as ProfileLoadedState;
        expect(loaded.products, [refreshedProduct]);
      },
    );

    test(
      'ProfileChangedEvent on the app EventBus triggers a quiet refresh',
      () async {
        await startBlocAsMe();
        const refreshedProduct = Product(id: 'p2', title: 'Pants', price: 80);
        when(
          () => mockSocial.getMyProfile(),
        ).thenAnswer((_) async => _kMyProfile);
        when(
          () => mockSocial.getUserProducts(
            any(),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async =>
              const PaginatedList<Product>(data: <Product>[refreshedProduct]),
        );

        final states = <ProfileState>[];
        final sub = bloc.stream.listen(states.add);
        eventBus.fire(const ProfileChangedEvent());
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();

        final loaded = states.last as ProfileLoadedState;
        expect(loaded.products, [refreshedProduct]);
      },
    );
  });
}
