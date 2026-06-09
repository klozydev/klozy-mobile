import 'package:equatable/equatable.dart';

class ReelAuthor extends Equatable {
  final String id;
  final String handle;
  final String? avatarUrl;
  final bool isPro;

  const ReelAuthor({
    required this.id,
    this.handle = '',
    this.avatarUrl,
    this.isPro = false,
  });

  @override
  List<Object?> get props => [id, handle, avatarUrl, isPro];
}
