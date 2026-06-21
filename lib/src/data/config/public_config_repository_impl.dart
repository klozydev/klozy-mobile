import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/network/cache/session_cache.dart';
import 'package:klozy/src/domain/config/entity/contact_info.dart';
import 'package:klozy/src/domain/config/entity/legal_doc.dart';
import 'package:klozy/src/domain/config/public_config_repository.dart';

@LazySingleton(as: PublicConfigRepository)
class PublicConfigRepositoryImpl implements PublicConfigRepository {
  final Dio _dio;

  PublicConfigRepositoryImpl(this._dio);

  @override
  Future<List<LegalDoc>> getLegalDocs() async {
    final response = await _dio.get<dynamic>(
      'v1/legal',
      options: cacheable('config'),
    );
    return _list(response.data).whereType<Map<String, dynamic>>().map((
      Map<String, dynamic> j,
    ) {
      return LegalDoc(
        key: _str(j, ['key', 'slug', 'id']) ?? '',
        name: _str(j, ['name', 'title']) ?? '',
        version: _str(j, ['version']),
      );
    }).toList();
  }

  @override
  Future<LegalDocContent> getLegalDoc(String key) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'v1/legal/$key',
      options: cacheable('config'),
    );
    final j = response.data ?? const <String, dynamic>{};
    return LegalDocContent(
      title: _str(j, ['name', 'title']) ?? '',
      body: _str(j, ['content', 'body', 'text', 'html']) ?? '',
    );
  }

  @override
  Future<ContactInfo> getContact() async {
    final response = await _dio.get<Map<String, dynamic>>(
      'v1/app/contact',
      options: cacheable('config'),
    );
    final j = response.data ?? const <String, dynamic>{};
    return ContactInfo(
      supportEmail: _str(j, ['supportEmail', 'email']),
      instagram: _str(j, ['instagram', 'instagramUrl']),
    );
  }

  @override
  Future<List<LegalDoc>> getPendingLegal() async {
    final response = await _dio.get<dynamic>('v1/me/legal/pending');
    return _list(response.data).whereType<Map<String, dynamic>>().map((
      Map<String, dynamic> j,
    ) {
      return LegalDoc(
        key: _str(j, ['key', 'slug', 'id']) ?? '',
        name: _str(j, ['name', 'title']) ?? '',
        version: _str(j, ['version']),
      );
    }).toList();
  }

  @override
  Future<void> acceptLegal(String key) async {
    await _dio.post<dynamic>('v1/me/legal/$key/accept');
  }

  List<dynamic> _list(Object? data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final key in const <String>['data', 'items', 'documents']) {
        if (data[key] is List) return data[key] as List<dynamic>;
      }
    }
    return const <dynamic>[];
  }

  String? _str(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }
}
