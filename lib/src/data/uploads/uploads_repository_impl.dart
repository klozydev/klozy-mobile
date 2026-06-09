import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/domain/uploads/uploads_repository.dart';

@LazySingleton(as: UploadsRepository)
class UploadsRepositoryImpl implements UploadsRepository {
  final Dio _dio;

  UploadsRepositoryImpl(this._dio);

  @override
  Future<List<String>> uploadImages(List<String> filePaths) async {
    final formData = FormData();
    for (final path in filePaths) {
      formData.files.add(
        MapEntry<String, MultipartFile>(
          'files',
          await MultipartFile.fromFile(path),
        ),
      );
    }
    final response = await _dio.post<dynamic>(
      'v1/uploads/images',
      data: formData,
    );
    return _urls(response.data);
  }

  List<String> _urls(Object? data) {
    if (data is List) return _fromList(data);
    if (data is Map<String, dynamic>) {
      for (final key in const <String>['urls', 'data', 'images', 'files']) {
        final value = data[key];
        if (value is List) return _fromList(value);
      }
    }
    return const <String>[];
  }

  List<String> _fromList(List<dynamic> list) {
    return list
        .map((Object? e) {
          if (e is String) return e;
          if (e is Map<String, dynamic>) {
            for (final key in const <String>['url', 'src', 'location']) {
              final value = e[key];
              if (value is String) return value;
            }
          }
          return '';
        })
        .where((String s) => s.isNotEmpty)
        .toList();
  }
}
