import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/domain/offers/offers_repository.dart';

@LazySingleton(as: OffersRepository)
class OffersRepositoryImpl implements OffersRepository {
  final Dio _dio;

  OffersRepositoryImpl(this._dio);

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
}
