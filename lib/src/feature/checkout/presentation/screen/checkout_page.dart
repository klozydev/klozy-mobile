import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Address;
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/checkout/entity/checkout_quote.dart';
import 'package:klozy/src/domain/checkout/entity/checkout_result.dart';
import 'package:klozy/src/domain/me/entity/address.dart';
import 'package:klozy/src/feature/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:klozy/src/feature/checkout/presentation/bloc/checkout_event.dart';
import 'package:klozy/src/feature/checkout/presentation/bloc/checkout_state.dart';
import 'package:klozy/src/router/app_router.dart';

@RoutePage()
class CheckoutPage extends StatelessWidget implements AutoRouteWrapper {
  final String sellerId;

  const CheckoutPage({required this.sellerId, super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<CheckoutBloc>(
      create: (_) => locator<CheckoutBloc>()..add(CheckoutStarted(sellerId)),
      child: this,
    );
  }

  Future<void> _present(BuildContext context, CheckoutResult result) async {
    final payment = result.payment;
    if (!payment.isValid) {
      context.showSnackBar(context.l10N.checkout_payment_unavailable);
      context.read<CheckoutBloc>().add(const CheckoutPayCancelled());
      return;
    }
    try {
      Stripe.publishableKey = payment.publishableKey;
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: payment.clientSecret,
          customerEphemeralKeySecret: payment.ephemeralKey,
          customerId: payment.customerId,
          merchantDisplayName: 'Klozy',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      if (context.mounted) {
        context.read<CheckoutBloc>().add(const CheckoutPaid());
      }
    } on StripeException catch (e) {
      if (context.mounted) {
        if (e.error.code != FailureCode.Canceled) {
          context.showSnackBar(context.l10N.checkout_payment_failed);
        }
        context.read<CheckoutBloc>().add(const CheckoutPayCancelled());
      }
    } catch (_) {
      if (context.mounted) {
        context.showSnackBar(context.l10N.checkout_payment_failed);
        context.read<CheckoutBloc>().add(const CheckoutPayCancelled());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutBloc, CheckoutState>(
      listener: (BuildContext context, CheckoutState state) {
        if (state is CheckoutPaymentState) {
          _present(context, state.result);
        } else if (state is CheckoutPayFailedState) {
          context.showSnackBar(context.l10N.checkout_payment_failed);
        } else if (state is CheckoutQuoteFailedState) {
          context.showSnackBar(context.l10N.checkout_quote_failed);
        }
      },
      buildWhen: (CheckoutState previous, CheckoutState current) =>
          current is! CheckoutPayFailedState &&
          current is! CheckoutQuoteFailedState,
      builder: (BuildContext context, CheckoutState state) {
        return switch (state) {
          CheckoutLoadingState() || CheckoutPaymentState() => const Scaffold(
            backgroundColor: DSColor.surface,
            body: DSLoader(),
          ),
          CheckoutErrorState(:final type) => Scaffold(
            backgroundColor: DSColor.surface,
            appBar: AppBar(),
            body: AppErrorWidget(
              type: type,
              onRetry: () =>
                  context.read<CheckoutBloc>().add(CheckoutStarted(sellerId)),
            ),
          ),
          CheckoutReadyState() => _Review(state: state),
          CheckoutDoneState() => const _OrderPlaced(),
          // Transient one-shot states are filtered by buildWhen; these cases
          // only keep the switch exhaustive.
          CheckoutPayFailedState() ||
          CheckoutQuoteFailedState() => const SizedBox.shrink(),
        };
      },
    );
  }
}

class _Review extends StatelessWidget {
  final CheckoutReadyState state;

  const _Review({required this.state});

  Address? get _selected {
    for (final Address a in state.addresses) {
      if (a.id == state.selectedAddressId) return a;
    }
    return state.addresses.isEmpty ? null : state.addresses.first;
  }

  Future<void> _pickAddress(BuildContext context) async {
    final bloc = context.read<CheckoutBloc>();
    final chosen = await DSBottomSheet.show<String>(
      context,
      title: context.l10N.checkout_delivery,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: state.addresses
            .map(
              (Address a) => InkWell(
                onTap: () => Navigator.of(context).pop(a.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        a.id == state.selectedAddressId
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 20,
                        color: a.id == state.selectedAddressId
                            ? DSColor.primary
                            : DSColor.onSurface45,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              a.title,
                              style: const TextStyle(
                                fontFamily: dsFontFamily,
                                fontSize: DSFontSize.bodyLarge,
                                fontWeight: DSFontWeight.semiBold,
                                color: DSColor.onSurface,
                              ),
                            ),
                            Text(
                              a.summary,
                              style: const TextStyle(
                                fontFamily: dsFontFamily,
                                fontSize: DSFontSize.bodyMedium,
                                color: DSColor.onSurface60,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
    if (chosen != null) bloc.add(CheckoutAddressSelected(chosen));
  }

  @override
  Widget build(BuildContext context) {
    final fees = state.effectiveFees;
    final address = _selected;
    return Scaffold(
      backgroundColor: DSColor.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(context.l10N.checkout_title),
      ),
      bottomNavigationBar: DSBottomBar(
        child: DSButtonElevated(
          text: context.l10N.checkout_pay_amount(fees.total.toInt()),
          isEnable: address != null && !state.isQuoting,
          isLoading: state.isCreating,
          onPressed: () =>
              context.read<CheckoutBloc>().add(const CheckoutPayRequested()),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: <Widget>[
          _DeliveryCard(
            address: address,
            canChange: state.addresses.length > 1,
            onChange: () => _pickAddress(context),
            onAdd: () {
              final bloc = context.read<CheckoutBloc>();
              // Refresh on return — addresses created in the address book
              // must show up (and enable Pay) without leaving checkout.
              context.router
                  .push(const AddressBookRoute())
                  .then(
                    (_) => bloc.add(const CheckoutAddressesRefreshRequested()),
                  )
                  .ignore();
            },
          ),
          _card(context.l10N.checkout_summary, <Widget>[
            if (state.isQuoting)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(height: 18, child: DSLoader()),
              )
            else ...<Widget>[
              if (state.quote.shippingOptions.length > 1) ...<Widget>[
                _ShippingTierChips(state: state),
                const SizedBox(height: 10),
              ],
              _row(context, context.l10N.checkout_subtotal, fees.subtotal),
              _row(context, context.l10N.checkout_shipping_emx, fees.shipping),
              _row(
                context,
                context.l10N.checkout_buyer_protection,
                fees.protection,
              ),
              _row(context, context.l10N.checkout_vat, fees.vat),
              const Divider(height: 20, color: DSColor.onSurface08),
              _row(
                context,
                context.l10N.checkout_total,
                fees.total,
                bold: true,
              ),
            ],
          ]),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.lock_outline,
                  size: 14,
                  color: DSColor.onSurface45,
                ),
                const SizedBox(width: 6),
                Text(
                  context.l10N.checkout_encrypted_escrow_note,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodyMedium,
                    color: DSColor.onSurface45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DSColor.card,
        borderRadius: BorderRadius.circular(DSBorderRadius.card),
        border: Border.all(color: DSColor.onSurface07, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.titleLarge,
              fontWeight: DSFontWeight.semiBold,
              color: DSColor.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    num value, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodyMedium,
              fontWeight: bold ? DSFontWeight.semiBold : DSFontWeight.regular,
              color: bold ? DSColor.onSurface : DSColor.onSurface60,
            ),
          ),
          const Spacer(),
          Text(
            context.l10N.checkout_amount_dhs(value.toInt()),
            style: TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodyMedium,
              fontWeight: bold ? DSFontWeight.bold : DSFontWeight.medium,
              color: DSColor.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShippingTierChips extends StatelessWidget {
  final CheckoutReadyState state;

  const _ShippingTierChips({required this.state});

  @override
  Widget build(BuildContext context) {
    final String? selected =
        state.selectedShipmentType ?? state.quote.shipmentType;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: state.quote.shippingOptions.map((ShippingOption option) {
        final bool active = option.shipmentType == selected;
        return GestureDetector(
          onTap: () => context.read<CheckoutBloc>().add(
            CheckoutShipmentSelected(option.shipmentType),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: active ? const Color(0x1FE0CE7D) : DSColor.onSurface07,
              borderRadius: BorderRadius.circular(DSBorderRadius.chip),
              border: Border.all(
                color: active ? DSColor.primary : DSColor.onSurface15,
                width: active ? 1 : 0.5,
              ),
            ),
            child: Text(
              '${option.shipmentType} · ${context.l10N.checkout_amount_dhs(option.amount.toInt())}',
              style: TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyMedium,
                fontWeight: active
                    ? DSFontWeight.semiBold
                    : DSFontWeight.regular,
                color: active ? DSColor.primary : DSColor.onSurface75,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final Address? address;
  final bool canChange;
  final VoidCallback onChange;
  final VoidCallback onAdd;

  const _DeliveryCard({
    required this.address,
    required this.canChange,
    required this.onChange,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DSColor.card,
        borderRadius: BorderRadius.circular(DSBorderRadius.card),
        border: Border.all(color: DSColor.onSurface07, width: 0.5),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.location_on_outlined,
            size: 20,
            color: DSColor.onSurface60,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: address == null
                ? Text(
                    context.l10N.checkout_add_address,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyLarge,
                      color: DSColor.onSurface60,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        address!.recipientName ?? address!.title,
                        style: const TextStyle(
                          fontFamily: dsFontFamily,
                          fontSize: DSFontSize.bodyLarge,
                          fontWeight: DSFontWeight.semiBold,
                          color: DSColor.onSurface,
                        ),
                      ),
                      Text(
                        address!.summary,
                        style: const TextStyle(
                          fontFamily: dsFontFamily,
                          fontSize: DSFontSize.bodyMedium,
                          color: DSColor.onSurface60,
                        ),
                      ),
                    ],
                  ),
          ),
          TextButton(
            onPressed: address == null ? onAdd : (canChange ? onChange : onAdd),
            child: Text(
              address == null
                  ? context.l10N.checkout_add
                  : context.l10N.checkout_change,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyMedium,
                fontWeight: DSFontWeight.medium,
                color: DSColor.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderPlaced extends StatelessWidget {
  const _OrderPlaced();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 92,
                        height: 92,
                        decoration: const BoxDecoration(
                          color: DSColor.primary,
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(color: Color(0x66E0CE7D), blurRadius: 50),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 46,
                          color: DSColor.surface,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        context.l10N.checkout_order_placed_title,
                        style: const TextStyle(
                          fontFamily: dsFontFamily,
                          fontSize: 28,
                          fontWeight: DSFontWeight.bold,
                          letterSpacing: -0.56,
                          color: DSColor.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        context.l10N.checkout_order_placed_escrow_message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: dsFontFamily,
                          fontSize: DSFontSize.bodyLarge,
                          height: 1.5,
                          color: DSColor.onSurface60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            DSBottomBar(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DSButtonElevated(
                    text: context.l10N.checkout_track_order,
                    onPressed: () => context.router.replaceAll(
                      const <PageRouteInfo>[ShellRoute(), OrdersRoute()],
                    ),
                  ),
                  const SizedBox(height: 10),
                  DSButtonOutline(
                    text: context.l10N.checkout_continue_shopping,
                    onPressed: () => context.router.replaceAll(
                      const <PageRouteInfo>[ShellRoute()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
