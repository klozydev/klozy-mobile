import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// The subtle "Picked for you · Women, Men" hint shown above the feed grid on
/// the All tab. [categories] are the preferred category names from the feed
/// response (derived from the user's onboarding preferences).
class FeedPickedForYouWidget extends StatelessWidget {
  final List<String> categories;

  const FeedPickedForYouWidget({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: Row(
        children: <Widget>[
          const Icon(Icons.auto_awesome, size: 15, color: DSColor.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10N.home_picked_for_you(categories.join(', ')),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyMedium,
                color: DSColor.onSurface60,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
