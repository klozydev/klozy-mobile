import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/app/cart/cart_cubit.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/cart/cart_repository.dart';
import 'package:klozy/src/domain/offers/offers_repository.dart';
import 'package:klozy/src/feature/cart/presentation/bloc/cart_event.dart';
import 'package:klozy/src/feature/cart/presentation/bloc/cart_state.dart';

@injectable
class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _cartRepository;
  final OffersRepository _offersRepository;
  final CartCubit _cartCubit;

  CartBloc(this._cartRepository, this._offersRepository, this._cartCubit)
    : super(const CartLoadingState()) {
    on<CartStarted>(_onStarted);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartOfferMade>(_onOfferMade);
    on<CartOfferCancelled>(_onOfferCancelled);
  }

  Future<void> _onStarted(CartStarted event, Emitter<CartState> emit) async {
    emit(const CartLoadingState());
    await _reload(emit, fatal: true);
  }

  Future<void> _onItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    await _mutate(emit, () => _cartRepository.removeItem(event.productId));
  }

  Future<void> _onOfferMade(
    CartOfferMade event,
    Emitter<CartState> emit,
  ) async {
    await _mutate(
      emit,
      () => _offersRepository.makeOffer(
        productIds: event.productIds,
        amount: event.amount,
      ),
    );
  }

  Future<void> _onOfferCancelled(
    CartOfferCancelled event,
    Emitter<CartState> emit,
  ) async {
    await _mutate(emit, () => _offersRepository.cancelOffer(event.offerId));
  }

  Future<void> _mutate(
    Emitter<CartState> emit,
    Future<void> Function() action,
  ) async {
    final current = state;
    if (current is CartLoadedState) {
      emit(CartLoadedState(current.cart, isMutating: true));
    }
    try {
      await action();
    } catch (_) {}
    await _reload(emit, fatal: false);
  }

  Future<void> _reload(Emitter<CartState> emit, {required bool fatal}) async {
    try {
      final cart = await _cartRepository.getCart();
      emit(CartLoadedState(cart));
      await _cartCubit.load();
    } catch (error) {
      if (fatal) {
        emit(CartErrorState(type: AppErrorType.fromException(error)));
      }
    }
  }
}
