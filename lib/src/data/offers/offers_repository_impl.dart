import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/domain/offers/entity/offer.dart';
import 'package:klozy/src/domain/offers/offers_repository.dart';

@LazySingleton(as: OffersRepository)
class OffersRepositoryImpl implements OffersRepository {
  final Dio _dio;

  OffersRepositoryImpl(this._dio);

  @override
  Future<List<Offer>> listOffers({required bool incoming}) async {
    final response = await _dio.get<dynamic>(
      'v1/offers',
      queryParameters: <String, dynamic>{
        'box': incoming ? 'incoming' : 'outgoing',
      },
    );
    final data = response.data;
    final list = data is List
        ? data
        : (data is Map<String, dynamic> && data['data'] is List
              ? data['data'] as List<dynamic>
              : const <dynamic>[]);
    return list
        .whereType<Map<String, dynamic>>()
        .map((Map<String, dynamic> j) => _mapOffer(j, incoming: incoming))
        .toList();
  }

  Offer _mapOffer(Map<String, dynamic> json, {required bool incoming}) {
    // Incoming offers show the buyer; outgoing show the seller.
    final party = json[incoming ? 'buyer' : 'seller'] is Map<String, dynamic>
        ? json[incoming ? 'buyer' : 'seller'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final items = json['items'];
    return Offer(
      id: _str(json, ['id', '_id']) ?? '',
      amount: _num(json, ['amount']) ?? 0,
      status: switch ((_str(json, ['status']) ?? '').toUpperCase()) {
        'ACCEPTED' => OfferStatus.accepted,
        'DECLINED' || 'REFUSED' => OfferStatus.declined,
        'CANCELLED' || 'CANCELED' => OfferStatus.cancelled,
        'PENDING' => OfferStatus.pending,
        _ => OfferStatus.unknown,
      },
      counterpartName:
          _str(party, ['displayName', 'name']) ??
          _str(party, ['handle', 'username']) ??
          '',
      counterpartAvatar: _str(party, ['avatarUrl', 'avatar']),
      itemCount: items is List ? items.length : 0,
      createdAt: DateTime.tryParse(_str(json, ['createdAt']) ?? ''),
    );
  }

  @override
  Future<void> makeOffer({
    required String sellerId,
    required num amount,
  }) async {
    await _dio.post<dynamic>(
      'v1/offers',
      data: <String, dynamic>{'sellerId': sellerId, 'amount': amount},
    );
  }

  @override
  Future<void> cancelOffer(String offerId) async {
    await _dio.delete<dynamic>('v1/offers/$offerId');
  }

  @override
  Future<void> acceptOffer(String offerId) async {
    await _dio.post<dynamic>('v1/offers/$offerId/accept');
  }

  @override
  Future<void> declineOffer(String offerId) async {
    await _dio.post<dynamic>('v1/offers/$offerId/decline');
  }

  String? _str(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  num? _num(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) return value;
      if (value is String) {
        final parsed = num.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }
}
