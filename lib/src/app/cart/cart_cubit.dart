import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/domain/cart/cart_repository.dart';
import 'package:klozy/src/domain/cart/entity/cart.dart';

/// App-wide cart state — the single source for the bottom/home cart badge count
/// and the cart screen.
@lazySingleton
class CartCubit extends Cubit<Cart> {
  final CartRepository _repository;

  CartCubit(this._repository) : super(Cart.empty);

  int get itemCount => state.itemCount;

  Future<void> load() async {
    try {
      emit(await _repository.getCart());
    } catch (_) {
      // Keep the last known cart on failure.
    }
  }

  Future<void> refresh() => load();

  /// Adds a product to the cart (server) then reloads. Rethrows so callers that
  /// depend on the item being in the cart (e.g. making an offer) can react.
  Future<void> add(String productId) async {
    await _repository.addItem(productId);
    await load();
  }

  Future<void> remove(String productId) async {
    try {
      await _repository.removeItem(productId);
    } catch (_) {}
    await load();
  }
}
