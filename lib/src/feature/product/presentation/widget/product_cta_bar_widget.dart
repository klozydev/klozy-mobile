import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';

/// Bottom action bar — buyer (add-to-cart + make-offer / in-cart), owner (edit + delete), or
/// a disabled state when sold/reserved.
class ProductCtaBarWidget extends StatelessWidget {
  final ProductDetail detail;
  final bool inCart;
  final VoidCallback onAddToCart;
  final VoidCallback onViewCart;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMakeOffer;
  final VoidCallback onSeeOffer;

  /// Shows a spinner on the make-offer button while an offer is submitting
  /// (add-to-cart + POST /v1/offers + open chat can take a moment).
  final bool offerLoading;

  const ProductCtaBarWidget({
    super.key,
    required this.detail,
    required this.inCart,
    required this.onAddToCart,
    required this.onViewCart,
    required this.onEdit,
    required this.onDelete,
    required this.onMakeOffer,
    required this.onSeeOffer,
    this.offerLoading = false,
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
      return Row(
        children: <Widget>[
          Expanded(
            child: DSButtonElevated(
              text: context.l10N.product_edit_listing,
              onPressed: onEdit,
            ),
          ),
          const SizedBox(width: DSSpacing.xs),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: DSColor.onSurface07,
                borderRadius: BorderRadius.circular(DSBorderRadius.input),
                border: Border.all(color: DSColor.onSurface15, width: 0.5),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: DSColor.destructive,
              ),
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
    return Row(
      children: <Widget>[
        Expanded(
          child: DSButtonElevated(
            text: context.l10N.product_buy,
            onPressed: onAddToCart,
          ),
        ),
        const SizedBox(width: DSSpacing.xs),
        Expanded(
          child: offerLoading
              ? _glassLoading()
              : detail.hasActiveOffer
              ? _glass(
                  context.l10N.product_see_offer,
                  Icons.local_offer,
                  onSeeOffer,
                )
              : _glass(
                  context.l10N.product_make_offer,
                  Icons.local_offer_outlined,
                  onMakeOffer,
                ),
        ),
      ],
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

  Widget _glassLoading() {
    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xB81A1A1A),
        borderRadius: BorderRadius.circular(DSBorderRadius.input),
        border: Border.all(color: DSColor.onSurface24, width: 0.5),
      ),
      child: const SizedBox(
        width: 20,
        height: 20,
        child: DSLoader(size: 18, color: DSColor.onSurface),
      ),
    );
  }

  Widget _glass(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xB81A1A1A),
          borderRadius: BorderRadius.circular(DSBorderRadius.input),
          border: Border.all(color: DSColor.onSurface24, width: 0.5),
        ),
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
