import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/data/product/product_detail_mapper.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Full response envelope as the REST API sends it:
  /// GET /v1/products/{id} → { data: { ...product... } }
  Map<String, dynamic> envelope(Map<String, dynamic> product) =>
      <String, dynamic>{'data': product};

  Map<String, dynamic> fullProduct() => <String, dynamic>{
    'id': 'prod-123',
    'title': 'Nike Air Max 90',
    'price': 85,
    'description': 'Great condition pair of sneakers.',
    'location': 'Paris, France',
    'createdAt': '2024-01-15T10:00:00.000Z',
    'status': 'ACTIVE',
    'likes': 12,
    'views': 340,
    'isOwner': false,
    'size': '42',
    'brand': <String, dynamic>{'name': 'Nike'},
    'condition': <String, dynamic>{'label': 'Very Good'},
    'images': <dynamic>[
      <String, dynamic>{'url': 'https://cdn.example.com/a.jpg'},
      <String, dynamic>{'url': 'https://cdn.example.com/b.jpg'},
      'https://cdn.example.com/c.jpg',
    ],
    'seller': <String, dynamic>{
      'id': 'user-456',
      'handle': 'john_doe',
      'displayName': 'John Doe',
      'avatarUrl': 'https://cdn.example.com/avatar.jpg',
      'isPro': true,
      'rating': 4.8,
      'reviewCount': 23,
    },
  };

  // ---------------------------------------------------------------------------
  // Root-cause regression: envelope unwrapping
  // ---------------------------------------------------------------------------

  group('envelope unwrapping (root-cause fix)', () {
    test('bare object (no envelope) still parses correctly', () {
      final detail = mapProductDetail(fullProduct());
      expect(detail.id, 'prod-123');
      expect(detail.title, 'Nike Air Max 90');
    });

    test(
      'mapProductDetail on a {data:{...}} envelope returns empty entity',
      () {
        // This test documents the pre-fix behaviour: the mapper itself only
        // receives the inner product map (unwrapping happens in the repo).
        // Passing the *envelope* to the mapper must produce empty defaults so
        // callers can detect the bug.
        final envelop = envelope(fullProduct());
        final detail = mapProductDetail(envelop);
        // The envelope map has no 'title', 'price', etc. at the top level.
        expect(detail.title, isEmpty);
        expect(detail.price, 0);
        expect(detail.images, isEmpty);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Field mapping
  // ---------------------------------------------------------------------------

  group('mapProductDetail — standard fields', () {
    late ProductDetail detail;
    setUp(() => detail = mapProductDetail(fullProduct()));

    test('id', () => expect(detail.id, 'prod-123'));
    test('title', () => expect(detail.title, 'Nike Air Max 90'));
    test('price', () => expect(detail.price, 85));
    test(
      'description',
      () => expect(detail.description, 'Great condition pair of sneakers.'),
    );
    test('location', () => expect(detail.location, 'Paris, France'));
    test('size', () => expect(detail.size, '42'));
    test(
      'status defaults to active',
      () => expect(detail.status, ProductStatus.active),
    );
    test('likes', () => expect(detail.likes, 12));
    test('views', () => expect(detail.views, 340));
    test('isOwner false', () => expect(detail.isOwner, isFalse));
  });

  group('mapProductDetail — price alternatives', () {
    test('price as numeric string is parsed', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..['price'] = '150';
      expect(mapProductDetail(product).price, 150);
    });
  });

  group('mapProductDetail — brand', () {
    test('brand from object {name}', () {
      final detail = mapProductDetail(fullProduct());
      expect(detail.brand, 'Nike');
    });

    test('brand from flat string', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..['brand'] = 'Adidas';
      expect(mapProductDetail(product).brand, 'Adidas');
    });

    test('brand from brandName key when brand is absent', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..remove('brand')
        ..['brandName'] = 'Puma';
      expect(mapProductDetail(product).brand, 'Puma');
    });
  });

  group('mapProductDetail — condition', () {
    test(
      'conditionLabel from object {label} (no top-level conditionLabel)',
      () {
        final detail = mapProductDetail(fullProduct());
        expect(detail.conditionLabel, 'Very Good');
      },
    );

    test('conditionLabel from flat string (no top-level conditionLabel)', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..['condition'] = 'Good';
      expect(mapProductDetail(product).conditionLabel, 'Good');
    });

    test('conditionLabel null when condition and conditionLabel absent', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..remove('condition');
      expect(mapProductDetail(product).conditionLabel, isNull);
    });

    test(
      'top-level conditionLabel (localized) is preferred over condition object',
      () {
        final product = Map<String, dynamic>.from(fullProduct())
          ..['conditionLabel'] = 'Muy bueno';
        // 'condition' object {'label': 'Very Good'} is still present but the
        // localized top-level field wins.
        expect(mapProductDetail(product).conditionLabel, 'Muy bueno');
      },
    );

    test(
      'top-level conditionLabel is used even when condition is only the raw slug',
      () {
        final product = Map<String, dynamic>.from(fullProduct())
          ..['condition'] = 'veryGood'
          ..['conditionLabel'] = 'Very Good';
        expect(mapProductDetail(product).conditionLabel, 'Very Good');
      },
    );

    test('falls back to raw condition slug when conditionLabel is absent', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..remove('condition')
        ..['condition'] = 'veryGood';
      expect(mapProductDetail(product).conditionLabel, 'veryGood');
    });
  });

  group('mapProductDetail — size', () {
    test('falls back to raw size token when sizeLabel is absent', () {
      final detail = mapProductDetail(fullProduct());
      expect(detail.size, '42');
    });

    test('prefers localized sizeLabel over the raw size token', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..['size'] = 'years_3_4'
        ..['sizeLabel'] = '3-4 years';
      expect(mapProductDetail(product).size, '3-4 years');
    });

    test('empty string when both sizeLabel and size are absent', () {
      final product = Map<String, dynamic>.from(fullProduct())..remove('size');
      expect(mapProductDetail(product).size, isEmpty);
    });
  });

  group('mapProductDetail — images', () {
    test('all three images are parsed', () {
      final detail = mapProductDetail(fullProduct());
      expect(detail.images, <String>[
        'https://cdn.example.com/a.jpg',
        'https://cdn.example.com/b.jpg',
        'https://cdn.example.com/c.jpg',
      ]);
    });

    test('empty list when images key is absent', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..remove('images');
      expect(mapProductDetail(product).images, isEmpty);
    });

    test('image objects with src key are resolved', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..['images'] = <dynamic>[
          <String, dynamic>{'src': 'https://cdn.example.com/x.jpg'},
        ];
      expect(mapProductDetail(product).images, <String>[
        'https://cdn.example.com/x.jpg',
      ]);
    });
  });

  group('mapProductDetail — seller', () {
    late ProductSeller seller;
    setUp(() => seller = mapProductDetail(fullProduct()).seller);

    test('id', () => expect(seller.id, 'user-456'));
    test('displayName', () => expect(seller.displayName, 'John Doe'));
    test(
      'avatarUrl',
      () => expect(seller.avatarUrl, 'https://cdn.example.com/avatar.jpg'),
    );
    test('isPro', () => expect(seller.isPro, isTrue));
    test('rating', () => expect(seller.rating, closeTo(4.8, 0.001)));
    test('reviewCount', () => expect(seller.reviewCount, 23));
  });

  group('mapProductDetail — seller missing', () {
    test('seller falls back to empty defaults when key absent', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..remove('seller');
      final seller = mapProductDetail(product).seller;
      expect(seller.id, isEmpty);
      expect(seller.displayName, isEmpty);
      expect(seller.avatarUrl, isNull);
    });
  });

  group('mapProductDetail — status', () {
    test('SOLD maps to sold', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..['status'] = 'SOLD';
      expect(mapProductDetail(product).status, ProductStatus.sold);
    });

    test('RESERVED maps to reserved', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..['status'] = 'RESERVED';
      expect(mapProductDetail(product).status, ProductStatus.reserved);
    });

    test('unknown status maps to active', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..['status'] = 'SOMETHING_NEW';
      expect(mapProductDetail(product).status, ProductStatus.active);
    });
  });

  group('mapProductDetail — postedLabel', () {
    test('uses postedLabel key when present', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..['postedLabel'] = '3 days ago';
      expect(mapProductDetail(product).postedLabel, '3 days ago');
    });

    test('uses posted key when postedLabel absent', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..remove('postedLabel')
        ..['posted'] = '3 days ago';
      expect(mapProductDetail(product).postedLabel, '3 days ago');
    });

    test(
      'null when postedLabel absent — never derived from createdAt locally',
      () {
        final product = Map<String, dynamic>.from(fullProduct())
          ..remove('postedLabel');
        expect(mapProductDetail(product).postedLabel, isNull);
      },
    );

    test('null when both postedLabel and createdAt are absent', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..remove('postedLabel')
        ..remove('createdAt');
      expect(mapProductDetail(product).postedLabel, isNull);
    });
  });

  group('mapProductDetail — postedAt', () {
    test('parses createdAt into postedAt', () {
      final detail = mapProductDetail(fullProduct());
      expect(detail.postedAt, DateTime.parse('2024-01-15T10:00:00.000Z'));
    });

    test('parses from created key when createdAt absent', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..remove('createdAt')
        ..['created'] = '2024-02-01T00:00:00.000Z';
      expect(
        mapProductDetail(product).postedAt,
        DateTime.parse('2024-02-01T00:00:00.000Z'),
      );
    });

    test('null when createdAt/created absent', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..remove('createdAt');
      expect(mapProductDetail(product).postedAt, isNull);
    });

    test('null when createdAt is unparsable', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..['createdAt'] = 'not-a-date';
      expect(mapProductDetail(product).postedAt, isNull);
    });
  });

  group('mapProductDetail — isOwner', () {
    test('isOwner true from isOwner flag', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..['isOwner'] = true;
      expect(mapProductDetail(product).isOwner, isTrue);
    });

    test('isOwner true from isMine flag', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..remove('isOwner')
        ..['isMine'] = true;
      expect(mapProductDetail(product).isOwner, isTrue);
    });
  });

  group('mapProductDetail — categoryLabel', () {
    test('reads categoryLabel directly when present', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..['categoryLabel'] = 'Pulls';
      expect(mapProductDetail(product).categoryLabel, 'Pulls');
    });

    test('falls back to categorySlug when categoryLabel absent', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..['categorySlug'] = 'sweaters';
      expect(mapProductDetail(product).categoryLabel, 'sweaters');
    });

    test(
      'falls back to category when categoryLabel and categorySlug absent',
      () {
        final product = Map<String, dynamic>.from(fullProduct())
          ..['category'] = 'women';
        expect(mapProductDetail(product).categoryLabel, 'women');
      },
    );

    test('null when categoryLabel, categorySlug and category all absent', () {
      final product = Map<String, dynamic>.from(fullProduct())
        ..remove('categoryLabel')
        ..remove('categorySlug')
        ..remove('category');
      expect(mapProductDetail(product).categoryLabel, isNull);
    });
  });

  group('mapProductDetail — null/empty input', () {
    test('null input returns safe defaults', () {
      final detail = mapProductDetail(null);
      expect(detail.id, isEmpty);
      expect(detail.title, isEmpty);
      expect(detail.price, 0);
      expect(detail.images, isEmpty);
      expect(detail.seller.id, isEmpty);
    });

    test('empty map returns safe defaults', () {
      final detail = mapProductDetail(const <String, dynamic>{});
      expect(detail.id, isEmpty);
      expect(detail.title, isEmpty);
    });
  });
}
