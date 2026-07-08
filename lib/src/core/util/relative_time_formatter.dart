import 'package:flutter/widgets.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';

/// Shared, localized relative-time formatter.
///
/// Data-layer mappers must NOT format times into English strings. Instead they
/// carry a raw [DateTime] on the entity (e.g. `ProductDetail.postedAt`,
/// `Order.createdAt`) and the UI calls [format] to render a localized label.
///
/// Localization contract (l10n keys already defined in `app_en.arb`):
///   - < 1 minute  -> `common_time_just_now`      ("Just now")
///   - < 1 hour    -> `common_time_minutes_ago`   (ICU plural on {count})
///   - < 1 day     -> `common_time_hours_ago`     (ICU plural on {count})
///   - >= 1 day    -> `common_time_days_ago`      (ICU plural on {count})
abstract final class RelativeTimeFormatter {
  /// Returns a localized relative-time label for [dateTime] relative to now.
  ///
  /// Implementation (ui-dev): compute `DateTime.now().difference(dateTime)` and
  /// select the matching `common_time_*` key via `context.l10N`. Keep the
  /// threshold logic identical to the former mapper logic (days > hours >
  /// minutes > just now).
  static String format(BuildContext context, DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);

    if (diff.inDays >= 1) {
      return context.l10N.common_time_days_ago(diff.inDays);
    }
    if (diff.inHours >= 1) {
      return context.l10N.common_time_hours_ago(diff.inHours);
    }
    if (diff.inMinutes >= 1) {
      return context.l10N.common_time_minutes_ago(diff.inMinutes);
    }
    return context.l10N.common_time_just_now;
  }
}
