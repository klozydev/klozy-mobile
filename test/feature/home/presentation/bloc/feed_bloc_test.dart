import 'package:event_bus/event_bus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/product/entity/feed_page.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/product/products_repository.dart';
import 'package:klozy/src/feature/home/presentation/bloc/feed_bloc.dart';
import 'package:klozy/src/feature/home/presentation/bloc/feed_event.dart';
import 'package:klozy/src/feature/home/presentation/bloc/feed_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockProductsRepository extends Mock implements ProductsRepository {}

class _MockCatalogRepository extends Mock implements CatalogRepository {}

Future<List<FeedState>> _collectStates(FeedBloc bloc, FeedEvent event) async {
  final states = <FeedState>[];
  final sub = bloc.stream.listen(states.add);
  bloc.add(event);
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

const _kProduct = Product(id: 'p1', title: 'Shirt', price: 50);
const _kCategory = CatalogCategory(id: 'cat1', label: 'Women');

const _kEmptyPage = FeedPage(data: <Product>[]);
const _kOnePage = FeedPage(data: <Product>[_kProduct]);

void main() {
  late _MockProductsRepository mockProducts;
  late _MockCatalogRepository mockCatalog;
  late FeedBloc bloc;

  setUp(() {
    mockProducts = _MockProductsRepository();
    mockCatalog = _MockCatalogRepository();
    bloc = FeedBloc(mockProducts, mockCatalog, EventBus());
  });

  tearDown(() => bloc.close());

  test('initial state is FeedLoading', () {
    expect(bloc.state, const FeedLoading());
  });

  group('FeedStarted', () {
    test('emits [loading, ready] on success', () async {
      when(
        () => mockCatalog.getRootCategories(),
      ).thenAnswer((_) async => <CatalogCategory>[_kCategory]);
      when(
        () => mockProducts.feed(
          rootCategoryId: any(named: 'rootCategoryId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => _kOnePage);

      final states = await _collectStates(bloc, const FeedStarted());

      expect(states.first, const FeedLoading());
      final ready = states.last as FeedReady;
      expect(ready.items, [_kProduct]);
      expect(ready.categories, [_kCategory]);
    });

    test('emits [loading, error] when products fetch fails', () async {
      when(
        () => mockCatalog.getRootCategories(),
      ).thenAnswer((_) async => <CatalogCategory>[]);
      when(
        () => mockProducts.feed(
          rootCategoryId: any(named: 'rootCategoryId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('network'));

      final states = await _collectStates(bloc, const FeedStarted());

      expect(states.first, const FeedLoading());
      expect(states.last, isA<FeedError>());
    });

    test(
      'proceeds with empty categories when getRootCategories fails',
      () async {
        when(
          () => mockCatalog.getRootCategories(),
        ).thenThrow(Exception('network'));
        when(
          () => mockProducts.feed(
            rootCategoryId: any(named: 'rootCategoryId'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => _kEmptyPage);

        final states = await _collectStates(bloc, const FeedStarted());

        final ready = states.last as FeedReady;
        expect(ready.categories, isEmpty);
      },
    );
  });

  group('FeedCategorySelected', () {
    Future<void> startBloc() async {
      when(
        () => mockCatalog.getRootCategories(),
      ).thenAnswer((_) async => <CatalogCategory>[_kCategory]);
      when(
        () => mockProducts.feed(
          rootCategoryId: any(named: 'rootCategoryId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => _kOnePage);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const FeedStarted());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('emits ready with loadingMore=true then ready with results', () async {
      await startBloc();

      when(
        () => mockProducts.feed(
          rootCategoryId: any(named: 'rootCategoryId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => _kEmptyPage);

      final states = await _collectStates(
        bloc,
        const FeedCategorySelected('cat1'),
      );

      // First emits loading=true, then final result
      expect(states.first, isA<FeedReady>());
      expect((states.first as FeedReady).isLoadingMore, isTrue);
      final last = states.last as FeedReady;
      expect(last.selectedRootId, 'cat1');
    });

    test('emits error when products fetch fails', () async {
      await startBloc();
      when(
        () => mockProducts.feed(
          rootCategoryId: any(named: 'rootCategoryId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('network'));

      final states = await _collectStates(
        bloc,
        const FeedCategorySelected('cat1'),
      );

      expect(states.last, isA<FeedError>());
    });

    test('does nothing when state is not FeedReady', () async {
      // State is still FeedLoading
      final states = await _collectStates(
        bloc,
        const FeedCategorySelected('cat1'),
      );
      expect(states, isEmpty);
    });
  });

  group('FeedLoadMore', () {
    Future<void> startBloc({int itemCount = 20}) async {
      final products = List.generate(
        itemCount,
        (i) => Product(id: 'p$i', title: 'P$i', price: i.toDouble()),
      );
      when(
        () => mockCatalog.getRootCategories(),
      ).thenAnswer((_) async => <CatalogCategory>[]);
      when(
        () => mockProducts.feed(
          rootCategoryId: any(named: 'rootCategoryId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => FeedPage(data: products));
      final sub = bloc.stream.listen((_) {});
      bloc.add(const FeedStarted());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('appends next page on success', () async {
      await startBloc(itemCount: 20); // hasMore=true (20 >= 20)

      when(
        () => mockProducts.feed(
          rootCategoryId: any(named: 'rootCategoryId'),
          page: 2,
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const FeedPage(data: <Product>[_kProduct]));

      final states = await _collectStates(bloc, const FeedLoadMore());

      // loadingMore=true then final state with appended items
      expect((states.first as FeedReady).isLoadingMore, isTrue);
      final last = states.last as FeedReady;
      expect(last.items.length, 21);
    });

    test('does nothing when hasMore is false', () async {
      await startBloc(itemCount: 5); // 5 < 20 → hasMore=false

      final states = await _collectStates(bloc, const FeedLoadMore());
      expect(states, isEmpty);
    });

    test('settles isLoadingMore=false on error', () async {
      await startBloc(itemCount: 20);
      when(
        () => mockProducts.feed(
          rootCategoryId: any(named: 'rootCategoryId'),
          page: 2,
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('network'));

      final states = await _collectStates(bloc, const FeedLoadMore());

      expect((states.last as FeedReady).isLoadingMore, isFalse);
    });
  });

  group('FeedRefreshed', () {
    Future<void> startBloc() async {
      when(
        () => mockCatalog.getRootCategories(),
      ).thenAnswer((_) async => <CatalogCategory>[_kCategory]);
      when(
        () => mockProducts.feed(
          rootCategoryId: any(named: 'rootCategoryId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => _kOnePage);
      final sub = bloc.stream.listen((_) {});
      bloc.add(const FeedStarted());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('refreshes first page silently on success', () async {
      await startBloc();
      const newProduct = Product(id: 'p2', title: 'Pants', price: 80);
      when(
        () => mockProducts.feed(
          rootCategoryId: any(named: 'rootCategoryId'),
          page: 1,
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const FeedPage(data: <Product>[newProduct]));

      final states = await _collectStates(bloc, const FeedRefreshed());

      // First emits loadingMore=true, then fresh data
      final last = states.last as FeedReady;
      expect(last.items, [newProduct]);
    });

    test('settles isLoadingMore=false on error', () async {
      await startBloc();
      when(
        () => mockProducts.feed(
          rootCategoryId: any(named: 'rootCategoryId'),
          page: 1,
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('network'));

      final states = await _collectStates(bloc, const FeedRefreshed());

      expect((states.last as FeedReady).isLoadingMore, isFalse);
    });

    test('does nothing when state is not FeedReady', () async {
      final states = await _collectStates(bloc, const FeedRefreshed());
      expect(states, isEmpty);
    });
  });
}
