import 'package:equatable/equatable.dart';

/// A catalog category node. [hasChildren] drives the filters drill-down.
/// [imageUrl] is the (absolute) tile image set admin-side; null when unset,
/// in which case the browse UI falls back to a gradient.
class CatalogCategory extends Equatable {
  final String id;
  final String label;
  final bool hasChildren;
  final String? imageUrl;

  const CatalogCategory({
    required this.id,
    required this.label,
    this.hasChildren = false,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, label, hasChildren, imageUrl];
}
