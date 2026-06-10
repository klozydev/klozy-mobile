import 'package:core_kosmos/core_kosmos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

enum TchatingStatus {
  offline,
  online,
  multipleOnline,
  typing,
  audioRec;

  String? getStatusEvent() {
    switch (this) {
      case TchatingStatus.offline:
        return null;
      case TchatingStatus.online:
        return null;
      case TchatingStatus.typing:
        return "package.tchat.status.typing";
      case TchatingStatus.audioRec:
        return "package.tchat.status.audioRec";
      case TchatingStatus.multipleOnline:
        return null;
    }
  }

  String? getStatusTchatEvent() {
    switch (this) {
      case TchatingStatus.typing:
        return "package.tchat.status.typing";
      case TchatingStatus.audioRec:
        return "package.tchat.status.audioRec";
      case TchatingStatus.online:
        return "package.tchat.status.online";
      case TchatingStatus.offline:
        return null;
      case TchatingStatus.multipleOnline:
        return "package.tchat.status.multiple-online";
    }
  }
}

String chatStatus(DateTime date) {
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = today.subtract(const Duration(days: 1));
  DateTime inputDate = DateTime(date.year, date.month, date.day);

  // Formatter for time
  var timeFormatter = DateFormat('HH:mm');

  // Formatter for date
  // var dateFormatter = DateFormat('dd/MM/yyyy');

  if (inputDate == today) {
    // If the date is today
    return "package.tchat.online-today-at".tr(args: [
      timeFormatter.format(date),
      // "date.locale-format".tr(
      //   namedArgs: {
      //     "day": date.day.toString().padLeft(2, "0"),
      //     "month": date.month.toString().padLeft(2, "0"),
      //     "year": date.year.toString(),
      //   },
      // )
    ]);
  } else if (inputDate == yesterday) {
    // If the date is yesterday
    return "package.tchat.online-yesterday-at".tr(args: [
      timeFormatter.format(date),
    ]);
  } else {
    // For any other date
    return "package.tchat.online-at".tr(args: [
      "date.locale-format".tr(namedArgs: {
        "day": date.day.toString().padLeft(2, "0"),
        "month": date.month.toString().padLeft(2, "0"),
        "year": date.year.toString(),
      })
    ]);
  }
}

abstract class StatusController {
  static Future<void> setStatus(String tchatId, TchatingStatus status) async {
    FirebaseDatabase.instance.ref("tchat/status/$tchatId").update({
      FirebaseAuth.instance.currentUser!.uid: {
        "status": enumToString(status),
        "lastUpdate": DateTime.now().toUtc().millisecondsSinceEpoch,
      },
    });
  }
}
