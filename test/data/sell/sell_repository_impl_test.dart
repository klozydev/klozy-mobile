// test/data/sell/sell_repository_impl_test.dart

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/data/sell/sell_repository_impl.dart';
import 'package:klozy/src/domain/sell/entity/sell_draft.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockDio extends Mock implements Dio {}

// ── Helpers ────────────────────────────────────────────────────────────────

Response<Map<String, dynamic>> _ok(String path, Map<String, dynamic> data) =>
    Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: data,
    );

void main() {
  late _MockDio mockDio;
  late SellRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(Options());
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = _MockDio();
    repo = SellRepositoryImpl(mockDio);
  });

  // ── analyze ─────────────────────────────────────────────────────────────

  group('analyze', () {
    test('prefers en translation for title/description', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/sell/analyze',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => _ok('v1/sell/analyze', <String, dynamic>{
          'translations': <String, dynamic>{
            'en': <String, dynamic>{
              'title': 'Blue Dress',
              'description': 'A lovely dress.',
            },
            'fr': <String, dynamic>{
              'title': 'Robe Bleue',
              'description': 'Une belle robe.',
            },
          },
          'suggestedPrice': 50.0,
          'condition': 'good-condition',
          'category': <String, dynamic>{'id': 'cat-123'},
          'brand': <String, dynamic>{'id': 'brand-456'},
          'size': 'M',
        }),
      );

      final SellDraft result = await repo.analyze(<String>[
        'https://example.com/img.jpg',
      ]);

      expect(result.title, 'Blue Dress');
      expect(result.description, 'A lovely dress.');
      expect(result.price, 50.0);
      expect(result.categoryId, 'cat-123');
      expect(result.brandId, 'brand-456');
      expect(result.size, 'M');
      expect(result.conditionId, 'good-condition');
      expect(result.translations, isNotNull);
    });

    test('falls back to first locale when en is absent', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/sell/analyze',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => _ok('v1/sell/analyze', <String, dynamic>{
          'translations': <String, dynamic>{
            'fr': <String, dynamic>{
              'title': 'Robe',
              'description': 'Belle robe.',
            },
          },
          'suggestedPrice': 30,
        }),
      );

      final SellDraft result = await repo.analyze(<String>['img.jpg']);
      expect(result.title, 'Robe');
      expect(result.description, 'Belle robe.');
    });

    test('falls back to top-level title when translations absent', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/sell/analyze',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => _ok('v1/sell/analyze', <String, dynamic>{
          'title': 'Flat title',
          'description': 'Flat desc.',
          'categoryId': 'cat-flat',
          'brandId': 'brand-flat',
        }),
      );

      final SellDraft result = await repo.analyze(<String>['img.jpg']);
      expect(result.title, 'Flat title');
      expect(result.description, 'Flat desc.');
      expect(result.categoryId, 'cat-flat');
      expect(result.brandId, 'brand-flat');
      expect(result.translations, isNull); // translations map was empty
    });

    test('unwraps data envelope', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/sell/analyze',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => _ok('v1/sell/analyze', <String, dynamic>{
          'data': <String, dynamic>{
            'translations': <String, dynamic>{
              'en': <String, dynamic>{'title': 'Wrapped Title'},
            },
            'suggestedPrice': 75,
          },
        }),
      );

      final SellDraft result = await repo.analyze(<String>['img.jpg']);
      expect(result.title, 'Wrapped Title');
      expect(result.price, 75);
    });

    test('returns empty draft when response is empty object', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/sell/analyze',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => _ok('v1/sell/analyze', <String, dynamic>{}));

      final SellDraft result = await repo.analyze(<String>['img.jpg']);
      expect(result.title, isNull);
      expect(result.price, isNull);
      expect(result.translations, isNull);
    });

    test('parses price from string numeric value', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/sell/analyze',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => _ok('v1/sell/analyze', <String, dynamic>{
          'price': '99',
          'title': 'Shirt',
        }),
      );

      final SellDraft result = await repo.analyze(<String>['img.jpg']);
      expect(result.price, 99);
    });

    test('sends imageUrls in the request body', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/sell/analyze',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => _ok('v1/sell/analyze', <String, dynamic>{}));

      await repo.analyze(<String>[
        'https://cdn.example.com/1.jpg',
        'https://cdn.example.com/2.jpg',
      ]);

      final VerificationResult verification = verify(
        () => mockDio.post<Map<String, dynamic>>(
          'v1/sell/analyze',
          data: captureAny(named: 'data'),
        ),
      );
      final Map<String, dynamic> body =
          verification.captured.first as Map<String, dynamic>;
      expect(
        body['imageUrls'],
        containsAll(<String>[
          'https://cdn.example.com/1.jpg',
          'https://cdn.example.com/2.jpg',
        ]),
      );
    });
  });
}
