import 'package:equatable/equatable.dart';

/// A catalog category node. [hasChildren] drives the filters drill-down.
class CatalogCategory extends Equatable {
  final String id;
  final String label;
  final bool hasChildren;

  const CatalogCategory({
    required this.id,
    required this.label,
    this.hasChildren = false,
  });

  @override
  List<Object?> get props => [id, label, hasChildren];
}
