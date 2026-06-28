import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/data/cart/cart_mapper.dart';
import 'package:klozy/src/domain/cart/entity/cart_item.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Map<String, dynamic> _item({
  String productId = 'prod-1',
  String title = 'Air Max',
  num listPrice = 80,
  num? effectivePrice,
  String brand = 'Nike',
  String size = '42',
  String? image = 'https://cdn.example.com/img.jpg',
  String? offerId,
  num? offerAmount,
  String? offerStatus,
  String? bundleId,
  bool addedAfter = false,
}) => <String, dynamic>{
  'productId': productId,
  'product': <String, dynamic>{
    'title': title,
    'brand': brand,
    'size': size,
    if (image != null) 'image': image,
  },
  'listPrice': listPrice,
  if (effectivePrice != null) 'effectivePrice': effectivePrice,
  if (offerId != null) 'offerId': offerId,
  if (offerAmount != null) 'offerAmount': offerAmount,
  if (offerStatus != null) 'offerStatus': offerStatus,
  if (bundleId != null) 'bundleId': bundleId,
  'addedAfter': addedAfter,
};

Map<String, dynamic> _seller({
  String id = 'seller-1',
  String name = 'Alice',
  String? avatar = 'https://cdn.example.com/alice.jpg',
  bool isPro = true,
}) => <String, dynamic>{
  'id': id,
  'displayName': name,
  if (avatar != null) 'avatarUrl': avatar,
  'isPro': isPro,
};

Map<String, dynamic> _bucket({
  Map<String, dynamic>? seller,
  List<Map<String, dynamic>>? items,
  List<Map<String, dynamic>>? bundles,
  num? subtotal,
  bool canBundle = false,
}) => <String, dynamic>{
  'seller': seller ?? _seller(),
  'items': items ?? <dynamic>[_item()],
  if (bundles != null) 'bundles': bundles,
  if (subtotal != null) 'subtotal': subtotal,
  'canBundle': canBundle,
};

Map<String, dynamic> _cart({List<Map<String, dynamic>>? buckets}) =>
    <String, dynamic>{
      'buckets': buckets ?? <dynamic>[_bucket()],
    };

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Null / empty input
  // -------------------------------------------------------------------------

  group('mapCart — null/empty input', () {
    test('null returns Cart.empty', () {
      final cart = mapCart(null);
      expect(cart.isEmpty, isTrue);
    });

    test('empty map returns Cart.empty', () {
      final cart = mapCart(const <String, dynamic>{});
      expect(cart.isEmpty, isTrue);
    });

    test('non-list buckets key returns Cart.empty', () {
      final cart = mapCart(<String, dynamic>{'buckets': 'not-a-list'});
      expect(cart.isEmpty, isTrue);
    });

    test('buckets with no items are filtered out', () {
      final raw = <String, dynamic>{
        'buckets': <dynamic>[
          <String, dynamic>{'seller': _seller(), 'items': <dynamic>[]},
        ],
      };
      expect(mapCart(raw).isEmpty, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // Data envelope unwrapping
  // -------------------------------------------------------------------------

  group('mapCart — data envelope', () {
    test('unwraps data key when present', () {
      final raw = <String, dynamic>{'data': _cart()};
      expect(mapCart(raw).buckets, hasLength(1));
    });

    test('falls back to sellers key when buckets absent', () {
      final raw = <String, dynamic>{
        'sellers': <dynamic>[_bucket()],
      };
      expect(mapCart(raw).buckets, hasLength(1));
    });

    test('falls back to items key', () {
      final raw = <String, dynamic>{
        'items': <dynamic>[_bucket()],
      };
      expect(mapCart(raw).buckets, hasLength(1));
    });
  });

  // -------------------------------------------------------------------------
  // CartBucket fields
  // -------------------------------------------------------------------------

  group('CartBucket — standard fields', () {
    late final dynamic bucket;
    setUpAll(() => bucket = mapCart(_cart()).buckets.first);

    test('sellerId', () => expect(bucket.sellerId, 'seller-1'));
    test('sellerName', () => expect(bucket.sellerName, 'Alice'));
    test(
      'sellerAvatar',
      () => expect(bucket.sellerAvatar, 'https://cdn.example.com/alice.jpg'),
    );
    test('isPro', () => expect(bucket.isPro, isTrue));
    test('items length', () => expect(bucket.items, hasLength(1)));
    test('canBundle false', () => expect(bucket.canBundle, isFalse));
  });

  group('CartBucket — sellerId from sellerId key', () {
    test('reads sellerId when seller object has no id', () {
      final raw = <String, dynamic>{
        'buckets': <dynamic>[
          <String, dynamic>{
            'sellerId': 'fallback-seller',
            'seller': const <String, dynamic>{},
            'items': <dynamic>[_item()],
          },
        ],
      };
      expect(mapCart(raw).buckets.first.sellerId, 'fallback-seller');
    });
  });

  group('CartBucket — seller _id key', () {
    test('reads _id from seller', () {
      final raw = _cart(
        buckets: <Map<String, dynamic>>[
          _bucket(
            seller: <String, dynamic>{'_id': 'alt-id', 'displayName': 'Bob'},
          ),
        ],
      );
      expect(mapCart(raw).buckets.first.sellerId, 'alt-id');
    });
  });

  group('CartBucket — isPro from pro key', () {
    test('isPro true when pro == true', () {
      final raw = _cart(
        buckets: <Map<String, dynamic>>[
          _bucket(
            seller: <String, dynamic>{
              'id': 's1',
              'displayName': 'X',
              'pro': true,
            },
          ),
        ],
      );
      expect(mapCart(raw).buckets.first.isPro, isTrue);
    });
  });

  group('CartBucket — subtotal computed from items when absent', () {
    test('subtotal falls back to sum of item effectivePrices', () {
      final raw = _cart(
        buckets: <Map<String, dynamic>>[
          <String, dynamic>{
            'seller': _seller(),
            'items': <dynamic>[
              _item(listPrice: 60, effectivePrice: 50),
              _item(productId: 'p2', listPrice: 40, effectivePrice: 30),
            ],
          },
        ],
      );
      expect(mapCart(raw).buckets.first.subtotal, 80);
    });

    test('explicit subtotal is used when present', () {
      final raw = _cart(
        buckets: <Map<String, dynamic>>[_bucket(subtotal: 999)],
      );
      expect(mapCart(raw).buckets.first.subtotal, 999);
    });
  });

  group('CartBucket — canBundle', () {
    test('canBundle true', () {
      final raw = _cart(
        buckets: <Map<String, dynamic>>[_bucket(canBundle: true)],
      );
      expect(mapCart(raw).buckets.first.canBundle, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // CartItem fields
  // -------------------------------------------------------------------------

  group('CartItem — standard fields', () {
    late final dynamic item;
    setUpAll(() => item = mapCart(_cart()).buckets.first.items.first);

    test('productId', () => expect(item.productId, 'prod-1'));
    test('title', () => expect(item.title, 'Air Max'));
    test('brand', () => expect(item.brand, 'Nike'));
    test('size', () => expect(item.size, '42'));
    test('image', () => expect(item.image, 'https://cdn.example.com/img.jpg'));
    test('price', () => expect(item.price, 80));
    test(
      'effectivePrice defaults to price',
      () => expect(item.effectivePrice, 80),
    );
    test(
      'offerStatus none',
      () => expect(item.offerStatus, CartOfferStatus.none),
    );
    test('bundleId null', () => expect(item.bundleId, isNull));
    test('addedAfter false', () => expect(item.addedAfter, isFalse));
  });

  group('CartItem — offer fields', () {
    test('offerId and offerAmount forwarded', () {
      final raw = _cart(
        buckets: <Map<String, dynamic>>[
          _bucket(
            items: <Map<String, dynamic>>[
              _item(offerId: 'off-1', offerAmount: 65, offerStatus: 'pending'),
            ],
          ),
        ],
      );
      final item = mapCart(raw).buckets.first.items.first;
      expect(item.offerId, 'off-1');
      expect(item.offerAmount, 65);
      expect(item.offerStatus, CartOfferStatus.pending);
    });

    test('offerStatus accepted', () {
      final raw = _cart(
        buckets: <Map<String, dynamic>>[
          _bucket(
            items: <Map<String, dynamic>>[_item(offerStatus: 'accepted')],
          ),
        ],
      );
      expect(
        mapCart(raw).buckets.first.items.first.offerStatus,
        CartOfferStatus.accepted,
      );
    });

    test('offerStatus declined from refused', () {
      final raw = _cart(
        buckets: <Map<String, dynamic>>[
          _bucket(items: <Map<String, dynamic>>[_item(offerStatus: 'refused')]),
        ],
      );
      expect(
        mapCart(raw).buckets.first.items.first.offerStatus,
        CartOfferStatus.declined,
      );
    });

    test('offerStatus declined from declined', () {
      final raw = _cart(
        buckets: <Map<String, dynamic>>[
          _bucket(
            items: <Map<String, dynamic>>[_item(offerStatus: 'declined')],
          ),
        ],
      );
      expect(
        mapCart(raw).buckets.first.items.first.offerStatus,
        CartOfferStatus.declined,
      );
    });
  });

  group('CartItem — bundleId', () {
    test('bundleId forwarded', () {
      final raw = _cart(
        buckets: <Map<String, dynamic>>[
          _bucket(items: <Map<String, dynamic>>[_item(bundleId: 'bundle-1')]),
        ],
      );
      expect(mapCart(raw).buckets.first.items.first.bundleId, 'bundle-1');
    });
  });

  group('CartItem — addedAfter', () {
    test('addedAfter true', () {
      final raw = _cart(
        buckets: <Map<String, dynamic>>[
          _bucket(items: <Map<String, dynamic>>[_item(addedAfter: true)]),
        ],
      );
      expect(mapCart(raw).buckets.first.items.first.addedAfter, isTrue);
    });
  });

  group('CartItem — effectivePrice explicit', () {
    test('effectivePrice overrides price', () {
      final raw = _cart(
        buckets: <Map<String, dynamic>>[
          _bucket(
            items: <Map<String, dynamic>>[
              _item(listPrice: 80, effectivePrice: 60),
            ],
          ),
        ],
      );
      final item = mapCart(raw).buckets.first.items.first;
      expect(item.price, 80);
      expect(item.effectivePrice, 60);
    });
  });

  // -------------------------------------------------------------------------
  // Brand resolution
  // -------------------------------------------------------------------------

  group('CartItem — brand resolution', () {
    test('brand from product.brand map {name}', () {
      final raw = _cart(
        buckets: <Map<String, dynamic>>[
          _bucket(
            items: <Map<String, dynamic>>[
              <String, dynamic>{
                'productId': 'p1',
                'product': <String, dynamic>{
                  'title': 'T',
                  'brand': <String, dynamic>{'name': 'Adidas'},
                },
                'listPrice': 10,
              },
            ],
          ),
        ],
      );
      expect(mapCart(raw).buckets.first.items.first.brand, 'Adidas');
    });

    test('brand from brandName key', () {
      final raw = _cart(
        buckets: <Map<String, dynamic>>[
          _bucket(
            items: <Map<String, dynamic>>[
              <String, dynamic>{
                'productId': 'p1',
                'product': <String, dynamic>{'title': 'T', 'brandName': 'Puma'},
                'listPrice': 10,
              },
            ],
          ),
        ],
      );
      expect(mapCart(raw).buckets.first.items.first.brand, 'Puma');
    });
  });

  // -------------------------------------------------------------------------
  // Cover image resolution
  // -------------------------------------------------------------------------

  group('CartItem — cover image resolution', () {
    test('images list → first string element', () {
      final raw = _cart(
        buckets: <Map<String, dynamic>>[
          _bucket(
            items: <Map<String, dynamic>>[
              <String, dynamic>{
                'productId': 'p1',
                'product': <String, dynamic>{
                  'title': 'T',
                  'images': <dynamic>['https://cdn.example.com/first.jpg'],
                },
                'listPrice': 10,
              },
            ],
          ),
        ],
      );
      expect(
        mapCart(raw).buckets.first.items.first.image,
        'https://cdn.example.com/first.jpg',
      );
    });

    test('images list → first object with url key', () {
      final raw = _cart(
        buckets: <Map<String, dynamic>>[
          _bucket(
            items: <Map<String, dynamic>>[
              <String, dynamic>{
                'productId': 'p1',
                'product': <String, dynamic>{
                  'title': 'T',
                  'images': <dynamic>[
                    <String, dynamic>{'url': 'https://cdn.example.com/obj.jpg'},
                  ],
                },
                'listPrice': 10,
              },
            ],
          ),
        ],
      );
      expect(
        mapCart(raw).buckets.first.items.first.image,
        'https://cdn.example.com/obj.jpg',
      );
    });

    test('falls back to coverImage key', () {
      final raw = _cart(
        buckets: <Map<String, dynamic>>[
          _bucket(
            items: <Map<String, dynamic>>[
              <String, dynamic>{
                'productId': 'p1',
                'product': <String, dynamic>{
                  'title': 'T',
                  'coverImage': 'https://cdn.example.com/cv.jpg',
                },
                'listPrice': 10,
              },
            ],
          ),
        ],
      );
      expect(
        mapCart(raw).buckets.first.items.first.image,
        'https://cdn.example.com/cv.jpg',
      );
    });
  });

  // -------------------------------------------------------------------------
  // CartBundle
  // -------------------------------------------------------------------------

  group('CartBundle', () {
    late final dynamic bundle;
    setUpAll(() {
      final raw = _cart(
        buckets: <Map<String, dynamic>>[
          _bucket(
            bundles: <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'bnd-1',
                'amount': 150,
                'status': 'pending',
                'productIds': <dynamic>['p1', 'p2'],
                'listSum': 200,
              },
            ],
          ),
        ],
      );
      bundle = mapCart(raw).buckets.first.bundles.first;
    });

    test('id', () => expect(bundle.id, 'bnd-1'));
    test('amount', () => expect(bundle.amount, 150));
    test(
      'status pending',
      () => expect(bundle.status, CartOfferStatus.pending),
    );
    test('productIds', () => expect(bundle.productIds, <String>['p1', 'p2']));
    test('listSum', () => expect(bundle.listSum, 200));
  });

  group('CartBundle — status variants', () {
    CartOfferStatus bundleStatus(String status) {
      final raw = _cart(
        buckets: <Map<String, dynamic>>[
          _bucket(
            bundles: <Map<String, dynamic>>[
              <String, dynamic>{
                '_id': 'b',
                'amount': 1,
                'status': status,
                'listSum': 0,
              },
            ],
          ),
        ],
      );
      return mapCart(raw).buckets.first.bundles.first.status;
    }

    test(
      'accepted',
      () => expect(bundleStatus('accepted'), CartOfferStatus.accepted),
    );
    test(
      'declined',
      () => expect(bundleStatus('declined'), CartOfferStatus.declined),
    );
    test(
      'refused',
      () => expect(bundleStatus('refused'), CartOfferStatus.declined),
    );
    test(
      'unknown → none',
      () => expect(bundleStatus('other'), CartOfferStatus.none),
    );
  });

  group('CartBundle — empty productIds', () {
    test('productIds is empty list when key absent', () {
      final raw = _cart(
        buckets: <Map<String, dynamic>>[
          _bucket(
            bundles: <Map<String, dynamic>>[
              <String, dynamic>{'_id': 'b', 'amount': 0, 'listSum': 0},
            ],
          ),
        ],
      );
      expect(mapCart(raw).buckets.first.bundles.first.productIds, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // productId fallback from product object
  // -------------------------------------------------------------------------

  group('CartItem — productId fallback from product.id', () {
    test('reads product.id when productId absent', () {
      final raw = _cart(
        buckets: <Map<String, dynamic>>[
          _bucket(
            items: <Map<String, dynamic>>[
              <String, dynamic>{
                'product': <String, dynamic>{
                  'id': 'inner-prod-id',
                  'title': 'T',
                },
                'listPrice': 10,
              },
            ],
          ),
        ],
      );
      expect(mapCart(raw).buckets.first.items.first.productId, 'inner-prod-id');
    });
  });
}
