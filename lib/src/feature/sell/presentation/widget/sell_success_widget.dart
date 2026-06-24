import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/router/app_router.dart';

class SellSuccessWidget extends StatelessWidget {
  final String productId;

  const SellSuccessWidget({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
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
                      context.l10N.sell_youre_live,
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
                      context.l10N.sell_item_visible_to_buyers,
                      style: const TextStyle(
                        fontFamily: dsFontFamily,
                        fontSize: DSFontSize.bodyLarge,
                        color: DSColor.onSurface60,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            DSBottomBar(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DSButtonElevated(
                    text: context.l10N.sell_view_listing,
                    isEnable: productId.isNotEmpty,
                    onPressed: () =>
                        context.router.replace(ProductRoute(id: productId)),
                  ),
                  const SizedBox(height: 10),
                  // Quick path into the reel composer with this product
                  // pre-tagged (a reel requires at least one tagged product).
                  DSButtonOutline(
                    text: context.l10N.sell_create_reel,
                    onPressed: () => context.router.replace(
                      ReelComposerRoute(initialProductId: productId),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DSButtonOutline(
                    text: context.l10N.sell_back_to_home,
                    onPressed: () => context.router.maybePop(),
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
