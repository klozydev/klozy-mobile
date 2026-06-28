import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/app/cart/cart_cubit.dart';
import 'package:klozy/src/domain/cart/cart_repository.dart';
import 'package:klozy/src/domain/cart/entity/cart.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/domain/product/products_repository.dart';
import 'package:klozy/src/feature/product/presentation/bloc/product_bloc.dart';
import 'package:klozy/src/feature/product/presentation/bloc/product_event.dart';
import 'package:klozy/src/feature/product/presentation/bloc/product_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockProductsRepository extends Mock implements ProductsRepository {}

class _MockCartRepository extends Mock implements CartRepository {}

class _MockMeRepository extends Mock implements MeRepository {}

class _MockCartCubit extends Mock implements CartCubit {}

Future<List<ProductState>> _collectStates(
  ProductBloc bloc,
  ProductEvent event,
) async {
  final states = <ProductState>[];
  final sub = bloc.stream.listen(states.add);
  bloc.add(event);
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

const _kSeller = ProductSeller(id: 's1', displayName: 'Bob');
const _kDetail = ProductDetail(
  id: 'p1',
  title: 'Shirt',
  price: 50,
  seller: _kSeller,
);

void main() {
  late _MockProductsRepository mockProducts;
  late _MockCartRepository mockCart;
  late _MockMeRepository mockMe;
  late _MockCartCubit mockCubit;
  late ProductBloc bloc;

  setUpAll(() {
    registerFallbackValue(ProductStatus.active);
  });

  setUp(() {
    mockProducts = _MockProductsRepository();
    mockCart = _MockCartRepository();
    mockMe = _MockMeRepository();
    mockCubit = _MockCartCubit();
    when(() => mockCubit.state).thenReturn(Cart.empty);
    when(() => mockCubit.load()).thenAnswer((_) async {});
    bloc = ProductBloc(mockProducts, mockCart, mockMe, mockCubit);
  });

  tearDown(() => bloc.close());

  test('initial state is ProductLoadingState', () {
    expect(bloc.state, const ProductLoadingState());
  });

  group('ProductStarted', () {
    test('emits [loading, loaded] on success (not owner)', () async {
      when(
        () => mockProducts.getProduct(any()),
      ).thenAnswer((_) async => _kDetail);
      when(() => mockMe.getMe()).thenAnswer(
        (_) async => const MeProfile(id: 'other'),
      ); // different seller

      final states = await _collectStates(bloc, const ProductStarted('p1'));

      expect(states.first, const ProductLoadingState());
      final loaded = states.last as ProductLoadedState;
      expect(loaded.detail, isA<ProductDetail>());
      expect(loaded.inCart, isFalse);
    });

    test('sets isOwner=true when me.id matches seller.id', () async {
      const ownerMe = MeProfile(id: 's1');
      when(
        () => mockProducts.getProduct(any()),
      ).thenAnswer((_) async => _kDetail);
      when(() => mockMe.getMe()).thenAnswer((_) async => ownerMe);

      final states = await _collectStates(bloc, const ProductStarted('p1'));

      final loaded = states.last as ProductLoadedState;
      expect(loaded.detail.isOwner, isTrue);
    });

    test('emits loaded with isOwner=false when getMe throws', () async {
      when(
        () => mockProducts.getProduct(any()),
      ).thenAnswer((_) async => _kDetail);
      when(() => mockMe.getMe()).thenThrow(Exception('auth'));

      final states = await _collectStates(bloc, const ProductStarted('p1'));

      final loaded = states.last as ProductLoadedState;
      expect(loaded.detail.isOwner, isFalse);
    });

    test('emits [loading, error] when getProduct throws', () async {
      when(
        () => mockProducts.getProduct(any()),
      ).thenThrow(Exception('not found'));

      final states = await _collectStates(bloc, const ProductStarted('p1'));

      expect(states.first, const ProductLoadingState());
      expect(states.last, isA<ProductErrorState>());
    });
  });

  group('ProductAddToCart', () {
    Future<void> loadProduct() async {
      when(
        () => mockProducts.getProduct(any()),
      ).thenAnswer((_) async => _kDetail);
      when(
        () => mockMe.getMe(),
      ).thenAnswer((_) async => const MeProfile(id: 'other'));
      final sub = bloc.stream.listen((_) {});
      bloc.add(const ProductStarted('p1'));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('adds to cart and emits loaded(inCart=true)', () async {
      await loadProduct();
      when(() => mockCart.addItem(any())).thenAnswer((_) async {});

      final states = await _collectStates(bloc, const ProductAddToCart());

      final loaded = states.last as ProductLoadedState;
      expect(loaded.inCart, isTrue);
      verify(() => mockCart.addItem('p1')).called(1);
      verify(() => mockCubit.load()).called(1);
    });

    test('silently ignores error when addItem throws', () async {
      await loadProduct();
      when(() => mockCart.addItem(any())).thenThrow(Exception('server'));

      final states = await _collectStates(bloc, const ProductAddToCart());

      expect(states, isEmpty); // no state change on error
    });

    test('does nothing when state is not loaded', () async {
      final states = await _collectStates(bloc, const ProductAddToCart());
      expect(states, isEmpty);
    });
  });

  group('ProductMarkStatus', () {
    Future<void> loadProduct() async {
      when(
        () => mockProducts.getProduct(any()),
      ).thenAnswer((_) async => _kDetail);
      when(
        () => mockMe.getMe(),
      ).thenAnswer((_) async => const MeProfile(id: 's1'));
      final sub = bloc.stream.listen((_) {});
      bloc.add(const ProductStarted('p1'));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('updates status on success', () async {
      await loadProduct();
      when(
        () => mockProducts.updateStatus(any(), any()),
      ).thenAnswer((_) async {});

      final states = await _collectStates(
        bloc,
        const ProductMarkStatus(ProductStatus.sold),
      );

      final loaded = states.last as ProductLoadedState;
      expect(loaded.detail.status, ProductStatus.sold);
    });

    test('silently ignores error', () async {
      await loadProduct();
      when(
        () => mockProducts.updateStatus(any(), any()),
      ).thenThrow(Exception('server'));

      final states = await _collectStates(
        bloc,
        const ProductMarkStatus(ProductStatus.sold),
      );

      expect(states, isEmpty);
    });
  });

  group('ProductDeleted', () {
    Future<void> loadProduct() async {
      when(
        () => mockProducts.getProduct(any()),
      ).thenAnswer((_) async => _kDetail);
      when(
        () => mockMe.getMe(),
      ).thenAnswer((_) async => const MeProfile(id: 's1'));
      final sub = bloc.stream.listen((_) {});
      bloc.add(const ProductStarted('p1'));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('emits ProductDeletedState on success', () async {
      await loadProduct();
      when(() => mockProducts.deleteProduct(any())).thenAnswer((_) async {});

      final states = await _collectStates(bloc, const ProductDeleted());

      expect(states.last, const ProductDeletedState());
    });

    test('silently ignores error', () async {
      await loadProduct();
      when(
        () => mockProducts.deleteProduct(any()),
      ).thenThrow(Exception('server'));

      final states = await _collectStates(bloc, const ProductDeleted());

      expect(states, isEmpty);
    });
  });

  group('ProductReported', () {
    Future<void> loadProduct() async {
      when(
        () => mockProducts.getProduct(any()),
      ).thenAnswer((_) async => _kDetail);
      when(
        () => mockMe.getMe(),
      ).thenAnswer((_) async => const MeProfile(id: 'other'));
      final sub = bloc.stream.listen((_) {});
      bloc.add(const ProductStarted('p1'));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('calls reportProduct silently (no state change)', () async {
      await loadProduct();
      when(
        () => mockProducts.reportProduct(any(), any()),
      ).thenAnswer((_) async {});

      final states = await _collectStates(bloc, const ProductReported());

      expect(states, isEmpty);
      verify(() => mockProducts.reportProduct('p1', any())).called(1);
    });
  });
}
