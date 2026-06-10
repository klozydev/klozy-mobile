import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/util/app_share.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_glass_button.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/feature/product/presentation/bloc/product_bloc.dart';
import 'package:klozy/src/feature/product/presentation/bloc/product_event.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_menu_sheet.dart';
import 'package:klozy/src/router/app_router.dart';

class ProductTopBarWidget extends StatelessWidget {
  final ProductDetail detail;

  const ProductTopBarWidget({super.key, required this.detail});

  Future<void> _openMenu(BuildContext context) {
    final bloc = context.read<ProductBloc>();
    return DSBottomSheet.show<void>(
      context,
      child: ProductMenuSheet(
        isOwner: detail.isOwner,
        isSold: detail.status == ProductStatus.sold,
        onEdit: () {
          Navigator.of(context).maybePop();
          context.router.push(EditListingRoute(productId: detail.id));
        },
        onToggleSold: () {
          Navigator.of(context).maybePop();
          bloc.add(
            ProductMarkStatus(
              detail.status == ProductStatus.sold
                  ? ProductStatus.active
                  : ProductStatus.sold,
            ),
          );
        },
        onDelete: () {
          Navigator.of(context).maybePop();
          bloc.add(const ProductDeleted());
        },
        onReport: () {
          Navigator.of(context).maybePop();
          bloc.add(const ProductReported());
          context.showSnackBar(context.l10N.product_report_received);
        },
      ),
    );
  }

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
            DSGlassButton(
              onTap: () => _openMenu(context),
              child: const Icon(
                Icons.more_horiz,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: DSSpacing.xxs),
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
