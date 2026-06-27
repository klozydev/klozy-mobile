// test/data/config/public_config_repository_impl_test.dart

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/data/config/public_config_repository_impl.dart';
import 'package:klozy/src/domain/config/entity/contact_info.dart';
import 'package:klozy/src/domain/config/entity/legal_doc.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockDio extends Mock implements Dio {}

// ── Helpers ────────────────────────────────────────────────────────────────

Response<T> _ok<T>(String path, T data) => Response<T>(
  requestOptions: RequestOptions(path: path),
  statusCode: 200,
  data: data,
);

Response<dynamic> _voidOk(String path) => Response<dynamic>(
  requestOptions: RequestOptions(path: path),
  statusCode: 200,
);

void main() {
  late _MockDio mockDio;
  late PublicConfigRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(Options());
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = _MockDio();
    repo = PublicConfigRepositoryImpl(mockDio);
  });

  // ── getLegalDocs ────────────────────────────────────────────────────────

  group('getLegalDocs', () {
    test('maps bare list of legal docs', () async {
      when(
        () => mockDio.get<dynamic>('v1/legal', options: any(named: 'options')),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/legal', <dynamic>[
          <String, dynamic>{
            'key': 'privacy',
            'name': 'Privacy Policy',
            'version': '1.2',
          },
          <String, dynamic>{'slug': 'terms', 'title': 'Terms of Service'},
        ]),
      );

      final List<LegalDoc> result = await repo.getLegalDocs();

      expect(result, hasLength(2));
      expect(result[0].key, 'privacy');
      expect(result[0].name, 'Privacy Policy');
      expect(result[0].version, '1.2');
      expect(result[1].key, 'terms');
      expect(result[1].version, isNull);
    });

    test('maps envelope with data list', () async {
      when(
        () => mockDio.get<dynamic>('v1/legal', options: any(named: 'options')),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/legal', <String, dynamic>{
          'data': <dynamic>[
            <String, dynamic>{'key': 'cookies', 'name': 'Cookie Policy'},
          ],
        }),
      );

      final List<LegalDoc> result = await repo.getLegalDocs();
      expect(result, hasLength(1));
      expect(result.first.key, 'cookies');
    });

    test('maps envelope with documents list', () async {
      when(
        () => mockDio.get<dynamic>('v1/legal', options: any(named: 'options')),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/legal', <String, dynamic>{
          'documents': <dynamic>[
            <String, dynamic>{'key': 'gdpr', 'name': 'GDPR'},
          ],
        }),
      );

      final List<LegalDoc> result = await repo.getLegalDocs();
      expect(result, hasLength(1));
      expect(result.first.key, 'gdpr');
    });

    test('returns empty when response is not list or map', () async {
      when(
        () => mockDio.get<dynamic>('v1/legal', options: any(named: 'options')),
      ).thenAnswer((_) async => _ok<dynamic>('v1/legal', null));

      final List<LegalDoc> result = await repo.getLegalDocs();
      expect(result, isEmpty);
    });
  });

  // ── getLegalDoc ─────────────────────────────────────────────────────────

  group('getLegalDoc', () {
    test('maps content from body key', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/legal/privacy',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async =>
            _ok<Map<String, dynamic>>('v1/legal/privacy', <String, dynamic>{
              'name': 'Privacy Policy',
              'content': '<p>We respect your privacy.</p>',
            }),
      );

      final LegalDocContent result = await repo.getLegalDoc('privacy');

      expect(result.title, 'Privacy Policy');
      expect(result.body, contains('respect'));
    });

    test('falls back to text key for body', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/legal/terms',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<Map<String, dynamic>>(
          'v1/legal/terms',
          <String, dynamic>{'title': 'Terms', 'text': 'Terms content.'},
        ),
      );

      final LegalDocContent result = await repo.getLegalDoc('terms');
      expect(result.title, 'Terms');
      expect(result.body, 'Terms content.');
    });

    test('returns empty strings when data is empty', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/legal/missing',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async =>
            _ok<Map<String, dynamic>>('v1/legal/missing', <String, dynamic>{}),
      );

      final LegalDocContent result = await repo.getLegalDoc('missing');
      expect(result.title, '');
      expect(result.body, '');
    });
  });

  // ── getContact ──────────────────────────────────────────────────────────

  group('getContact', () {
    test('maps supportEmail and instagram', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/app/contact',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async =>
            _ok<Map<String, dynamic>>('v1/app/contact', <String, dynamic>{
              'supportEmail': 'support@klozy.com',
              'instagram': '@klozy',
            }),
      );

      final ContactInfo result = await repo.getContact();

      expect(result.supportEmail, 'support@klozy.com');
      expect(result.instagram, '@klozy');
    });

    test('uses alternative key instagramUrl', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/app/contact',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async =>
            _ok<Map<String, dynamic>>('v1/app/contact', <String, dynamic>{
              'email': 'hello@klozy.com',
              'instagramUrl': 'https://instagram.com/klozy',
            }),
      );

      final ContactInfo result = await repo.getContact();
      expect(result.supportEmail, 'hello@klozy.com');
      expect(result.instagram, 'https://instagram.com/klozy');
    });

    test('returns nulls when fields absent', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          'v1/app/contact',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async =>
            _ok<Map<String, dynamic>>('v1/app/contact', <String, dynamic>{}),
      );

      final ContactInfo result = await repo.getContact();
      expect(result.supportEmail, isNull);
      expect(result.instagram, isNull);
    });
  });

  // ── getPendingLegal ─────────────────────────────────────────────────────

  group('getPendingLegal', () {
    test('maps pending legal docs from bare list', () async {
      when(() => mockDio.get<dynamic>('v1/me/legal/pending')).thenAnswer(
        (_) async => _ok<dynamic>('v1/me/legal/pending', <dynamic>[
          <String, dynamic>{'key': 'terms-v2', 'name': 'Terms v2'},
        ]),
      );

      final List<LegalDoc> result = await repo.getPendingLegal();
      expect(result, hasLength(1));
      expect(result.first.key, 'terms-v2');
    });

    test('returns empty list when no pending docs', () async {
      when(() => mockDio.get<dynamic>('v1/me/legal/pending')).thenAnswer(
        (_) async => _ok<dynamic>('v1/me/legal/pending', <dynamic>[]),
      );

      final List<LegalDoc> result = await repo.getPendingLegal();
      expect(result, isEmpty);
    });
  });

  // ── acceptLegal ─────────────────────────────────────────────────────────

  group('acceptLegal', () {
    test('posts to v1/me/legal/:key/accept', () async {
      when(
        () => mockDio.post<dynamic>('v1/me/legal/terms-v2/accept'),
      ).thenAnswer((_) async => _voidOk('v1/me/legal/terms-v2/accept'));

      await repo.acceptLegal('terms-v2');

      verify(
        () => mockDio.post<dynamic>('v1/me/legal/terms-v2/accept'),
      ).called(1);
    });
  });
}
