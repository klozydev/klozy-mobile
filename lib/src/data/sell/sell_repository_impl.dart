import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/domain/sell/entity/sell_draft.dart';
import 'package:klozy/src/domain/sell/sell_repository.dart';

@LazySingleton(as: SellRepository)
class SellRepositoryImpl implements SellRepository {
  final Dio _dio;

  SellRepositoryImpl(this._dio);

  @override
  Future<SellDraft> analyze(List<String> imageUrls) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'v1/sell/analyze',
      data: <String, dynamic>{'imageUrls': imageUrls},
    );
    final json = response.data ?? const <String, dynamic>{};
    final inner = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    // ListingSuggestionDto: translations.{locale}.{title,description},
    // suggestedPrice, condition (slug), category.{id}, brand.{id}, size.
    final translations = inner['translations'] is Map<String, dynamic>
        ? inner['translations'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final en = _firstDraft(translations);
    final category = _obj(inner['category']);
    final brand = _obj(inner['brand']);
    return SellDraft(
      title: _str(en, ['title']) ?? _str(inner, ['title', 'name']),
      description: _str(en, ['description']) ?? _str(inner, ['description']),
      price: _num(inner, ['suggestedPrice', 'price']),
      categoryId: _str(category, ['id']) ?? _str(inner, ['categoryId']),
      brandId: _str(brand, ['id']) ?? _str(inner, ['brandId']),
      size: _str(inner, ['size']),
      conditionId: _str(inner, ['condition', 'conditionId']),
      translations: translations.isEmpty ? null : translations,
    );
  }

  Map<String, dynamic> _obj(Object? value) =>
      value is Map<String, dynamic> ? value : const <String, dynamic>{};

  /// Prefer the `en` locale draft, else the first available one.
  Map<String, dynamic> _firstDraft(Map<String, dynamic> translations) {
    if (translations['en'] is Map<String, dynamic>) {
      return translations['en'] as Map<String, dynamic>;
    }
    for (final Object? v in translations.values) {
      if (v is Map<String, dynamic>) return v;
    }
    return const <String, dynamic>{};
  }

  String? _str(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  num? _num(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) return value;
      if (value is String) {
        final parsed = num.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }
}
