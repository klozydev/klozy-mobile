/// The 10 in-app notification types (+ unknown fallback).
enum NotificationType {
  newReview,
  offerAccepted,
  offerRefused,
  newOffer,
  inDelivery,
  delivered,
  newOrder,
  shippingReminder,
  newFollower,
  priceDrop,
  unknown;

  static NotificationType fromApi(String? raw) {
    switch ((raw ?? '').toLowerCase().replaceAll(RegExp('[_-]'), '')) {
      case 'newreview':
        return NotificationType.newReview;
      case 'offeraccepted':
        return NotificationType.offerAccepted;
      case 'offerrefused':
      case 'offerdeclined':
        return NotificationType.offerRefused;
      case 'newoffer':
        return NotificationType.newOffer;
      case 'indelivery':
        return NotificationType.inDelivery;
      case 'delivered':
        return NotificationType.delivered;
      case 'neworder':
        return NotificationType.newOrder;
      case 'shippingreminder':
        return NotificationType.shippingReminder;
      case 'newfollower':
        return NotificationType.newFollower;
      case 'pricedrop':
        return NotificationType.priceDrop;
      default:
        return NotificationType.unknown;
    }
  }
}
