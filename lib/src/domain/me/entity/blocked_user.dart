import 'package:equatable/equatable.dart';

class BlockedUser extends Equatable {
  final String id;
  final String displayName;
  final String handle;
  final String? avatarUrl;

  const BlockedUser({
    required this.id,
    this.displayName = '',
    this.handle = '',
    this.avatarUrl,
  });

  String get name => displayName.isEmpty ? '@$handle' : displayName;

  @override
  List<Object?> get props => [id, displayName, handle, avatarUrl];
}
