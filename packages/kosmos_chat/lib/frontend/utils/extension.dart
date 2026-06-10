import 'package:core_kosmos/core_kosmos.dart';

extension TchatDuration on Duration {
  String formatWithDate() {
    if (inSeconds < 30) {
      return "package.duration.now".tr();
    } else if (inMinutes < 1) {
      return "${inSeconds}s";
    } else if (inMinutes < 60) {
      return "${inMinutes}min";
    } else if (inHours < 24) {
      return "${inHours}h";
    } else if (inDays < 2) {
      return "package.duration.yesterday".tr();
    }

    return "package.duration.moment-ago".tr();
  }
}
