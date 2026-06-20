import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/feature/search/presentation/widget/filter_section_label_widget.dart';

/// Price range section of the search filters sheet. The bounds [min]/[max] come
/// from the backend facets of the current result set; the section renders
/// nothing when no usable range is available (browse mode or a single-price
/// set). [low]/[high] are the current thumb positions.
class PriceRangeSectionWidget extends StatelessWidget {
  final double? min;
  final double? max;
  final double? low;
  final double? high;
  final ValueChanged<RangeValues> onChanged;

  const PriceRangeSectionWidget({
    super.key,
    required this.min,
    required this.max,
    required this.low,
    required this.high,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final double? lo = min;
    final double? hi = max;
    if (lo == null || hi == null || hi <= lo || low == null || high == null) {
      return const SizedBox.shrink();
    }
    // One division per Dhs, capped so very wide ranges stay performant.
    final int span = (hi - lo).round();
    final int divisions = span <= 0 ? 1 : (span > 200 ? 200 : span);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FilterSectionLabelWidget(text: context.l10N.search_filter_price),
            Text(
              context.l10N.search_price_chip(low!.round(), high!.round()),
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyMedium,
                fontWeight: DSFontWeight.semiBold,
                color: DSColor.primary,
              ),
            ),
          ],
        ),
        RangeSlider(
          min: lo,
          max: hi,
          divisions: divisions,
          values: RangeValues(low!.clamp(lo, hi), high!.clamp(lo, hi)),
          activeColor: DSColor.primary,
          inactiveColor: DSColor.onSurface15,
          labels: RangeLabels(
            context.l10N.product_price_amount(low!.round()),
            context.l10N.product_price_amount(high!.round()),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
