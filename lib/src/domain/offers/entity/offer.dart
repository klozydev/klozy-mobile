import 'package:equatable/equatable.dart';

enum OfferStatus { pending, accepted, declined, cancelled, unknown }

/// An offer on a seller bucket (`/v1/offers`).
class Offer extends Equatable {
  final String id;
  final num amount;
  final OfferStatus status;
  final String counterpartName;
  final String? counterpartAvatar;
  final int itemCount;
  final DateTime? createdAt;

  const Offer({
    required this.id,
    required this.amount,
    this.status = OfferStatus.pending,
    this.counterpartName = '',
    this.counterpartAvatar,
    this.itemCount = 0,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    amount,
    status,
    counterpartName,
    counterpartAvatar,
    itemCount,
    createdAt,
  ];
}
