import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/cart/entity/cart_bucket.dart';
import 'package:klozy/src/feature/cart/presentation/bloc/cart_bloc.dart';
import 'package:klozy/src/feature/cart/presentation/bloc/cart_event.dart';
import 'package:klozy/src/feature/cart/presentation/bloc/cart_state.dart';
import 'package:klozy/src/feature/cart/presentation/widget/cart_bucket_card_widget.dart';
import 'package:klozy/src/feature/cart/presentation/widget/offer_sheet.dart';
import 'package:klozy/src/feature/chat/entry/chat_launcher.dart';
import 'package:klozy/src/router/app_router.dart';

@RoutePage()
class CartPage extends StatelessWidget implements AutoRouteWrapper {
  const CartPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<CartBloc>(
      create: (_) => locator<CartBloc>()..add(const CartStarted()),
      child: this,
    );
  }

  Future<void> _makeOffer(BuildContext context, CartBucket bucket) async {
    final amount = await DSBottomSheet.show<num>(
      context,
      title: context.l10N.cart_make_an_offer,
      child: OfferSheet(
        subtotal: bucket.subtotal,
        itemCount: bucket.items.length,
      ),
    );
    if (amount != null && context.mounted) {
      context.read<CartBloc>().add(
        CartOfferMade(sellerId: bucket.sellerId, amount: amount),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(context.l10N.cart_title),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (BuildContext context, CartState state) {
          return switch (state) {
            CartLoadingState() => const DSLoader(),
            CartErrorState(:final type) => AppErrorWidget(
              type: type,
              onRetry: () => context.read<CartBloc>().add(const CartStarted()),
            ),
            CartLoadedState(:final cart) =>
              cart.isEmpty
                  ? const _Empty()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            context.l10N.cart_sellers_summary(
                              cart.buckets.length,
                            ),
                            style: const TextStyle(
                              fontFamily: dsFontFamily,
                              fontSize: DSFontSize.bodyMedium,
                              color: DSColor.onSurface60,
                            ),
                          ),
                        ),
                        ...cart.buckets.map(
                          (CartBucket b) => CartBucketCardWidget(
                            bucket: b,
                            onRemoveItem: (String id) => context
                                .read<CartBloc>()
                                .add(CartItemRemoved(id)),
                            onMakeOffer: () => _makeOffer(context, b),
                            onCancelOffer: () {
                              if (b.offerId != null) {
                                context.read<CartBloc>().add(
                                  CartOfferCancelled(b.offerId!),
                                );
                              }
                            },
                            onCheckout: () => context.router.push(
                              CheckoutRoute(sellerId: b.sellerId),
                            ),
                            onMessageSeller: () =>
                                context.openChatWith(b.sellerId),
                          ),
                        ),
                      ],
                    ),
          };
        },
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.shopping_bag_outlined,
            size: 40,
            color: DSColor.onSurface35,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10N.cart_empty_title,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodyLarge,
              fontWeight: DSFontWeight.medium,
              color: DSColor.onSurface60,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10N.cart_empty_subtitle,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodyMedium,
              color: DSColor.onSurface45,
            ),
          ),
        ],
      ),
    );
  }
}
