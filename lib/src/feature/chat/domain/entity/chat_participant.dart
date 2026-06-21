import 'package:equatable/equatable.dart';

/// A thread participant's display data, read from the thread doc's
/// `metadata.usersData` map (embedded by the backend mirror / [ChatEntry]).
class ChatParticipant extends Equatable {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final double rating;
  final bool isPro;

  const ChatParticipant({
    required this.id,
    this.displayName = '',
    this.avatarUrl,
    this.rating = 0,
    this.isPro = false,
  });

  /// First glyph for the fallback avatar, uppercased.
  String get initial =>
      displayName.trim().isEmpty ? '?' : displayName.trim()[0].toUpperCase();

  static const ChatParticipant unknown = ChatParticipant(
    id: '',
    displayName: '',
  );

  @override
  List<Object?> get props => <Object?>[
    id,
    displayName,
    avatarUrl,
    rating,
    isPro,
  ];
}
