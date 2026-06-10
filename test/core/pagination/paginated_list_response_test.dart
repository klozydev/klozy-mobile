import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/pagination/paginated_list_response.dart';

void main() {
  // Real envelope from the live API (products.service.ts PaginatedProducts):
  // every paginated endpoint wraps the list in `items`, with flat
  // page/limit/total alongside.
  const liveEnvelope = <String, dynamic>{
    'items': <dynamic>[
      <String, dynamic>{'id': 'p1'},
      <String, dynamic>{'id': 'p2'},
    ],
    'page': 1,
    'limit': 20,
    'total': 2,
    'pickedForYou': <dynamic>['Dresses'],
  };

  String mapId(Object? json) => (json! as Map<String, dynamic>)['id'] as String;

  test('parses the live {items, page, limit, total} envelope', () {
    final parsed = PaginatedListResponse<String>.fromJson(liveEnvelope, mapId);
    expect(parsed.data, <String>['p1', 'p2']);
  });

  test('still accepts a {data: [...]} envelope', () {
    final parsed = PaginatedListResponse<String>.fromJson(
      const <String, dynamic>{
        'data': <dynamic>[
          <String, dynamic>{'id': 'p1'},
        ],
      },
      mapId,
    );
    expect(parsed.data, <String>['p1']);
  });

  test('empty/unknown envelope yields an empty list', () {
    final parsed = PaginatedListResponse<String>.fromJson(
      const <String, dynamic>{},
      mapId,
    );
    expect(parsed.data, isEmpty);
  });
}
