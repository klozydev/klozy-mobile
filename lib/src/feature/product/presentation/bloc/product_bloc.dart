import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
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

  ProductBloc(
    this._productsRepository,
    this._cartRepository,
    this._meRepository,
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
      emit(ProductLoadedState(detail: detail));
    } catch (error) {
      emit(ProductErrorState(type: AppErrorType.fromException(error)));
    }
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
      emit(const ProductCartResultState(success: true));
      emit(current.copyWith(inCart: true));
    } catch (_) {
      // Surface the failure — swallowing it while the page showed an
      // unconditional success snackbar told the user the item was added
      // when it wasn't.
      emit(const ProductCartResultState(success: false));
      emit(current);
    }
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
    } catch (_) {
      emit(const ProductDeleteFailedState());
      emit(current);
    }
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
