import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/network/cache/session_cache.dart';

@injectable
class RemoteReelsDataSource {
  final Dio _dio;

  RemoteReelsDataSource(this._dio);

  Future<Map<String, dynamic>> feed({
    required int page,
    required int limit,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'v1/reels',
      queryParameters: <String, dynamic>{'page': page, 'limit': limit},
    );
    return response.data ?? const <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getOne(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'v1/reels/$id',
      options: cacheable('reels'),
    );
    return response.data ?? const <String, dynamic>{};
  }

  Future<void> update(String id, Map<String, dynamic> body) =>
      _dio.patch<dynamic>('v1/reels/$id', data: body);

  Future<Object?> comments(String id, {required int page}) async {
    final response = await _dio.get<dynamic>(
      'v1/reels/$id/comments',
      queryParameters: <String, dynamic>{'page': page, 'limit': 50},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> addComment(String id, String body) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'v1/reels/$id/comments',
      data: <String, dynamic>{'body': body},
    );
    return response.data ?? const <String, dynamic>{};
  }

  Future<void> deleteComment(String id, String commentId) =>
      _dio.delete<dynamic>('v1/reels/$id/comments/$commentId');

  Future<void> like(String id) => _dio.put<dynamic>('v1/reels/$id/like');

  Future<void> unlike(String id) => _dio.delete<dynamic>('v1/reels/$id/like');

  Future<void> view(String id) => _dio.post<dynamic>('v1/reels/$id/view');

  Future<void> report(String id, String reason) => _dio.post<dynamic>(
    'v1/reels/$id/report',
    data: <String, dynamic>{'reason': reason},
  );

  Future<void> delete(String id) => _dio.delete<dynamic>('v1/reels/$id');

  Future<List<dynamic>> shopTheLook(String id) async {
    final response = await _dio.get<List<dynamic>>(
      'v1/reels/$id/products',
      options: cacheable('reels'),
    );
    return response.data ?? const <dynamic>[];
  }

  Future<List<dynamic>> userProducts(String userId) async {
    final response = await _dio.get<dynamic>(
      'v1/users/$userId/products',
      queryParameters: <String, dynamic>{'page': 1, 'limit': 50},
    );
    // The endpoint may return a bare list or a paginated envelope; accept the
    // same key variants the profile feature handles.
    final Object? data = response.data;
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final String key in const <String>[
        'data',
        'items',
        'results',
        'products',
      ]) {
        if (data[key] is List) return data[key] as List<dynamic>;
      }
    }
    return const <dynamic>[];
  }

  Future<Map<String, dynamic>> createReel({
    String? caption,
    required List<String> taggedProductIds,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'v1/reels',
      data: <String, dynamic>{
        if (caption != null && caption.isNotEmpty) 'caption': caption,
        'taggedProductIds': taggedProductIds,
      },
    );
    return response.data ?? const <String, dynamic>{};
  }

  /// Raw PUT of the video bytes to the Mux upload URL (no app interceptors).
  Future<void> uploadVideo(String uploadUrl, String filePath) async {
    final file = File(filePath);
    final length = await file.length();
    await Dio().put<dynamic>(
      uploadUrl,
      data: file.openRead(),
      options: Options(
        headers: <String, dynamic>{
          Headers.contentLengthHeader: length,
          Headers.contentTypeHeader: 'video/mp4',
        },
      ),
    );
  }
}
