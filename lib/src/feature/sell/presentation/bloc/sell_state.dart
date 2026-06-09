import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_condition.dart';
import 'package:klozy/src/domain/sell/entity/sell_draft.dart';

@immutable
sealed class SellState extends Equatable {
  const SellState();

  @override
  List<Object?> get props => [];
}

final class SellPhotosState extends SellState {
  final List<String> paths;

  const SellPhotosState(this.paths);

  @override
  List<Object?> get props => [paths];
}

final class SellAnalyzingState extends SellState {
  const SellAnalyzingState();
}

final class SellErrorState extends SellState {
  final AppErrorType type;

  const SellErrorState({required this.type});

  @override
  List<Object?> get props => [type];
}

final class SellRecapState extends SellState {
  final SellDraft draft;
  final List<CatalogCategory> rootCategories;
  final List<CatalogCondition> conditions;
  final List<String> imageUrls;
  final bool isCreating;
  final String? submitError;

  const SellRecapState({
    required this.draft,
    required this.rootCategories,
    required this.conditions,
    required this.imageUrls,
    this.isCreating = false,
    this.submitError,
  });

  SellRecapState copyWith({bool? isCreating, String? submitError}) {
    return SellRecapState(
      draft: draft,
      rootCategories: rootCategories,
      conditions: conditions,
      imageUrls: imageUrls,
      isCreating: isCreating ?? this.isCreating,
      submitError: submitError,
    );
  }

  @override
  List<Object?> get props => [
    draft,
    rootCategories,
    conditions,
    imageUrls,
    isCreating,
    submitError,
  ];
}

final class SellDoneState extends SellState {
  final String productId;

  const SellDoneState(this.productId);

  @override
  List<Object?> get props => [productId];
}
