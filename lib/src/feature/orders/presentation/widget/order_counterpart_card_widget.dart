import 'package:flutter/material.dart';
import 'package:klozy/src/design/components/ds_network_image/ds_network_image.dart';
import 'package:klozy/src/design/components/ds_network_image/ds_network_image_shape.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';

class OrderCounterpartCardWidget extends StatelessWidget {
  final ProductSeller party;
  final String roleLabel;
  final VoidCallback onMessage;

  const OrderCounterpartCardWidget({
    super.key,
    required this.party,
    required this.roleLabel,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DSColor.card,
        borderRadius: BorderRadius.circular(DSBorderRadius.card),
        border: Border.all(color: DSColor.onSurface07, width: 0.5),
      ),
      child: Row(
        children: <Widget>[
          DSNetworkImage(
            imageUrl: party.avatarUrl,
            width: 40,
            height: 40,
            shape: DSNetworkImageShape.circle,
            fallback: const SizedBox(
              width: 40,
              height: 40,
              child: ColoredBox(
                color: DSColor.lowBlack,
                child: Center(
                  child: Icon(Icons.person, size: 20, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  roleLabel,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodySmall,
                    color: DSColor.onSurface45,
                  ),
                ),
                Text(
                  party.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          GestureDetector(
            onTap: onMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DSColor.onSurface07,
                shape: BoxShape.circle,
                border: Border.all(color: DSColor.onSurface15, width: 0.5),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 18,
                color: DSColor.onSurface75,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
