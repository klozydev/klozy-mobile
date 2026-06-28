import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/domain/notifications/entity/notification_type.dart';
import 'package:klozy/src/feature/notifications/presentation/widget/notification_type_visuals.dart';

void main() {
  group('visualFor', () {
    test('newReview returns favorite_border icon with primary gold color', () {
      final v = visualFor(NotificationType.newReview);
      expect(v.icon, Icons.favorite_border);
      expect(v.color, DSColor.primary);
    });

    test('offerAccepted returns local_offer_outlined with mint color', () {
      final v = visualFor(NotificationType.offerAccepted);
      expect(v.icon, Icons.local_offer_outlined);
      expect(v.color, const Color(0xFFA7D2BE));
    });

    test(
      'offerRefused returns local_offer_outlined with onSurface45 color',
      () {
        final v = visualFor(NotificationType.offerRefused);
        expect(v.icon, Icons.local_offer_outlined);
        expect(v.color, DSColor.onSurface45);
      },
    );

    test('newOffer returns local_offer_outlined with primary gold color', () {
      final v = visualFor(NotificationType.newOffer);
      expect(v.icon, Icons.local_offer_outlined);
      expect(v.color, DSColor.primary);
    });

    test(
      'inDelivery returns local_shipping_outlined with primary gold color',
      () {
        final v = visualFor(NotificationType.inDelivery);
        expect(v.icon, Icons.local_shipping_outlined);
        expect(v.color, DSColor.primary);
      },
    );

    test('delivered returns inventory_2_outlined with mint color', () {
      final v = visualFor(NotificationType.delivered);
      expect(v.icon, Icons.inventory_2_outlined);
      expect(v.color, const Color(0xFFA7D2BE));
    });

    test('newOrder returns shopping_bag_outlined with mint color', () {
      final v = visualFor(NotificationType.newOrder);
      expect(v.icon, Icons.shopping_bag_outlined);
      expect(v.color, const Color(0xFFA7D2BE));
    });

    test(
      'shippingReminder returns local_shipping_outlined with orange color',
      () {
        final v = visualFor(NotificationType.shippingReminder);
        expect(v.icon, Icons.local_shipping_outlined);
        expect(v.color, const Color(0xFFE0A24D));
      },
    );

    test('newFollower returns person_outline with lavender color', () {
      final v = visualFor(NotificationType.newFollower);
      expect(v.icon, Icons.person_outline);
      expect(v.color, const Color(0xFFC3BCEA));
    });

    test('priceDrop returns trending_down with primary gold color', () {
      final v = visualFor(NotificationType.priceDrop);
      expect(v.icon, Icons.trending_down);
      expect(v.color, DSColor.primary);
    });

    test(
      'unknown returns notifications_none_rounded with onSurface60 color',
      () {
        final v = visualFor(NotificationType.unknown);
        expect(v.icon, Icons.notifications_none_rounded);
        expect(v.color, DSColor.onSurface60);
      },
    );

    test('every NotificationType has a non-null visual', () {
      for (final type in NotificationType.values) {
        final v = visualFor(type);
        expect(v.icon, isNotNull, reason: '$type icon should not be null');
        expect(v.color, isNotNull, reason: '$type color should not be null');
      }
    });
  });
}
