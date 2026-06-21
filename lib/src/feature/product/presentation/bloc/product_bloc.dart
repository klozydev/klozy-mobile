import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/app/cart/cart_cubit.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/cart/cart_repository.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/domain/product/products_repository.dart';
import 'package:klozy/src/feature/product/presentation/bloc/product_event.dart';
import 'package:klozy/src/feature/product/presentation/bloc/product_state.dart';

@injectable
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductsRepository _productsRepository;
  final CartRepository _cartRepository;
  final MeRepository _meRepository;
  final CartCubit _cartCubit;

  ProductBloc(
    this._productsRepository,
    this._cartRepository,
    this._meRepository,
    this._cartCubit,
  ) : super(const ProductLoadingState()) {
    on<ProductStarted>(_onStarted);
    on<ProductAddToCart>(_onAddToCart);
    on<ProductMarkStatus>(_onMarkStatus);
    on<ProductDeleted>(_onDeleted);
    on<ProductReported>(_onReported);
  }

  Future<void> _onStarted(
    ProductStarted event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoadingState());
    try {
      var detail = await _productsRepository.getProduct(event.id);
      if (!detail.isOwner) {
        detail = detail.copyWith(isOwner: await _isMine(detail));
      }
      emit(ProductLoadedState(detail: detail, inCart: _isInCart(detail.id)));
    } catch (error) {
      emit(ProductErrorState(type: AppErrorType.fromException(error)));
    }
  }

  /// Whether the product is already in the app-wide cart (so the CTA shows the
  /// "in cart" state when the page is reopened).
  bool _isInCart(String productId) {
    return _cartCubit.state.buckets.any(
      (bucket) => bucket.items.any((item) => item.productId == productId),
    );
  }

  Future<bool> _isMine(ProductDetail detail) async {
    try {
      final me = await _meRepository.getMe();
      return me.id.isNotEmpty && me.id == detail.seller.id;
    } catch (_) {
      return false;
    }
  }

  Future<void> _onAddToCart(
    ProductAddToCart event,
    Emitter<ProductState> emit,
  ) async {
    final current = state;
    if (current is! ProductLoadedState) return;
    try {
      await _cartRepository.addItem(current.detail.id);
      emit(current.copyWith(inCart: true));
      // Reload the app-wide cart only after the add has persisted, so the home
      // cart badge reflects the new item (the old fire-and-forget refresh on
      // the page raced the add and read a stale count).
      await _cartCubit.load();
    } catch (_) {}
  }

  Future<void> _onMarkStatus(
    ProductMarkStatus event,
    Emitter<ProductState> emit,
  ) async {
    final current = state;
    if (current is! ProductLoadedState) return;
    try {
      await _productsRepository.updateStatus(current.detail.id, event.status);
      emit(
        current.copyWith(detail: current.detail.copyWith(status: event.status)),
      );
    } catch (_) {}
  }

  Future<void> _onDeleted(
    ProductDeleted event,
    Emitter<ProductState> emit,
  ) async {
    final current = state;
    if (current is! ProductLoadedState) return;
    try {
      await _productsRepository.deleteProduct(current.detail.id);
      emit(const ProductDeletedState());
    } catch (_) {}
  }

  Future<void> _onReported(
    ProductReported event,
    Emitter<ProductState> emit,
  ) async {
    final current = state;
    if (current is! ProductLoadedState) return;
    try {
      await _productsRepository.reportProduct(
        current.detail.id,
        'Reported from app',
      );
    } catch (_) {}
  }
}
