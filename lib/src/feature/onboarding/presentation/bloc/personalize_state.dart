import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_brand.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';

@immutable
sealed class PersonalizeState extends Equatable {
  const PersonalizeState();

  @override
  List<Object?> get props => [];
}

final class PersonalizeLoading extends PersonalizeState {
  const PersonalizeLoading();
}

final class PersonalizeFailure extends PersonalizeState {
  final AppErrorType type;

  const PersonalizeFailure(this.type);

  @override
  List<Object?> get props => [type];
}

final class PersonalizeReady extends PersonalizeState {
  final List<CatalogCategory> categories;
  final List<CatalogBrand> brands;
  final bool isSubmitting;

  const PersonalizeReady({
    required this.categories,
    required this.brands,
    this.isSubmitting = false,
  });

  PersonalizeReady copyWith({List<CatalogBrand>? brands, bool? isSubmitting}) {
    return PersonalizeReady(
      categories: categories,
      brands: brands ?? this.brands,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [categories, brands, isSubmitting];
}

final class PersonalizeCompleted extends PersonalizeState {
  const PersonalizeCompleted();
}
