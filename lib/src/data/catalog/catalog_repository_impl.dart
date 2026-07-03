import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/network/cache/session_cache.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_brand.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_condition.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_size_value.dart';

@LazySingleton(as: CatalogRepository)
class CatalogRepositoryImpl implements CatalogRepository {
  final Dio _dio;

  CatalogRepositoryImpl(this._dio);

  @override
  Future<List<CatalogCategory>> getRootCategories() => getCategories();

  @override
  Future<List<CatalogCategory>> getCategories({String? parentId}) async {
    final response = await _dio.get<List<dynamic>>(
      'v1/catalog/categories',
      queryParameters: <String, dynamic>{'parentId': parentId ?? ''},
      options: cacheable('catalog'),
    );
    final List<CatalogCategory> mapped = _list(response.data)
        .map(
          (Map<String, dynamic> json) => CatalogCategory(
            id: _str(json, ['id', '_id', 'slug']) ?? '',
            label: _str(json, ['label', 'name', 'title', 'slug']) ?? '',
            hasChildren: _hasChildren(json),
            imageUrl: _str(json, ['imageUrl', 'image', 'imageUri', 'photo']),
          ),
        )
        .where((CatalogCategory c) => c.id.isNotEmpty && c.label.isNotEmpty)
        .toList();
    return _dedupeCategories(mapped);
  }

  /// Drops duplicate categories the backend may return (same id, or same
  /// case-insensitive label) so the feed chips and pickers never show a
  /// category twice. First occurrence wins.
  List<CatalogCategory> _dedupeCategories(List<CatalogCategory> categories) {
    final Set<String> seenIds = <String>{};
    final Set<String> seenLabels = <String>{};
    final List<CatalogCategory> result = <CatalogCategory>[];
    for (final CatalogCategory c in categories) {
      final String label = c.label.trim().toLowerCase();
      if (seenIds.contains(c.id) || seenLabels.contains(label)) {
        continue;
      }
      seenIds.add(c.id);
      seenLabels.add(label);
      result.add(c);
    }
    return result;
  }

  @override
  Future<List<CatalogBrand>> searchBrands({String? query}) async {
    final response = await _dio.get<List<dynamic>>(
      'v1/catalog/brands',
      queryParameters: <String, dynamic>{
        if (query != null && query.isNotEmpty) 'q': query,
      },
      options: cacheable('catalog'),
    );
    return _list(response.data)
        .map(
          (Map<String, dynamic> json) => CatalogBrand(
            id: _str(json, ['id', '_id', 'slug']) ?? '',
            name: _str(json, ['name', 'label', 'title']) ?? '',
          ),
        )
        .where((CatalogBrand b) => b.id.isNotEmpty && b.name.isNotEmpty)
        .toList();
  }

  @override
  Future<List<CatalogCondition>> getConditions() async {
    final response = await _dio.get<List<dynamic>>(
      'v1/catalog/conditions',
      options: cacheable('catalog'),
    );
    return _list(response.data)
        .map(
          (Map<String, dynamic> json) => CatalogCondition(
            slug: _str(json, ['slug', 'id', '_id']) ?? '',
            label: _str(json, ['label', 'name', 'title']) ?? '',
          ),
        )
        .where((CatalogCondition c) => c.slug.isNotEmpty && c.label.isNotEmpty)
        .toList();
  }

  @override
  Future<List<CatalogSizeValue>> getSizeConfig(String categoryId) async {
    final response = await _dio.get<dynamic>(
      'v1/catalog/categories/$categoryId/size-config',
      options: cacheable('catalog'),
    );
    final data = response.data;
    final List<dynamic> sets = data is List
        ? data
        : (data is Map<String, dynamic>
              ? (data['sizeSets'] ?? data['sets'] ?? data['data'] ?? const [])
                    as List<dynamic>
              : const <dynamic>[]);
    return _flattenSizes(sets.whereType<Map<String, dynamic>>().toList());
  }

  @override
  Future<List<CatalogSizeValue>> getSizes() async {
    final response = await _dio.get<List<dynamic>>(
      'v1/catalog/sizes',
      options: cacheable('catalog'),
    );
    return _flattenSizes(_list(response.data));
  }

  List<CatalogSizeValue> _flattenSizes(List<Map<String, dynamic>> raws) {
    final result = <CatalogSizeValue>[];
    for (final raw in raws) {
      // A size set may carry a `values` list, or be a flat token.
      final values = raw['values'];
      if (values is List) {
        for (final v in values.whereType<Map<String, dynamic>>()) {
          final token = _str(v, ['value', 'token', 'label']);
          if (token != null) {
            result.add(
              CatalogSizeValue(
                token: token,
                label: _str(v, ['label']) ?? token,
                systemLabels: _systemLabels(v['systemLabels']),
              ),
            );
          }
        }
      } else {
        final token = _str(raw, ['value', 'token', 'name', 'label']);
        if (token != null) {
          result.add(
            CatalogSizeValue(
              token: token,
              label: _str(raw, ['label']) ?? token,
            ),
          );
        }
      }
    }
    return result;
  }

  bool _hasChildren(Map<String, dynamic> json) {
    if (json['hasChildren'] == true) return true;
    final children = json['children'];
    if (children is List && children.isNotEmpty) return true;
    final count = json['childCount'] ?? json['childrenCount'];
    return count is num && count > 0;
  }

  List<Map<String, dynamic>> _list(List<dynamic>? data) {
    if (data == null) return const <Map<String, dynamic>>[];
    return data.whereType<Map<String, dynamic>>().toList();
  }

  String? _str(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  /// Parses a size value's `systemLabels` map (e.g. `{'EU': '42', 'US': '9'}`)
  /// into a `Map<String, String>`, dropping any non-string entries. Returns
  /// null when absent or empty so region-agnostic sizes stay plain.
  Map<String, String>? _systemLabels(Object? raw) {
    if (raw is! Map) return null;
    final result = <String, String>{};
    raw.forEach((Object? key, Object? value) {
      if (key is String && value is String && value.isNotEmpty) {
        // Normalise keys to upper-case ('EU'/'US'/'UK'): the backend is
        // inconsistent (size sets carry lower-case `systems`, product tokens
        // use upper-case "EU 42"), so we pin a single casing here.
        result[key.toUpperCase()] = value;
      }
    });
    return result.isEmpty ? null : result;
  }
}
