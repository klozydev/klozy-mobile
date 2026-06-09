import 'package:equatable/equatable.dart';

/// A single seller metric (label + display value).
class SellerStat extends Equatable {
  final String label;
  final String value;

  const SellerStat({required this.label, required this.value});

  @override
  List<Object?> get props => [label, value];
}

class SellerStats extends Equatable {
  final List<SellerStat> entries;

  const SellerStats({this.entries = const <SellerStat>[]});

  @override
  List<Object?> get props => [entries];
}
