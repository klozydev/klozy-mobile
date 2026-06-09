import 'package:equatable/equatable.dart';

/// A review left for a seller.
class UserReview extends Equatable {
  final String id;
  final String authorName;
  final String? authorAvatar;
  final double rating;
  final String body;
  final DateTime? createdAt;

  const UserReview({
    required this.id,
    this.authorName = '',
    this.authorAvatar,
    this.rating = 0,
    this.body = '',
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    authorName,
    authorAvatar,
    rating,
    body,
    createdAt,
  ];
}
