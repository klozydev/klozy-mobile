import 'package:equatable/equatable.dart';

/// AI-suggested listing fields from `POST /v1/sell/analyze`. Any field may be
/// null (analysis is best-effort; failure is silent).
class SellDraft extends Equatable {
  final String? title;
  final String? description;
  final num? price;
  final String? categoryId;

  /// Display label for [categoryId] (the form shows it without re-resolving
  /// the category tree).
  final String? categoryName;
  final String? brandId;

  /// Display label for [brandId].
  final String? brandName;
  final String? size;
  final String? conditionId;

  /// Raw per-locale `{title, description}` drafts from the AI, passed through
  /// to `POST /v1/products` so listings stay multilingual.
  final Map<String, dynamic>? translations;

  const SellDraft({
    this.title,
    this.description,
    this.price,
    this.categoryId,
    this.categoryName,
    this.brandId,
    this.brandName,
    this.size,
    this.conditionId,
    this.translations,
  });

  static const SellDraft empty = SellDraft();

  @override
  List<Object?> get props => [
    title,
    description,
    price,
    categoryId,
    categoryName,
    brandId,
    brandName,
    size,
    conditionId,
    translations,
  ];
}
