import 'package:equatable/equatable.dart';

class ReelAuthor extends Equatable {
  final String id;
  final String displayName;
  final String? handle;
  final String? avatarUrl;
  final bool isPro;

  const ReelAuthor({
    required this.id,
    this.displayName = '',
    this.handle,
    this.avatarUrl,
    this.isPro = false,
  });

  /// What to show in the reel overlay: `@handle` when present, else the
  /// display name. Mirrors the design which leads with the username handle.
  String get label =>
      (handle != null && handle!.isNotEmpty) ? '@$handle' : displayName;

  @override
  List<Object?> get props => [id, displayName, handle, avatarUrl, isPro];
}
