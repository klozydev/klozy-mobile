import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/util/relative_time_formatter.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';

/// Owner-only stats row on the product detail — Views · Likes · Posted, above a
/// hairline top border (design: shown only when the viewer owns the listing).
class ProductOwnerStatsWidget extends StatelessWidget {
  final ProductDetail detail;

  const ProductOwnerStatsWidget({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final String postedValue = detail.postedLabel != null
        ? detail.postedLabel!
        : detail.postedAt != null
        ? RelativeTimeFormatter.format(context, detail.postedAt!)
        : '—';
    final List<(String, String)> stats = <(String, String)>[
      (context.l10N.product_stat_views, '${detail.views}'),
      (context.l10N.product_stat_likes, '${detail.likes}'),
      (context.l10N.product_stat_posted, postedValue),
    ];
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: DSColor.onSurface10, width: 0.5)),
      ),
      child: Row(
        children: <Widget>[
          for (final (String label, String value) in stats)
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodySmall,
                      color: DSColor.onSurface35,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyMedium,
                      fontWeight: DSFontWeight.semiBold,
                      color: DSColor.onSurface85,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
