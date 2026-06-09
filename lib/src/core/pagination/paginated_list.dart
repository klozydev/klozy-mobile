import 'package:equatable/equatable.dart';

class PaginatedList<T> extends Equatable {
  final List<T> data;
  final Map<String, dynamic>? metadata;

  const PaginatedList({required this.data, this.metadata});

  @override
  List<Object?> get props => [data, metadata];
}
