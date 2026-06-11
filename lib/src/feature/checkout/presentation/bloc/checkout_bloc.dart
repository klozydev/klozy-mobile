import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/app/cart/cart_cubit.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/checkout/checkout_repository.dart';
import 'package:klozy/src/domain/checkout/entity/checkout_quote.dart';
import 'package:klozy/src/domain/checkout/entity/checkout_result.dart';
import 'package:klozy/src/domain/me/entity/address.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/checkout/presentation/bloc/checkout_event.dart';
import 'package:klozy/src/feature/checkout/presentation/bloc/checkout_state.dart';

@injectable
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CheckoutRepository _checkoutRepository;
  final MeRepository _meRepository;
  final CartCubit _cartCubit;

  String _sellerId = '';
  List<Address> _addresses = const <Address>[];
  String? _selectedId;
  String? _shipmentType;
  CheckoutQuote _quote = const CheckoutQuote();
  CheckoutResult? _result;

  CheckoutBloc(this._checkoutRepository, this._meRepository, this._cartCubit)
    : super(const CheckoutLoadingState()) {
    on<CheckoutStarted>(_onStarted);
    on<CheckoutAddressesRefreshRequested>(_onAddressesRefreshRequested);
    on<CheckoutAddressSelected>(_onAddressSelected);
    on<CheckoutShipmentSelected>(_onShipmentSelected);
    on<CheckoutPayRequested>(_onPayRequested);
    on<CheckoutPaid>(_onPaid);
    on<CheckoutPayCancelled>(_onPayCancelled);
  }

  CheckoutReadyState get _ready => CheckoutReadyState(
    addresses: _addresses,
    selectedAddressId: _selectedId,
    selectedShipmentType: _shipmentType,
    quote: _quote,
  );

  Future<void> _onStarted(
    CheckoutStarted event,
    Emitter<CheckoutState> emit,
  ) async {
    _sellerId = event.sellerId;
    emit(const CheckoutLoadingState());
    try {
      try {
        _addresses = await _meRepository.getAddresses();
      } catch (_) {
        _addresses = const <Address>[];
      }
      _selectedId = _defaultAddressId();
      _quote = await _checkoutRepository.quote(
        _sellerId,
        addressId: _selectedId,
      );
      _shipmentType = _quote.shipmentType;
      emit(_ready);
    } catch (error) {
      emit(CheckoutErrorState(type: AppErrorType.fromException(error)));
    }
  }

  Future<void> _onAddressesRefreshRequested(
    CheckoutAddressesRefreshRequested event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutReadyState) return;
    try {
      _addresses = await _meRepository.getAddresses();
    } catch (_) {
      emit(_ready);
      return;
    }
    final bool selectionGone =
        _selectedId == null ||
        !_addresses.any((Address a) => a.id == _selectedId);
    if (!selectionGone) {
      emit(_ready);
      return;
    }
    _selectedId = _defaultAddressId();
    emit(_ready.copyWith(isQuoting: true));
    try {
      _quote = await _checkoutRepository.quote(
        _sellerId,
        addressId: _selectedId,
      );
      _shipmentType = _quote.shipmentType;
    } catch (_) {}
    emit(_ready);
  }

  String? _defaultAddressId() {
    if (_addresses.isEmpty) return null;
    for (final Address a in _addresses) {
      if (a.isDefault) return a.id;
    }
    return _addresses.first.id;
  }

  Future<void> _onAddressSelected(
    CheckoutAddressSelected event,
    Emitter<CheckoutState> emit,
  ) async {
    final previousId = _selectedId;
    _selectedId = event.addressId;
    emit(_ready.copyWith(isQuoting: true));
    try {
      _quote = await _checkoutRepository.quote(
        _sellerId,
        addressId: _selectedId,
      );
      // Tiers (and prices) are address-specific — reset to the new default.
      _shipmentType = _quote.shipmentType;
    } catch (_) {
      // Keeping the new address with the OLD quote would display totals that
      // belong to a different address — revert the selection and tell the
      // user instead.
      _selectedId = previousId;
      emit(const CheckoutQuoteFailedState());
    }
    emit(_ready);
  }

  void _onShipmentSelected(
    CheckoutShipmentSelected event,
    Emitter<CheckoutState> emit,
  ) {
    _shipmentType = event.shipmentType;
    emit(_ready);
  }

  Future<void> _onPayRequested(
    CheckoutPayRequested event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(_ready.copyWith(isCreating: true));
    try {
      _result = await _checkoutRepository.checkout(
        _sellerId,
        addressId: _selectedId,
        shipmentType: _shipmentType,
      );
      emit(CheckoutPaymentState(_result!));
    } catch (_) {
      // Surface the failure — silently re-emitting ready made the Pay tap
      // look like a no-op.
      emit(const CheckoutPayFailedState());
      emit(_ready);
    }
  }

  Future<void> _onPaid(CheckoutPaid event, Emitter<CheckoutState> emit) async {
    final result = _result;
    if (result == null) return;
    await _cartCubit.load();
    emit(CheckoutDoneState(result.order.orderId));
  }

  void _onPayCancelled(
    CheckoutPayCancelled event,
    Emitter<CheckoutState> emit,
  ) {
    emit(_ready);
  }
}
