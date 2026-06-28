// test/data/offers/offers_repository_impl_test.dart

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/data/offers/offers_repository_impl.dart';
import 'package:klozy/src/domain/offers/entity/offer.dart';
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
  late OffersRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(Options());
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = _MockDio();
    repo = OffersRepositoryImpl(mockDio);
  });

  // ── listOffers (incoming) ───────────────────────────────────────────────

  group('listOffers incoming', () {
    test('maps bare list with buyer counterpart', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/offers',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/offers', <dynamic>[
          <String, dynamic>{
            'id': 'off1',
            'amount': 150,
            'status': 'PENDING',
            'buyer': <String, dynamic>{
              'displayName': 'Alice',
              'avatarUrl': 'https://example.com/alice.jpg',
            },
            'items': <dynamic>[1, 2],
            'createdAt': '2024-03-01T12:00:00Z',
          },
        ]),
      );

      final List<Offer> result = await repo.listOffers(incoming: true);

      expect(result, hasLength(1));
      expect(result.first.id, 'off1');
      expect(result.first.amount, 150);
      expect(result.first.status, OfferStatus.pending);
      expect(result.first.counterpartName, 'Alice');
      expect(result.first.itemCount, 2);
      expect(result.first.createdAt, isNotNull);
    });

    test('maps ACCEPTED status', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/offers',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/offers', <dynamic>[
          <String, dynamic>{
            'id': 'off2',
            'amount': 200,
            'status': 'ACCEPTED',
            'buyer': <String, dynamic>{'displayName': 'Bob'},
          },
        ]),
      );

      final List<Offer> result = await repo.listOffers(incoming: true);
      expect(result.first.status, OfferStatus.accepted);
    });

    test('maps DECLINED/REFUSED status', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/offers',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/offers', <dynamic>[
          <String, dynamic>{
            '_id': 'off3',
            'amount': 50,
            'status': 'REFUSED',
            'buyer': <String, dynamic>{'name': 'Carol'},
          },
        ]),
      );

      final List<Offer> result = await repo.listOffers(incoming: true);
      expect(result.first.status, OfferStatus.declined);
      expect(result.first.id, 'off3');
      expect(result.first.counterpartName, 'Carol');
    });

    test('maps CANCELLED status', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/offers',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/offers', <dynamic>[
          <String, dynamic>{
            'id': 'off4',
            'amount': 80,
            'status': 'CANCELED',
            'buyer': <String, dynamic>{'displayName': 'Dan'},
          },
        ]),
      );

      final List<Offer> result = await repo.listOffers(incoming: true);
      expect(result.first.status, OfferStatus.cancelled);
    });

    test('maps unknown status to unknown', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/offers',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/offers', <dynamic>[
          <String, dynamic>{
            'id': 'off5',
            'amount': 0,
            'status': 'WEIRD',
            'buyer': <String, dynamic>{'displayName': 'Eve'},
          },
        ]),
      );

      final List<Offer> result = await repo.listOffers(incoming: true);
      expect(result.first.status, OfferStatus.unknown);
    });

    test('reads data envelope with data list', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/offers',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/offers', <String, dynamic>{
          'data': <dynamic>[
            <String, dynamic>{
              'id': 'off6',
              'amount': 100,
              'buyer': <String, dynamic>{'displayName': 'Frank'},
            },
          ],
        }),
      );

      final List<Offer> result = await repo.listOffers(incoming: true);
      expect(result, hasLength(1));
      expect(result.first.id, 'off6');
    });
  });

  // ── listOffers (outgoing) ───────────────────────────────────────────────

  group('listOffers outgoing', () {
    test('uses seller as counterpart for outgoing offers', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/offers',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _ok<dynamic>('v1/offers', <dynamic>[
          <String, dynamic>{
            'id': 'off7',
            'amount': 120,
            'seller': <String, dynamic>{'displayName': 'Seller Steve'},
            'items': <dynamic>[1],
          },
        ]),
      );

      final List<Offer> result = await repo.listOffers(incoming: false);

      expect(result.first.counterpartName, 'Seller Steve');
      expect(result.first.itemCount, 1);
    });

    test('passes outgoing box parameter', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/offers',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _ok<dynamic>('v1/offers', <dynamic>[]));

      await repo.listOffers(incoming: false);

      final VerificationResult verification = verify(
        () => mockDio.get<dynamic>(
          'v1/offers',
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      );
      final Map<String, dynamic> params =
          verification.captured.first as Map<String, dynamic>;
      expect(params['box'], 'outgoing');
    });

    test('passes incoming box parameter', () async {
      when(
        () => mockDio.get<dynamic>(
          'v1/offers',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _ok<dynamic>('v1/offers', <dynamic>[]));

      await repo.listOffers(incoming: true);

      final VerificationResult verification = verify(
        () => mockDio.get<dynamic>(
          'v1/offers',
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      );
      final Map<String, dynamic> params =
          verification.captured.first as Map<String, dynamic>;
      expect(params['box'], 'incoming');
    });
  });

  // ── makeOffer ───────────────────────────────────────────────────────────

  group('makeOffer', () {
    test('posts productIds and amount to v1/offers', () async {
      when(
        () => mockDio.post<dynamic>('v1/offers', data: any(named: 'data')),
      ).thenAnswer((_) async => _voidOk('v1/offers'));

      await repo.makeOffer(productIds: <String>['p1', 'p2'], amount: 250);

      verify(
        () => mockDio.post<dynamic>('v1/offers', data: any(named: 'data')),
      ).called(1);
    });
  });

  // ── cancelOffer ─────────────────────────────────────────────────────────

  group('cancelOffer', () {
    test('calls DELETE v1/offers/:id', () async {
      when(
        () => mockDio.delete<dynamic>('v1/offers/off1'),
      ).thenAnswer((_) async => _voidOk('v1/offers/off1'));

      await repo.cancelOffer('off1');

      verify(() => mockDio.delete<dynamic>('v1/offers/off1')).called(1);
    });
  });

  // ── acceptOffer ─────────────────────────────────────────────────────────

  group('acceptOffer', () {
    test('posts to v1/offers/:id/accept', () async {
      when(
        () => mockDio.post<dynamic>('v1/offers/off1/accept'),
      ).thenAnswer((_) async => _voidOk('v1/offers/off1/accept'));

      await repo.acceptOffer('off1');

      verify(() => mockDio.post<dynamic>('v1/offers/off1/accept')).called(1);
    });
  });

  // ── declineOffer ────────────────────────────────────────────────────────

  group('declineOffer', () {
    test('posts to v1/offers/:id/decline', () async {
      when(
        () => mockDio.post<dynamic>('v1/offers/off1/decline'),
      ).thenAnswer((_) async => _voidOk('v1/offers/off1/decline'));

      await repo.declineOffer('off1');

      verify(() => mockDio.post<dynamic>('v1/offers/off1/decline')).called(1);
    });
  });
}
