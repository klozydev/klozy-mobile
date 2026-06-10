import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/core/account/account_gate.dart';
import 'package:klozy/src/design/components/ds_glass_button.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';

/// Wishlist heart button for the product page overlay.
///
/// Gated by [AccountGate]: guest/legacy users see the sign-up sheet instead
/// of toggling the wishlist directly.
class ProductHeartButtonWidget extends StatelessWidget {
  final ProductDetail detail;

  const ProductHeartButtonWidget({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final bool liked = context.select<WishlistCubit, bool>(
      (WishlistCubit c) => c.state.contains(detail.id),
    );
    return DSGlassButton(
      onTap: () => locator<AccountGate>().guard(
        context,
        onAllowed: () => context.read<WishlistCubit>().toggle(detail.id),
      ),
      child: Icon(
        liked ? Icons.favorite : Icons.favorite_border,
        size: 18,
        color: liked ? DSColor.danger : Colors.white,
      ),
    );
  }
}
