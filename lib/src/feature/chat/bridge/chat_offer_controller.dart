import 'package:cloud_functions/cloud_functions.dart';

/// Chat-offer backend = the shared Firebase project's cloud functions, keyed by
/// (tchatId, messageId). This is NOT mobile's REST `/v1/offers/{id}` — different
/// IDs/backends — so accept/refuse stays on the Firebase callable to keep the
/// copied offer bubbles behaving identically.
class ChatOfferController {
  const ChatOfferController();

  Future<void> handleOffer(
    bool accepted,
    String tchatId,
    String messageId,
  ) async {
    final callable = FirebaseFunctions.instance.httpsCallable('handleOffer');
    await callable.call(<String, dynamic>{
      'tchatId': tchatId,
      'messageId': messageId,
      'accepted': accepted,
    });
  }

  Future<void> cancelOffer({
    required String tchatId,
    required String messageId,
    String? orderId,
  }) async {
    final callable = FirebaseFunctions.instance.httpsCallable('cancelOffer');
    await callable.call(<String, dynamic>{
      'tchatId': tchatId,
      'messageId': messageId,
      if (orderId != null) 'orderId': orderId,
    });
  }
}
