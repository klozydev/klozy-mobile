import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/notifications/entity/notification_type.dart';

void main() {
  group('NotificationType.fromApi', () {
    test('parses newreview (with underscore/dash variants)', () {
      expect(NotificationType.fromApi('newReview'), NotificationType.newReview);
      expect(
        NotificationType.fromApi('new_review'),
        NotificationType.newReview,
      );
      expect(
        NotificationType.fromApi('new-review'),
        NotificationType.newReview,
      );
    });

    test('parses offerAccepted', () {
      expect(
        NotificationType.fromApi('offerAccepted'),
        NotificationType.offerAccepted,
      );
      expect(
        NotificationType.fromApi('OFFERACCEPTED'),
        NotificationType.offerAccepted,
      );
    });

    test('parses offerRefused and offerDeclined', () {
      expect(
        NotificationType.fromApi('offerRefused'),
        NotificationType.offerRefused,
      );
      expect(
        NotificationType.fromApi('offerDeclined'),
        NotificationType.offerRefused,
      );
    });

    test('parses newOffer', () {
      expect(NotificationType.fromApi('newOffer'), NotificationType.newOffer);
      expect(NotificationType.fromApi('new_offer'), NotificationType.newOffer);
    });

    test('parses inDelivery', () {
      expect(
        NotificationType.fromApi('inDelivery'),
        NotificationType.inDelivery,
      );
      expect(
        NotificationType.fromApi('in_delivery'),
        NotificationType.inDelivery,
      );
    });

    test('parses delivered', () {
      expect(NotificationType.fromApi('delivered'), NotificationType.delivered);
    });

    test('parses newOrder', () {
      expect(NotificationType.fromApi('newOrder'), NotificationType.newOrder);
      expect(NotificationType.fromApi('new_order'), NotificationType.newOrder);
    });

    test('parses shippingReminder', () {
      expect(
        NotificationType.fromApi('shippingReminder'),
        NotificationType.shippingReminder,
      );
    });

    test('parses newFollower', () {
      expect(
        NotificationType.fromApi('newFollower'),
        NotificationType.newFollower,
      );
      expect(
        NotificationType.fromApi('new_follower'),
        NotificationType.newFollower,
      );
    });

    test('parses priceDrop', () {
      expect(NotificationType.fromApi('priceDrop'), NotificationType.priceDrop);
      expect(
        NotificationType.fromApi('price_drop'),
        NotificationType.priceDrop,
      );
    });

    test('returns unknown for null', () {
      expect(NotificationType.fromApi(null), NotificationType.unknown);
    });

    test('returns unknown for unrecognised string', () {
      expect(
        NotificationType.fromApi('totally_unknown'),
        NotificationType.unknown,
      );
    });
  });
}
