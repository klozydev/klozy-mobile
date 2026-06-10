import 'package:equatable/equatable.dart';

/// A comment on a reel.
class ReelComment extends Equatable {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String body;
  final DateTime? createdAt;

  const ReelComment({
    required this.id,
    required this.body,
    this.authorId = '',
    this.authorName = '',
    this.authorAvatar,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    authorId,
    authorName,
    authorAvatar,
    body,
    createdAt,
  ];
}
