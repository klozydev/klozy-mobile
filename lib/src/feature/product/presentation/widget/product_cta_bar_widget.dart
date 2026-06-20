import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';

/// Bottom action bar.
///
/// Mirrors the last design:
///  • buyer — single Add to cart (offers are made from the cart, not the PDP),
///    an "In cart · View cart" glass button once added, or a disabled label when
///    the listing is sold/reserved.
///  • owner — a danger-outlined trash button that opens the overflow menu
///    (Edit / Mark sold / Delete) plus a primary Edit listing button.
class ProductCtaBarWidget extends StatelessWidget {
  final ProductDetail detail;
  final bool inCart;
  final VoidCallback onAddToCart;
  final VoidCallback onViewCart;
  final VoidCallback onEdit;

  /// Owner trash button — opens the overflow menu (Edit / Mark sold / Delete).
  final VoidCallback onOpenMenu;

  const ProductCtaBarWidget({
    super.key,
    required this.detail,
    required this.inCart,
    required this.onAddToCart,
    required this.onViewCart,
    required this.onEdit,
    required this.onOpenMenu,
  });

  @override
  Widget build(BuildContext context) {
    // Floats over the immersive photo/details: solid surface at the bottom that
    // fades to transparent toward the top (design: gradient "to top, #000 42%").
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: <Color>[DSColor.surface, DSColor.surface, Color(0x00000000)],
          stops: <double>[0.0, 0.42, 1.0],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        DSSpacing.s,
        DSSpacing.xl,
        DSSpacing.s,
        DSSpacing.s + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: _content(context),
    );
  }

  Widget _content(BuildContext context) {
    if (detail.isOwner) {
      // Trash opens the overflow menu (Edit / Mark sold / Delete); Edit is the
      // primary action. Mark-sold lives in the menu, not as a primary button.
      return Row(
        children: <Widget>[
          GestureDetector(
            onTap: onOpenMenu,
            child: Container(
              width: 52,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(DSBorderRadius.input),
                border: Border.all(color: DSColor.danger, width: 1.5),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: DSColor.danger,
              ),
            ),
          ),
          const SizedBox(width: DSSpacing.xs),
          Expanded(
            child: DSButtonElevated(
              text: context.l10N.product_edit_listing,
              icon: Icons.edit_outlined,
              onPressed: onEdit,
            ),
          ),
        ],
      );
    }
    if (detail.isBlocked) {
      return _disabled(
        detail.status == ProductStatus.sold
            ? context.l10N.product_status_sold
            : context.l10N.product_status_reserved,
      );
    }
    if (inCart) {
      return _glass(
        context.l10N.product_in_cart_view_cart,
        Icons.check_rounded,
        onViewCart,
      );
    }
    return DSButtonElevated(
      text: context.l10N.product_add_to_cart,
      icon: Icons.shopping_bag_outlined,
      onPressed: onAddToCart,
    );
  }

  Widget _disabled(String label) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xCC1A1A1A),
        borderRadius: BorderRadius.circular(DSBorderRadius.input),
        border: Border.all(color: DSColor.onSurface10, width: 0.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: dsFontFamily,
          fontSize: DSFontSize.bodyLarge,
          fontWeight: DSFontWeight.semiBold,
          color: DSColor.onSurface24,
        ),
      ),
    );
  }

  Widget _glass(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: _GlassSurface(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 17, color: DSColor.onSurface),
            const SizedBox(width: DSSpacing.xxs),
            Text(
              label,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyLarge,
                fontWeight: DSFontWeight.semiBold,
                color: DSColor.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Backdrop-blurred glass surface for the secondary CTA — matches the design's
/// `BackdropFilter(blur 14)` over a translucent white fill, keeping the bar
/// immersive over the photo instead of a flat opaque block.
class _GlassSurface extends StatelessWidget {
  final Widget child;

  const _GlassSurface({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DSBorderRadius.input),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(DSBorderRadius.input),
            border: Border.all(color: DSColor.onSurface24, width: 0.5),
          ),
          child: child,
        ),
      ),
    );
  }
}
