import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/domain/product/entity/create_product_input.dart';
import 'package:klozy/src/feature/sell/domain/entity/sell_draft_field.dart';
import 'package:klozy/src/feature/sell/domain/entity/size_system.dart';

@immutable
sealed class SellEvent extends Equatable {
  const SellEvent();

  @override
  List<Object?> get props => [];
}

final class SellStarted extends SellEvent {
  const SellStarted();
}

final class SellPhotosUpdated extends SellEvent {
  final List<String> paths;

  const SellPhotosUpdated(this.paths);

  @override
  List<Object?> get props => [paths];
}

final class SellAnalyzeRequested extends SellEvent {
  final List<String> paths;

  const SellAnalyzeRequested(this.paths);

  @override
  List<Object?> get props => [paths];
}

/// User tapped "edit photos" on the recap — return to the picker step with the
/// already-chosen photos so they can add/replace images instead of leaving.
final class SellEditPhotosRequested extends SellEvent {
  const SellEditPhotosRequested();
}

final class SellSizeSystemToggled extends SellEvent {
  final SizeSystem system;

  const SellSizeSystemToggled(this.system);

  @override
  List<Object?> get props => [system];
}

/// Fired when the user manually edits a field that was previously AI-filled.
/// The BLoC removes [field] from [SellRecapState.aiFilled].
final class SellDraftFieldEdited extends SellEvent {
  final SellDraftField field;

  const SellDraftFieldEdited(this.field);

  @override
  List<Object?> get props => [field];
}

final class SellProductSubmitted extends SellEvent {
  final CreateProductInput input;

  const SellProductSubmitted(this.input);

  @override
  List<Object?> get props => [
    input.title,
    input.price,
    input.categoryId,
    input.conditionId,
  ];
}
