import 'package:intl/intl.dart';

/// Formats message / thread timestamps into the short labels the design uses:
/// `now` (<1 min), `HH:mm` (today), `Yesterday`, weekday (`Mon`, this week),
/// else `dd/MM/yy`.
abstract final class ChatTimeFormatter {
  static String label(DateTime? time, {DateTime? now}) {
    if (time == null) return '';
    final DateTime ref = now ?? DateTime.now();
    final Duration diff = ref.difference(time);

    if (diff.inSeconds < 60 && diff.inSeconds >= 0) return 'now';

    final DateTime day = DateTime(time.year, time.month, time.day);
    final DateTime today = DateTime(ref.year, ref.month, ref.day);
    final int dayDiff = today.difference(day).inDays;

    if (dayDiff <= 0) return DateFormat.Hm().format(time); // 14:05
    if (dayDiff == 1) return 'Yesterday';
    if (dayDiff < 7) return DateFormat.E().format(time); // Mon
    return DateFormat('dd/MM/yy').format(time);
  }
}
