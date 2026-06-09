import 'package:equatable/equatable.dart';

/// AI-suggested listing fields from `POST /v1/sell/analyze`. Any field may be
/// null (analysis is best-effort; failure is silent).
class SellDraft extends Equatable {
  final String? title;
  final String? description;
  final num? price;
  final String? categoryId;
  final String? brandId;
  final String? size;
  final String? conditionId;

  const SellDraft({
    this.title,
    this.description,
    this.price,
    this.categoryId,
    this.brandId,
    this.size,
    this.conditionId,
  });

  static const SellDraft empty = SellDraft();

  @override
  List<Object?> get props => [
    title,
    description,
    price,
    categoryId,
    brandId,
    size,
    conditionId,
  ];
}
