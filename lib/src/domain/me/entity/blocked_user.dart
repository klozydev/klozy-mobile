import 'package:equatable/equatable.dart';

class BlockedUser extends Equatable {
  final String id;
  final String displayName;
  final String? avatarUrl;

  const BlockedUser({required this.id, this.displayName = '', this.avatarUrl});

  String get name => displayName;

  @override
  List<Object?> get props => [id, displayName, avatarUrl];
}
