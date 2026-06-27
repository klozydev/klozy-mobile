// test/data/catalog/catalog_repository_impl_test.dart

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/data/catalog/catalog_repository_impl.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_brand.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_condition.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_size_value.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class _MockDio extends Mock implements Dio {}

// ── Helpers ────────────────────────────────────────────────────────────────

Response<T> _ok<T>(String path, T data) => Response<T>(
  requestOptions: RequestOptions(path: path),
  statusCode: 200,
  data: data,
);

void main() {
  late _MockDio mockDio;
  late CatalogRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(Options());
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = _MockDio();
    repo = CatalogRepositoryImpl(mockDio);
  });

  // ── getCategories ───────────────────────────────────────────────────────

  group('getCategories', () {
    test('maps category list with hasChildren from flag', () async {
      when(
        () => mockDio.get<List<dynamic>>(
          'v1/catalog/categories',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<List<dynamic>>('v1/catalog/categories', <dynamic>[
          <String, dynamic>{
            'id': 'cat1',
            'label': 'Clothes',
            'hasChildren': true,
          },
          <String, dynamic>{'id': 'cat2', 'label': 'Shoes', 'childCount': 0},
        ]),
      );

      final List<CatalogCategory> result = await repo.getCategories();

      expect(result, hasLength(2));
      expect(result[0].id, 'cat1');
      expect(result[0].label, 'Clothes');
      expect(result[0].hasChildren, isTrue);
      expect(result[1].hasChildren, isFalse);
    });

    test('filters out entries with empty id or label', () async {
      when(
        () => mockDio.get<List<dynamic>>(
          'v1/catalog/categories',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<List<dynamic>>('v1/catalog/categories', <dynamic>[
          <String, dynamic>{'id': '', 'label': 'Empty Id'},
          <String, dynamic>{'id': 'cat3', 'label': ''},
          <String, dynamic>{'id': 'cat4', 'label': 'Valid'},
        ]),
      );

      final List<CatalogCategory> result = await repo.getCategories();
      expect(result, hasLength(1));
      expect(result.first.id, 'cat4');
    });

    test('deduplicates categories by id (first wins)', () async {
      when(
        () => mockDio.get<List<dynamic>>(
          'v1/catalog/categories',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<List<dynamic>>('v1/catalog/categories', <dynamic>[
          <String, dynamic>{'id': 'cat1', 'label': 'First'},
          <String, dynamic>{'id': 'cat1', 'label': 'Duplicate'},
        ]),
      );

      final List<CatalogCategory> result = await repo.getCategories();
      expect(result, hasLength(1));
      expect(result.first.label, 'First');
    });

    test('deduplicates categories by label (case-insensitive)', () async {
      when(
        () => mockDio.get<List<dynamic>>(
          'v1/catalog/categories',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<List<dynamic>>('v1/catalog/categories', <dynamic>[
          <String, dynamic>{'id': 'cat1', 'label': 'Clothes'},
          <String, dynamic>{'id': 'cat2', 'label': 'CLOTHES'},
        ]),
      );

      final List<CatalogCategory> result = await repo.getCategories();
      expect(result, hasLength(1));
      expect(result.first.id, 'cat1');
    });

    test('hasChildren is true when childrenCount > 0', () async {
      when(
        () => mockDio.get<List<dynamic>>(
          'v1/catalog/categories',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<List<dynamic>>('v1/catalog/categories', <dynamic>[
          <String, dynamic>{'id': 'cat5', 'label': 'Bags', 'childrenCount': 3},
        ]),
      );

      final List<CatalogCategory> result = await repo.getCategories();
      expect(result.first.hasChildren, isTrue);
    });

    test('hasChildren is true when non-empty children list', () async {
      when(
        () => mockDio.get<List<dynamic>>(
          'v1/catalog/categories',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<List<dynamic>>('v1/catalog/categories', <dynamic>[
          <String, dynamic>{
            'id': 'cat6',
            'label': 'Tops',
            'children': <dynamic>['child1'],
          },
        ]),
      );

      final List<CatalogCategory> result = await repo.getCategories();
      expect(result.first.hasChildren, isTrue);
    });

    test('returns empty list when response data is empty', () async {
      when(
        () => mockDio.get<List<dynamic>>(
          'v1/catalog/categories',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<List<dynamic>>('v1/catalog/categories', <dynamic>[]),
      );

      final List<CatalogCategory> result = await repo.getCategories();
      expect(result, isEmpty);
    });

    test('uses slug as fallback id and label', () async {
      when(
        () => mockDio.get<List<dynamic>>(
          'v1/catalog/categories',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<List<dynamic>>('v1/catalog/categories', <dynamic>[
          <String, dynamic>{'slug': 'accessories'},
        ]),
      );

      final List<CatalogCategory> result = await repo.getCategories();
      expect(result, hasLength(1));
      expect(result.first.id, 'accessories');
      expect(result.first.label, 'accessories');
    });
  });

  // ── getRootCategories ───────────────────────────────────────────────────

  group('getRootCategories', () {
    test('delegates to getCategories with no parentId', () async {
      when(
        () => mockDio.get<List<dynamic>>(
          'v1/catalog/categories',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<List<dynamic>>('v1/catalog/categories', <dynamic>[
          <String, dynamic>{'id': 'root', 'label': 'Root'},
        ]),
      );

      final List<CatalogCategory> result = await repo.getRootCategories();
      expect(result, hasLength(1));
    });
  });

  // ── searchBrands ────────────────────────────────────────────────────────

  group('searchBrands', () {
    test('maps brand list', () async {
      when(
        () => mockDio.get<List<dynamic>>(
          'v1/catalog/brands',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<List<dynamic>>('v1/catalog/brands', <dynamic>[
          <String, dynamic>{'id': 'b1', 'name': 'Nike'},
          <String, dynamic>{'id': 'b2', 'name': 'Adidas'},
        ]),
      );

      final List<CatalogBrand> result = await repo.searchBrands(query: 'ni');
      expect(result, hasLength(2));
      expect(result[0].id, 'b1');
      expect(result[0].name, 'Nike');
    });

    test('uses slug as fallback id', () async {
      when(
        () => mockDio.get<List<dynamic>>(
          'v1/catalog/brands',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<List<dynamic>>('v1/catalog/brands', <dynamic>[
          <String, dynamic>{'slug': 'puma', 'label': 'Puma'},
        ]),
      );

      final List<CatalogBrand> result = await repo.searchBrands();
      expect(result.first.id, 'puma');
    });

    test('filters out brands with empty id or name', () async {
      when(
        () => mockDio.get<List<dynamic>>(
          'v1/catalog/brands',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<List<dynamic>>('v1/catalog/brands', <dynamic>[
          <String, dynamic>{'id': '', 'name': 'No-id'},
          <String, dynamic>{'id': 'b3', 'name': ''},
          <String, dynamic>{'id': 'b4', 'name': 'Valid'},
        ]),
      );

      final List<CatalogBrand> result = await repo.searchBrands();
      expect(result, hasLength(1));
      expect(result.first.id, 'b4');
    });
  });

  // ── getConditions ───────────────────────────────────────────────────────

  group('getConditions', () {
    test('maps conditions list', () async {
      when(
        () => mockDio.get<List<dynamic>>(
          'v1/catalog/conditions',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<List<dynamic>>('v1/catalog/conditions', <dynamic>[
          <String, dynamic>{'slug': 'new-with-tags', 'label': 'New with tags'},
          <String, dynamic>{'slug': 'good', 'label': 'Good'},
        ]),
      );

      final List<CatalogCondition> result = await repo.getConditions();
      expect(result, hasLength(2));
      expect(result[0].slug, 'new-with-tags');
      expect(result[1].label, 'Good');
    });

    test('uses id fallback for slug', () async {
      when(
        () => mockDio.get<List<dynamic>>(
          'v1/catalog/conditions',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<List<dynamic>>('v1/catalog/conditions', <dynamic>[
          <String, dynamic>{'id': 'fair', 'name': 'Fair'},
        ]),
      );

      final List<CatalogCondition> result = await repo.getConditions();
      expect(result.first.slug, 'fair');
    });
  });

  // ── getSizeConfig ───────────────────────────────────────────────────────

  group('getSizeConfig', () {
    test('flattens size sets with values list', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/catalog/categories/cat1/size-config',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async =>
            _ok<dynamic>('v1/catalog/categories/cat1/size-config', <dynamic>[
              <String, dynamic>{
                'setName': 'EU',
                'values': <dynamic>[
                  <String, dynamic>{
                    'value': 'EU 38',
                    'label': '38',
                    'systemLabels': <String, dynamic>{'US': '7.5', 'UK': '5'},
                  },
                  <String, dynamic>{'value': 'EU 40', 'label': '40'},
                ],
              },
            ]),
      );

      final List<CatalogSizeValue> result = await repo.getSizeConfig('cat1');

      expect(result, hasLength(2));
      expect(result[0].token, 'EU 38');
      expect(result[0].label, '38');
      expect(result[0].systemLabels, containsPair('US', '7.5'));
      expect(result[1].systemLabels, isNull);
    });

    test('flattens flat size tokens (no values list)', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/catalog/categories/cat2/size-config',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async =>
            _ok<dynamic>('v1/catalog/categories/cat2/size-config', <dynamic>[
              <String, dynamic>{'value': 'XS', 'label': 'Extra Small'},
              <String, dynamic>{'token': 'M'},
            ]),
      );

      final List<CatalogSizeValue> result = await repo.getSizeConfig('cat2');

      expect(result, hasLength(2));
      expect(result[0].token, 'XS');
      expect(result[0].label, 'Extra Small');
      expect(result[1].token, 'M');
      expect(result[1].label, 'M'); // falls back to token
    });

    test('handles envelope with sizeSets key', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/catalog/categories/cat3/size-config',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>(
          'v1/catalog/categories/cat3/size-config',
          <String, dynamic>{
            'sizeSets': <dynamic>[
              <String, dynamic>{'value': 'ONE SIZE'},
            ],
          },
        ),
      );

      final List<CatalogSizeValue> result = await repo.getSizeConfig('cat3');

      expect(result, hasLength(1));
      expect(result.first.token, 'ONE SIZE');
    });

    test('_systemLabels normalises keys to upper-case', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/catalog/categories/cat4/size-config',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async =>
            _ok<dynamic>('v1/catalog/categories/cat4/size-config', <dynamic>[
              <String, dynamic>{
                'values': <dynamic>[
                  <String, dynamic>{
                    'value': 'S',
                    'systemLabels': <String, dynamic>{'eu': '34', 'us': '2'},
                  },
                ],
              },
            ]),
      );

      final List<CatalogSizeValue> result = await repo.getSizeConfig('cat4');

      expect(result.first.systemLabels, containsPair('EU', '34'));
      expect(result.first.systemLabels, containsPair('US', '2'));
    });
  });

  // ── getSizes ────────────────────────────────────────────────────────────

  group('getSizes', () {
    test('maps flat size tokens', () async {
      when(
        () => mockDio.get<List<dynamic>>(
          'v1/catalog/sizes',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => _ok<List<dynamic>>('v1/catalog/sizes', <dynamic>[
          <String, dynamic>{'value': 'S'},
          <String, dynamic>{'value': 'M'},
          <String, dynamic>{'name': 'L'},
        ]),
      );

      final List<CatalogSizeValue> result = await repo.getSizes();
      expect(result, hasLength(3));
      expect(
        result.map((CatalogSizeValue v) => v.token),
        containsAll(<String>['S', 'M', 'L']),
      );
    });
  });
}
