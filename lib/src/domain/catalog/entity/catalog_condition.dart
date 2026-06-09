import 'package:equatable/equatable.dart';

/// An item condition facet (e.g. slug `veryGood`, label "Very good").
class CatalogCondition extends Equatable {
  final String slug;
  final String label;

  const CatalogCondition({required this.slug, required this.label});

  @override
  List<Object?> get props => [slug, label];
}
