import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/data/product/product_detail_mapper.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Full response envelope as the REST API sends it:
  /// GET /v1/products/{id} → { data: { ...product... } }
  Map<String, dynamic> _envelope(Map<String, dynamic> product) =>
      <String, dynamic>{'data': product};

  Map<String, dynamic> _fullProduct() => <String, dynamic>{
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
      final detail = mapProductDetail(_fullProduct());
      expect(detail.id, 'prod-123');
      expect(detail.title, 'Nike Air Max 90');
    });

    test('mapProductDetail on a {data:{...}} envelope returns empty entity', () {
      // This test documents the pre-fix behaviour: the mapper itself only
      // receives the inner product map (unwrapping happens in the repo).
      // Passing the *envelope* to the mapper must produce empty defaults so
      // callers can detect the bug.
      final envelope = _envelope(_fullProduct());
      final detail = mapProductDetail(envelope);
      // The envelope map has no 'title', 'price', etc. at the top level.
      expect(detail.title, isEmpty);
      expect(detail.price, 0);
      expect(detail.images, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // Field mapping
  // ---------------------------------------------------------------------------

  group('mapProductDetail — standard fields', () {
    late ProductDetail detail;
    setUp(() => detail = mapProductDetail(_fullProduct()));

    test('id', () => expect(detail.id, 'prod-123'));
    test('title', () => expect(detail.title, 'Nike Air Max 90'));
    test('price', () => expect(detail.price, 85));
    test('description', () => expect(detail.description, 'Great condition pair of sneakers.'));
    test('location', () => expect(detail.location, 'Paris, France'));
    test('size', () => expect(detail.size, '42'));
    test('status defaults to active', () => expect(detail.status, ProductStatus.active));
    test('likes', () => expect(detail.likes, 12));
    test('views', () => expect(detail.views, 340));
    test('isOwner false', () => expect(detail.isOwner, isFalse));
  });

  group('mapProductDetail — brand', () {
    test('brand from object {name}', () {
      final detail = mapProductDetail(_fullProduct());
      expect(detail.brand, 'Nike');
    });

    test('brand from flat string', () {
      final product = Map<String, dynamic>.from(_fullProduct())
        ..['brand'] = 'Adidas';
      expect(mapProductDetail(product).brand, 'Adidas');
    });

    test('brand from brandName key when brand is absent', () {
      final product = Map<String, dynamic>.from(_fullProduct())
        ..remove('brand')
        ..['brandName'] = 'Puma';
      expect(mapProductDetail(product).brand, 'Puma');
    });
  });

  group('mapProductDetail — condition', () {
    test('conditionLabel from object {label}', () {
      final detail = mapProductDetail(_fullProduct());
      expect(detail.conditionLabel, 'Very Good');
    });

    test('conditionLabel from flat string', () {
      final product = Map<String, dynamic>.from(_fullProduct())
        ..['condition'] = 'Good';
      expect(mapProductDetail(product).conditionLabel, 'Good');
    });

    test('conditionLabel null when condition absent', () {
      final product = Map<String, dynamic>.from(_fullProduct())
        ..remove('condition');
      expect(mapProductDetail(product).conditionLabel, isNull);
    });
  });

  group('mapProductDetail — images', () {
    test('all three images are parsed', () {
      final detail = mapProductDetail(_fullProduct());
      expect(detail.images, <String>[
        'https://cdn.example.com/a.jpg',
        'https://cdn.example.com/b.jpg',
        'https://cdn.example.com/c.jpg',
      ]);
    });

    test('empty list when images key is absent', () {
      final product = Map<String, dynamic>.from(_fullProduct())
        ..remove('images');
      expect(mapProductDetail(product).images, isEmpty);
    });

    test('image objects with src key are resolved', () {
      final product = Map<String, dynamic>.from(_fullProduct())
        ..['images'] = <dynamic>[
          <String, dynamic>{'src': 'https://cdn.example.com/x.jpg'},
        ];
      expect(mapProductDetail(product).images, <String>['https://cdn.example.com/x.jpg']);
    });
  });

  group('mapProductDetail — seller', () {
    late ProductSeller seller;
    setUp(() => seller = mapProductDetail(_fullProduct()).seller);

    test('id', () => expect(seller.id, 'user-456'));
    test('displayName', () => expect(seller.displayName, 'John Doe'));
    test('avatarUrl', () => expect(seller.avatarUrl, 'https://cdn.example.com/avatar.jpg'));
    test('isPro', () => expect(seller.isPro, isTrue));
    test('rating', () => expect(seller.rating, closeTo(4.8, 0.001)));
    test('reviewCount', () => expect(seller.reviewCount, 23));
  });

  group('mapProductDetail — seller missing', () {
    test('seller falls back to empty defaults when key absent', () {
      final product = Map<String, dynamic>.from(_fullProduct())
        ..remove('seller');
      final seller = mapProductDetail(product).seller;
      expect(seller.id, isEmpty);
      expect(seller.displayName, isEmpty);
      expect(seller.avatarUrl, isNull);
    });
  });

  group('mapProductDetail — status', () {
    test('SOLD maps to sold', () {
      final product = Map<String, dynamic>.from(_fullProduct())
        ..['status'] = 'SOLD';
      expect(mapProductDetail(product).status, ProductStatus.sold);
    });

    test('RESERVED maps to reserved', () {
      final product = Map<String, dynamic>.from(_fullProduct())
        ..['status'] = 'RESERVED';
      expect(mapProductDetail(product).status, ProductStatus.reserved);
    });

    test('unknown status maps to active', () {
      final product = Map<String, dynamic>.from(_fullProduct())
        ..['status'] = 'SOMETHING_NEW';
      expect(mapProductDetail(product).status, ProductStatus.active);
    });
  });

  group('mapProductDetail — postedLabel', () {
    test('uses postedLabel key when present', () {
      final product = Map<String, dynamic>.from(_fullProduct())
        ..['postedLabel'] = '3 days ago';
      expect(mapProductDetail(product).postedLabel, '3 days ago');
    });

    test('derives time-ago from createdAt when postedLabel absent', () {
      final recent = DateTime.now().subtract(const Duration(hours: 2)).toIso8601String();
      final product = Map<String, dynamic>.from(_fullProduct())
        ..remove('postedLabel')
        ..['createdAt'] = recent;
      expect(mapProductDetail(product).postedLabel, matches(RegExp(r'^\d+h ago$')));
    });

    test('null when both postedLabel and createdAt are absent', () {
      final product = Map<String, dynamic>.from(_fullProduct())
        ..remove('postedLabel')
        ..remove('createdAt');
      expect(mapProductDetail(product).postedLabel, isNull);
    });
  });

  group('mapProductDetail — isOwner', () {
    test('isOwner true from isOwner flag', () {
      final product = Map<String, dynamic>.from(_fullProduct())
        ..['isOwner'] = true;
      expect(mapProductDetail(product).isOwner, isTrue);
    });

    test('isOwner true from isMine flag', () {
      final product = Map<String, dynamic>.from(_fullProduct())
        ..remove('isOwner')
        ..['isMine'] = true;
      expect(mapProductDetail(product).isOwner, isTrue);
    });
  });

  group('mapProductDetail — categoryLabel', () {
    test('reads categoryLabel directly when present', () {
      final product = Map<String, dynamic>.from(_fullProduct())
        ..['categoryLabel'] = 'Pulls';
      expect(mapProductDetail(product).categoryLabel, 'Pulls');
    });

    test('falls back to categorySlug when categoryLabel absent', () {
      final product = Map<String, dynamic>.from(_fullProduct())
        ..['categorySlug'] = 'sweaters';
      expect(mapProductDetail(product).categoryLabel, 'sweaters');
    });

    test('falls back to category when categoryLabel and categorySlug absent', () {
      final product = Map<String, dynamic>.from(_fullProduct())
        ..['category'] = 'women';
      expect(mapProductDetail(product).categoryLabel, 'women');
    });

    test('null when categoryLabel, categorySlug and category all absent', () {
      final product = Map<String, dynamic>.from(_fullProduct())
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
