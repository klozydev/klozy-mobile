import 'package:event_bus/event_bus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/events/wishlist_changed_event.dart';
import 'package:klozy/src/core/pagination/paginated_list.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/wishlist/wishlist_repository.dart';
import 'package:klozy/src/feature/home/presentation/bloc/wishlist_feed_cubit.dart';
import 'package:klozy/src/feature/home/presentation/bloc/wishlist_feed_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockWishlistRepository extends Mock implements WishlistRepository {}

Future<List<WishlistFeedState>> _collectStates(
  WishlistFeedCubit cubit,
  Future<void> Function() action,
) async {
  final states = <WishlistFeedState>[];
  final sub = cubit.stream.listen(states.add);
  await action();
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

const _kProduct = Product(id: 'p1', title: 'Shirt', price: 50);

void main() {
  late _MockWishlistRepository mockRepo;
  late EventBus eventBus;
  late WishlistFeedCubit cubit;

  setUp(() {
    mockRepo = _MockWishlistRepository();
    eventBus = EventBus();
    cubit = WishlistFeedCubit(mockRepo, eventBus);
  });

  tearDown(() => cubit.close());

  test('initial state is WishlistFeedLoading', () {
    expect(cubit.state, const WishlistFeedLoading());
  });

  group('load', () {
    test('emits [loading, loaded] on success', () async {
      when(
        () => mockRepo.getWishlistProducts(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Product>(data: <Product>[_kProduct]),
      );

      final states = await _collectStates(cubit, cubit.load);

      expect(states.first, const WishlistFeedLoading());
      final loaded = states.last as WishlistFeedLoaded;
      expect(loaded.items, [_kProduct]);
      expect(loaded.hasMore, isFalse); // 1 < 20
    });

    test('hasMore is true when a full page comes back', () async {
      final products = List.generate(
        20,
        (i) => Product(id: 'p$i', title: 'P$i', price: i.toDouble()),
      );
      when(
        () => mockRepo.getWishlistProducts(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => PaginatedList<Product>(data: products));

      final states = await _collectStates(cubit, cubit.load);

      final loaded = states.last as WishlistFeedLoaded;
      expect(loaded.hasMore, isTrue);
    });

    test('emits [loading, error] on failure', () async {
      when(
        () => mockRepo.getWishlistProducts(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('network'));

      final states = await _collectStates(cubit, cubit.load);

      expect(states.first, const WishlistFeedLoading());
      expect(states.last, isA<WishlistFeedError>());
    });
  });

  group('loadMore', () {
    Future<void> loadFirstPage({int itemCount = 20}) async {
      final products = List.generate(
        itemCount,
        (i) => Product(id: 'p$i', title: 'P$i', price: i.toDouble()),
      );
      when(
        () => mockRepo.getWishlistProducts(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => PaginatedList<Product>(data: products));
      await cubit.load();
    }

    test('appends next page on success', () async {
      await loadFirstPage(); // 20 items -> hasMore=true

      when(() => mockRepo.getWishlistProducts(page: 2, limit: 20)).thenAnswer(
        (_) async => const PaginatedList<Product>(data: <Product>[_kProduct]),
      );

      final states = await _collectStates(cubit, cubit.loadMore);

      expect((states.first as WishlistFeedLoaded).loadingMore, isTrue);
      final last = states.last as WishlistFeedLoaded;
      expect(last.items.length, 21);
      expect(last.loadingMore, isFalse);
    });

    test('does nothing when hasMore is false', () async {
      await loadFirstPage(itemCount: 5); // 5 < 20 -> hasMore=false

      final states = await _collectStates(cubit, cubit.loadMore);
      expect(states, isEmpty);
    });

    test('settles loadingMore=false on error', () async {
      await loadFirstPage();
      when(
        () => mockRepo.getWishlistProducts(page: 2, limit: 20),
      ).thenThrow(Exception('network'));

      final states = await _collectStates(cubit, cubit.loadMore);

      expect((states.last as WishlistFeedLoaded).loadingMore, isFalse);
    });

    test('does nothing when state is not WishlistFeedLoaded', () async {
      final states = await _collectStates(cubit, cubit.loadMore);
      expect(states, isEmpty);
    });
  });

  group('refresh', () {
    Future<void> loadFirstPage() async {
      when(
        () => mockRepo.getWishlistProducts(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Product>(data: <Product>[_kProduct]),
      );
      await cubit.load();
    }

    test(
      'emits a value-distinct state first (loadingMore=true) then fresh data',
      () async {
        await loadFirstPage();
        const refreshedProduct = Product(id: 'p2', title: 'Pants', price: 80);
        when(
          () => mockRepo.getWishlistProducts(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async =>
              const PaginatedList<Product>(data: <Product>[refreshedProduct]),
        );

        final states = await _collectStates(cubit, cubit.refresh);

        expect((states.first as WishlistFeedLoaded).loadingMore, isTrue);
        final last = states.last as WishlistFeedLoaded;
        expect(last.items, [refreshedProduct]);
        expect(last.loadingMore, isFalse);
      },
    );

    test('settles loadingMore=false and keeps stale data on error', () async {
      await loadFirstPage();
      when(
        () => mockRepo.getWishlistProducts(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('network'));

      final states = await _collectStates(cubit, cubit.refresh);

      final last = states.last as WishlistFeedLoaded;
      expect(last.loadingMore, isFalse);
      expect(last.items, [_kProduct]); // stale data preserved
    });

    test('falls back to a full load when not yet loaded', () async {
      when(
        () => mockRepo.getWishlistProducts(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Product>(data: <Product>[_kProduct]),
      );

      final states = await _collectStates(cubit, cubit.refresh);

      expect(states.first, const WishlistFeedLoading());
      final loaded = states.last as WishlistFeedLoaded;
      expect(loaded.items, [_kProduct]);
    });

    test(
      'allows loadMore to fetch the correct next page after a refresh',
      () async {
        // Load then loadMore once so the internal page counter is at 2.
        final fullPage = List.generate(
          20,
          (i) => Product(id: 'p$i', title: 'P$i', price: i.toDouble()),
        );
        when(
          () => mockRepo.getWishlistProducts(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => PaginatedList<Product>(data: fullPage));
        await cubit.load();
        await cubit.loadMore(); // internal page counter now at 2

        // Refresh should reset the internal page counter back to 1 — a
        // subsequent loadMore must therefore request page 2, not page 3.
        await cubit.refresh();
        clearInteractions(mockRepo);

        when(() => mockRepo.getWishlistProducts(page: 2, limit: 20)).thenAnswer(
          (_) async => const PaginatedList<Product>(
            data: <Product>[Product(id: 'p3', title: 'Hat', price: 30)],
          ),
        );

        await cubit.loadMore();

        verify(
          () => mockRepo.getWishlistProducts(page: 2, limit: 20),
        ).called(1);
      },
    );
  });

  group('WishlistFeedState equality/copyWith', () {
    test('two WishlistFeedLoading instances are equal', () {
      expect(const WishlistFeedLoading(), const WishlistFeedLoading());
    });

    test('WishlistFeedError with same type are equal', () {
      expect(
        const WishlistFeedError(AppErrorType.network),
        const WishlistFeedError(AppErrorType.network),
      );
    });

    test('WishlistFeedError with different type are not equal', () {
      expect(
        const WishlistFeedError(AppErrorType.network),
        isNot(const WishlistFeedError(AppErrorType.server)),
      );
    });

    test('copyWith(loadingMore:) preserves items/hasMore', () {
      const original = WishlistFeedLoaded(
        items: [_kProduct],
        hasMore: true,
        loadingMore: false,
      );

      final updated = original.copyWith(loadingMore: true);

      expect(updated.items, original.items);
      expect(updated.hasMore, original.hasMore);
      expect(updated.loadingMore, isTrue);
    });
  });

  group('WishlistChangedEvent', () {
    test('triggers a quiet refresh', () async {
      when(
        () => mockRepo.getWishlistProducts(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Product>(data: <Product>[_kProduct]),
      );
      await cubit.load();

      const refreshedProduct = Product(id: 'p2', title: 'Pants', price: 80);
      when(
        () => mockRepo.getWishlistProducts(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async =>
            const PaginatedList<Product>(data: <Product>[refreshedProduct]),
      );

      final states = <WishlistFeedState>[];
      final sub = cubit.stream.listen(states.add);
      eventBus.fire(const WishlistChangedEvent());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(cubit.state, isA<WishlistFeedLoaded>());
      expect((cubit.state as WishlistFeedLoaded).items, [refreshedProduct]);
    });
  });
}
