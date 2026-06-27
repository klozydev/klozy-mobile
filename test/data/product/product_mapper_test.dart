import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/data/product/product_mapper.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _fullProduct() => <String, dynamic>{
  'id': 'prod-1',
  'title': 'Air Max 90',
  'price': 120,
  'brand': <String, dynamic>{'name': 'Nike'},
  'size': '42',
  'condition': <String, dynamic>{'label': 'Very Good'},
  'images': <dynamic>[
    <String, dynamic>{'url': 'https://cdn.example.com/a.jpg'},
    'https://cdn.example.com/b.jpg',
  ],
  'likes': 15,
  'status': 'ACTIVE',
  'sold': false,
  'reserved': false,
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Null / empty input
  // -------------------------------------------------------------------------

  group('mapProduct — null/empty input', () {
    test('null returns safe defaults', () {
      final p = mapProduct(null);
      expect(p.id, isEmpty);
      expect(p.title, isEmpty);
      expect(p.price, 0);
      expect(p.brand, isEmpty);
      expect(p.size, isEmpty);
      expect(p.coverImageUrl, isNull);
      expect(p.conditionLabel, isNull);
      expect(p.likes, 0);
      expect(p.isSold, isFalse);
      expect(p.isReserved, isFalse);
      expect(p.isNewWithTags, isFalse);
    });

    test('empty map returns safe defaults', () {
      final p = mapProduct(const <String, dynamic>{});
      expect(p.id, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // Standard fields
  // -------------------------------------------------------------------------

  group('mapProduct — standard fields', () {
    late final dynamic p;
    setUpAll(() => p = mapProduct(_fullProduct()));

    test('id', () => expect(p.id, 'prod-1'));
    test('title', () => expect(p.title, 'Air Max 90'));
    test('price', () => expect(p.price, 120));
    test('brand from object', () => expect(p.brand, 'Nike'));
    test('size', () => expect(p.size, '42'));
    test(
      'coverImageUrl from images list (object url)',
      () => expect(p.coverImageUrl, 'https://cdn.example.com/a.jpg'),
    );
    test(
      'conditionLabel from object',
      () => expect(p.conditionLabel, 'Very Good'),
    );
    test('likes', () => expect(p.likes, 15));
    test('isSold false', () => expect(p.isSold, isFalse));
    test('isReserved false', () => expect(p.isReserved, isFalse));
    test('isNewWithTags false', () => expect(p.isNewWithTags, isFalse));
  });

  // -------------------------------------------------------------------------
  // id alternatives
  // -------------------------------------------------------------------------

  group('mapProduct — id alternatives', () {
    test('reads _id when id absent', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..remove('id')
        ..['_id'] = 'alt-id';
      expect(mapProduct(raw).id, 'alt-id');
    });
  });

  // -------------------------------------------------------------------------
  // Title alternatives
  // -------------------------------------------------------------------------

  group('mapProduct — title alternatives', () {
    test('reads name key when title absent', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..remove('title')
        ..['name'] = 'Jordan 1';
      expect(mapProduct(raw).title, 'Jordan 1');
    });
  });

  // -------------------------------------------------------------------------
  // Price alternatives
  // -------------------------------------------------------------------------

  group('mapProduct — price alternatives', () {
    test('reads amount key when price absent', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..remove('price')
        ..['amount'] = 99;
      expect(mapProduct(raw).price, 99);
    });

    test('price as numeric string is parsed', () {
      final raw = Map<String, dynamic>.from(_fullProduct())..['price'] = '150';
      expect(mapProduct(raw).price, 150);
    });
  });

  // -------------------------------------------------------------------------
  // Brand resolution
  // -------------------------------------------------------------------------

  group('mapProduct — brand resolution', () {
    test('brand from flat string', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..['brand'] = 'Adidas';
      expect(mapProduct(raw).brand, 'Adidas');
    });

    test('brand from object label key', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..['brand'] = <String, dynamic>{'label': 'Puma'};
      expect(mapProduct(raw).brand, 'Puma');
    });

    test('brand from brandName key', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..remove('brand')
        ..['brandName'] = 'Reebok';
      expect(mapProduct(raw).brand, 'Reebok');
    });

    test('brand empty when brand absent', () {
      final raw = Map<String, dynamic>.from(_fullProduct())..remove('brand');
      expect(mapProduct(raw).brand, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // Condition resolution
  // -------------------------------------------------------------------------

  group('mapProduct — condition resolution', () {
    test('conditionLabel from flat string', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..['condition'] = 'Good';
      expect(mapProduct(raw).conditionLabel, 'Good');
    });

    test('conditionLabel from object name key', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..['condition'] = <String, dynamic>{'name': 'Like New'};
      expect(mapProduct(raw).conditionLabel, 'Like New');
    });

    test('conditionLabel from conditionLabel top-level key', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..remove('condition')
        ..['conditionLabel'] = 'Fair';
      expect(mapProduct(raw).conditionLabel, 'Fair');
    });

    test('conditionLabel null when absent', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..remove('condition');
      expect(mapProduct(raw).conditionLabel, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Cover image resolution
  // -------------------------------------------------------------------------

  group('mapProduct — coverImageUrl resolution', () {
    test('images list → first string element', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..['images'] = <dynamic>['https://cdn.example.com/first.jpg'];
      expect(
        mapProduct(raw).coverImageUrl,
        'https://cdn.example.com/first.jpg',
      );
    });

    test('images list → first object with src key', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..['images'] = <dynamic>[
          <String, dynamic>{'src': 'https://cdn.example.com/src.jpg'},
        ];
      expect(mapProduct(raw).coverImageUrl, 'https://cdn.example.com/src.jpg');
    });

    test('falls back to coverImage key', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..remove('images')
        ..['coverImage'] = 'https://cdn.example.com/cv.jpg';
      expect(mapProduct(raw).coverImageUrl, 'https://cdn.example.com/cv.jpg');
    });

    test('falls back to coverImageUrl key', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..remove('images')
        ..['coverImageUrl'] = 'https://cdn.example.com/cvurl.jpg';
      expect(
        mapProduct(raw).coverImageUrl,
        'https://cdn.example.com/cvurl.jpg',
      );
    });

    test('falls back to image key', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..remove('images')
        ..['image'] = 'https://cdn.example.com/img.jpg';
      expect(mapProduct(raw).coverImageUrl, 'https://cdn.example.com/img.jpg');
    });

    test('falls back to thumbnail key', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..remove('images')
        ..['thumbnail'] = 'https://cdn.example.com/thumb.jpg';
      expect(
        mapProduct(raw).coverImageUrl,
        'https://cdn.example.com/thumb.jpg',
      );
    });

    test('null when images empty and no fallback', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..['images'] = <dynamic>[];
      expect(mapProduct(raw).coverImageUrl, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // isSold / isReserved
  // -------------------------------------------------------------------------

  group('mapProduct — isSold', () {
    test('SOLD status → isSold', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..['status'] = 'SOLD';
      expect(mapProduct(raw).isSold, isTrue);
    });

    test('sold: true flag → isSold', () {
      final raw = Map<String, dynamic>.from(_fullProduct())..['sold'] = true;
      expect(mapProduct(raw).isSold, isTrue);
    });

    test('not sold when status ACTIVE', () {
      expect(mapProduct(_fullProduct()).isSold, isFalse);
    });
  });

  group('mapProduct — isReserved', () {
    test('RESERVED status → isReserved', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..['status'] = 'RESERVED';
      expect(mapProduct(raw).isReserved, isTrue);
    });

    test('reserved: true flag → isReserved', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..['reserved'] = true;
      expect(mapProduct(raw).isReserved, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // isNewWithTags
  // -------------------------------------------------------------------------

  group('mapProduct — isNewWithTags', () {
    test('condition label contains "new with tag"', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..['condition'] = 'New With Tags';
      expect(mapProduct(raw).isNewWithTags, isTrue);
    });

    test('conditionSlug contains "newwithtag"', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..['conditionSlug'] = 'newwithtag';
      expect(mapProduct(raw).isNewWithTags, isTrue);
    });

    test('unrelated condition → false', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..['condition'] = 'Good';
      expect(mapProduct(raw).isNewWithTags, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // likes alternatives
  // -------------------------------------------------------------------------

  group('mapProduct — likes', () {
    test('likeCount key', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..remove('likes')
        ..['likeCount'] = 5;
      expect(mapProduct(raw).likes, 5);
    });

    test('likesCount key', () {
      final raw = Map<String, dynamic>.from(_fullProduct())
        ..remove('likes')
        ..['likesCount'] = 7;
      expect(mapProduct(raw).likes, 7);
    });

    test('likes absent → 0', () {
      final raw = Map<String, dynamic>.from(_fullProduct())..remove('likes');
      expect(mapProduct(raw).likes, 0);
    });
  });
}
