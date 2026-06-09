import 'package:klozy/src/domain/catalog/entity/catalog_brand.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_condition.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_size_value.dart';

/// Read-only catalog reference data (`/v1/catalog/**`).
abstract class CatalogRepository {
  /// Top-level categories (Women/Men/Kids).
  Future<List<CatalogCategory>> getRootCategories();

  /// Direct children of [parentId] (root categories when null).
  Future<List<CatalogCategory>> getCategories({String? parentId});

  /// Brands, optionally filtered by name.
  Future<List<CatalogBrand>> searchBrands({String? query});

  /// Item conditions (facet).
  Future<List<CatalogCondition>> getConditions();

  /// All size tokens (facet).
  Future<List<CatalogSizeValue>> getSizes();

  /// Size tokens applicable to a category (`/v1/catalog/categories/{id}/size-config`).
  Future<List<CatalogSizeValue>> getSizeConfig(String categoryId);
}
