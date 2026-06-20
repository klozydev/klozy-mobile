import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/util/app_share.dart';
import 'package:klozy/src/design/components/ds_glass_button.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_heart_button_widget.dart';

/// Top controls over the hero photo: back, wishlist heart (buyer only), share.
/// Matches the last design — no overflow menu here; owner actions live in the
/// CTA-bar trash menu and buyer report is an inline link in the details panel.
class ProductTopBarWidget extends StatelessWidget {
  final ProductDetail detail;

  const ProductTopBarWidget({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.xs,
          vertical: DSSpacing.xxxs,
        ),
        child: Row(
          children: <Widget>[
            DSGlassButton(
              onTap: () => context.router.maybePop(),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            if (!detail.isOwner) ...<Widget>[
              ProductHeartButtonWidget(detail: detail),
              const SizedBox(width: DSSpacing.xxs),
            ],
            DSGlassButton(
              onTap: () => AppShare.product(detail.id, title: detail.title),
              child: const Icon(
                Icons.ios_share_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
