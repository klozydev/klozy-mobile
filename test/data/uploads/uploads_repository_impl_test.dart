// test/data/uploads/uploads_repository_impl_test.dart
//
// Covers UploadsRepositoryImpl — full coverage of uploadImages and the
// private _urls/_fromList parsing branches.
//
// Design: most mapping tests pass an empty file list so no disk I/O is needed.
// One test creates a real temp file to verify the FormData assembly path.

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/data/uploads/uploads_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockDio extends Mock implements Dio {}

// ── Helpers ────────────────────────────────────────────────────────────────

Response<T> okResponse<T>(String path, T data) => Response<T>(
  requestOptions: RequestOptions(path: path),
  statusCode: 200,
  data: data,
);

void main() {
  late _MockDio mockDio;
  late UploadsRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(Options());
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = _MockDio();
    repo = UploadsRepositoryImpl(mockDio);
  });

  // ── POST endpoint ─────────────────────────────────────────────────────────

  group('uploadImages — POST endpoint', () {
    test('calls POST to v1/uploads/images', () async {
      when(
        () => mockDio.post<dynamic>(
          'v1/uploads/images',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => okResponse<dynamic>('v1/uploads/images', <String>[]),
      );

      await repo.uploadImages(<String>[]);

      verify(
        () => mockDio.post<dynamic>(
          'v1/uploads/images',
          data: any(named: 'data'),
        ),
      ).called(1);
    });
  });

  // ── bare List response ────────────────────────────────────────────────────

  group('uploadImages — bare string list response', () {
    test('extracts strings directly from a List<String> response', () async {
      when(
        () => mockDio.post<dynamic>(
          'v1/uploads/images',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => okResponse<dynamic>('v1/uploads/images', <String>[
          'https://cdn.example.com/a.jpg',
          'https://cdn.example.com/b.jpg',
        ]),
      );

      final List<String> result = await repo.uploadImages(<String>[]);

      expect(result, <String>[
        'https://cdn.example.com/a.jpg',
        'https://cdn.example.com/b.jpg',
      ]);
    });

    test('filters empty strings and null-like items from list', () async {
      when(
        () => mockDio.post<dynamic>(
          'v1/uploads/images',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => okResponse<dynamic>('v1/uploads/images', <dynamic>[
          'https://cdn.example.com/a.jpg',
          '',
          null,
        ]),
      );

      final List<String> result = await repo.uploadImages(<String>[]);

      expect(result, <String>['https://cdn.example.com/a.jpg']);
    });
  });

  // ── list-of-map responses (url / src / location keys) ────────────────────

  group('uploadImages — list of map items', () {
    test('extracts url value from map items with url key', () async {
      when(
        () => mockDio.post<dynamic>(
          'v1/uploads/images',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => okResponse<dynamic>('v1/uploads/images', <dynamic>[
          <String, dynamic>{'url': 'https://s3.example.com/img.jpg'},
        ]),
      );

      final List<String> result = await repo.uploadImages(<String>[]);

      expect(result, <String>['https://s3.example.com/img.jpg']);
    });

    test('extracts url value from map items with src key', () async {
      when(
        () => mockDio.post<dynamic>(
          'v1/uploads/images',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => okResponse<dynamic>('v1/uploads/images', <dynamic>[
          <String, dynamic>{'src': 'https://s3.example.com/img2.jpg'},
        ]),
      );

      final List<String> result = await repo.uploadImages(<String>[]);

      expect(result, <String>['https://s3.example.com/img2.jpg']);
    });

    test('extracts url value from map items with location key', () async {
      when(
        () => mockDio.post<dynamic>(
          'v1/uploads/images',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => okResponse<dynamic>('v1/uploads/images', <dynamic>[
          <String, dynamic>{'location': 'https://s3.example.com/img3.jpg'},
        ]),
      );

      final List<String> result = await repo.uploadImages(<String>[]);

      expect(result, <String>['https://s3.example.com/img3.jpg']);
    });

    test('skips map items with no recognized url key', () async {
      when(
        () => mockDio.post<dynamic>(
          'v1/uploads/images',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => okResponse<dynamic>('v1/uploads/images', <dynamic>[
          <String, dynamic>{'name': 'file.jpg', 'size': 1024},
        ]),
      );

      final List<String> result = await repo.uploadImages(<String>[]);

      expect(result, isEmpty);
    });
  });

  // ── map envelope responses ────────────────────────────────────────────────

  group('uploadImages — map envelope response', () {
    test('extracts from urls key', () async {
      when(
        () => mockDio.post<dynamic>(
          'v1/uploads/images',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => okResponse<dynamic>('v1/uploads/images', <String, dynamic>{
          'urls': <String>['https://cdn.example.com/1.jpg'],
        }),
      );

      final List<String> result = await repo.uploadImages(<String>[]);

      expect(result, <String>['https://cdn.example.com/1.jpg']);
    });

    test('extracts from data key', () async {
      when(
        () => mockDio.post<dynamic>(
          'v1/uploads/images',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => okResponse<dynamic>('v1/uploads/images', <String, dynamic>{
          'data': <String>['https://cdn.example.com/2.jpg'],
        }),
      );

      final List<String> result = await repo.uploadImages(<String>[]);

      expect(result, <String>['https://cdn.example.com/2.jpg']);
    });

    test('extracts from images key', () async {
      when(
        () => mockDio.post<dynamic>(
          'v1/uploads/images',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => okResponse<dynamic>('v1/uploads/images', <String, dynamic>{
          'images': <String>['https://cdn.example.com/3.jpg'],
        }),
      );

      final List<String> result = await repo.uploadImages(<String>[]);

      expect(result, <String>['https://cdn.example.com/3.jpg']);
    });

    test('extracts from files key', () async {
      when(
        () => mockDio.post<dynamic>(
          'v1/uploads/images',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => okResponse<dynamic>('v1/uploads/images', <String, dynamic>{
          'files': <String>['https://cdn.example.com/4.jpg'],
        }),
      );

      final List<String> result = await repo.uploadImages(<String>[]);

      expect(result, <String>['https://cdn.example.com/4.jpg']);
    });

    test('returns empty list when map has no recognized key', () async {
      when(
        () => mockDio.post<dynamic>(
          'v1/uploads/images',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => okResponse<dynamic>('v1/uploads/images', <String, dynamic>{
          'status': 'ok',
        }),
      );

      final List<String> result = await repo.uploadImages(<String>[]);

      expect(result, isEmpty);
    });
  });

  // ── null / unrecognized response ──────────────────────────────────────────

  group('uploadImages — null or unrecognized response', () {
    test('returns empty list when response data is null', () async {
      when(
        () => mockDio.post<dynamic>(
          'v1/uploads/images',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => okResponse<dynamic>('v1/uploads/images', null));

      final List<String> result = await repo.uploadImages(<String>[]);

      expect(result, isEmpty);
    });

    test(
      'returns empty list when response data is a non-list/map scalar',
      () async {
        when(
          () => mockDio.post<dynamic>(
            'v1/uploads/images',
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) async => okResponse<dynamic>('v1/uploads/images', 42));

        final List<String> result = await repo.uploadImages(<String>[]);

        expect(result, isEmpty);
      },
    );
  });

  // ── with actual file ──────────────────────────────────────────────────────

  group('uploadImages — with actual file on disk', () {
    test('attaches file to FormData and POSTs; returns mapped URLs', () async {
      final File tmpFile = File(
        '${Directory.systemTemp.path}/test_upload_${DateTime.now().millisecondsSinceEpoch}.txt',
      );
      await tmpFile.writeAsString('upload test content');

      try {
        when(
          () => mockDio.post<dynamic>(
            'v1/uploads/images',
            data: any(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => okResponse<dynamic>('v1/uploads/images', <String>[
            'https://cdn.example.com/uploaded.jpg',
          ]),
        );

        final List<String> result = await repo.uploadImages(<String>[
          tmpFile.path,
        ]);

        expect(result, <String>['https://cdn.example.com/uploaded.jpg']);
        verify(
          () => mockDio.post<dynamic>(
            'v1/uploads/images',
            data: any(named: 'data'),
          ),
        ).called(1);
      } finally {
        if (tmpFile.existsSync()) tmpFile.deleteSync();
      }
    });
  });
}
