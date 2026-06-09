import 'package:equatable/equatable.dart';

/// A catalog brand (searchable in onboarding personalize).
class CatalogBrand extends Equatable {
  final String id;
  final String name;

  const CatalogBrand({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
