import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/domain/product/entity/create_product_input.dart';

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
