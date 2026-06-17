import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_condition.dart';
import 'package:klozy/src/domain/sell/entity/sell_draft.dart';
import 'package:klozy/src/feature/sell/domain/entity/sell_draft_field.dart';
import 'package:klozy/src/feature/sell/domain/entity/size_system.dart';

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

  /// The original local file paths, kept so "edit photos" can return to the
  /// picker pre-populated instead of dropping the user out of the flow.
  final List<String> paths;

  /// Fields populated by the AI analysis — drive the sparkle badge.
  final Set<SellDraftField> aiFilled;

  /// EU / US size system selected for the size field.
  final SizeSystem sizeSystem;
  final bool isCreating;
  final String? submitError;

  const SellRecapState({
    required this.draft,
    required this.rootCategories,
    required this.conditions,
    required this.imageUrls,
    this.paths = const <String>[],
    this.aiFilled = const <SellDraftField>{},
    this.sizeSystem = SizeSystem.eu,
    this.isCreating = false,
    this.submitError,
  });

  SellRecapState copyWith({
    SellDraft? draft,
    Set<SellDraftField>? aiFilled,
    SizeSystem? sizeSystem,
    bool? isCreating,
    String? submitError,
  }) {
    return SellRecapState(
      draft: draft ?? this.draft,
      rootCategories: rootCategories,
      conditions: conditions,
      imageUrls: imageUrls,
      paths: paths,
      aiFilled: aiFilled ?? this.aiFilled,
      sizeSystem: sizeSystem ?? this.sizeSystem,
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
    paths,
    aiFilled,
    sizeSystem,
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
