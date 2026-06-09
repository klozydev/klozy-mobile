import 'package:equatable/equatable.dart';

/// A size facet token (e.g. token "M" or "EU 42", with a display label).
class CatalogSizeValue extends Equatable {
  final String token;
  final String label;

  const CatalogSizeValue({required this.token, required this.label});

  @override
  List<Object?> get props => [token, label];
}
