import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/domain/notifications/entity/notification_type.dart';

typedef NotificationVisual = ({IconData icon, Color color});

const Color _gold = DSColor.primary;
const Color _mint = Color(0xFFA7D2BE);
const Color _orange = Color(0xFFE0A24D);
const Color _lavender = Color(0xFFC3BCEA);

/// Icon + accent colour per notification type (mirrors the prototype).
NotificationVisual visualFor(NotificationType type) {
  return switch (type) {
    NotificationType.newReview => (icon: Icons.favorite_border, color: _gold),
    NotificationType.offerAccepted => (
      icon: Icons.local_offer_outlined,
      color: _mint,
    ),
    NotificationType.offerRefused => (
      icon: Icons.local_offer_outlined,
      color: DSColor.onSurface45,
    ),
    NotificationType.newOffer => (
      icon: Icons.local_offer_outlined,
      color: _gold,
    ),
    NotificationType.inDelivery => (
      icon: Icons.local_shipping_outlined,
      color: _gold,
    ),
    NotificationType.delivered => (
      icon: Icons.inventory_2_outlined,
      color: _mint,
    ),
    NotificationType.newOrder => (
      icon: Icons.shopping_bag_outlined,
      color: _mint,
    ),
    NotificationType.shippingReminder => (
      icon: Icons.local_shipping_outlined,
      color: _orange,
    ),
    NotificationType.newFollower => (
      icon: Icons.person_outline,
      color: _lavender,
    ),
    NotificationType.priceDrop => (icon: Icons.trending_down, color: _gold),
    NotificationType.unknown => (
      icon: Icons.notifications_none_rounded,
      color: DSColor.onSurface60,
    ),
  };
}
