import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/data/product/product_mapper.dart';
import 'package:klozy/src/data/social/social_mapper.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/social/entity/follow_user.dart';
import 'package:klozy/src/domain/social/entity/profile_reel.dart';
import 'package:klozy/src/domain/social/entity/social_profile.dart';
import 'package:klozy/src/domain/social/entity/user_review.dart';
import 'package:klozy/src/domain/social/social_repository.dart';

@LazySingleton(as: SocialRepository)
class SocialRepositoryImpl implements SocialRepository {
  final Dio _dio;
  final MeRepository _meRepository;

  SocialRepositoryImpl(this._dio, this._meRepository);

  @override
  Future<SocialProfile> getProfile(String userId) async {
    final response = await _dio.get<Map<String, dynamic>>('v1/users/$userId');
    return mapSocialProfile(response.data);
  }

  @override
  Future<SocialProfile> getMyProfile() async {
    final me = await _meRepository.getMe();
    return getProfile(me.id);
  }

  @override
  Future<List<Product>> getUserProducts(String userId, {int page = 1}) async {
    final response = await _dio.get<dynamic>(
      'v1/users/$userId/products',
      queryParameters: <String, dynamic>{'page': page, 'limit': 20},
    );
    return _list(response.data).map(mapProduct).toList();
  }

  @override
  Future<List<ProfileReel>> getUserReels(
    String userId, {
    bool mine = false,
  }) async {
    final response = await _dio.get<dynamic>(
      mine ? 'v1/reels/mine' : 'v1/reels',
      queryParameters: <String, dynamic>{
        if (!mine) 'authorId': userId,
        'limit': 30,
      },
    );
    return _list(response.data).map(mapProfileReel).toList();
  }

  @override
  Future<List<UserReview>> getReviews(String userId) async {
    try {
      final response = await _dio.get<dynamic>('v1/users/$userId/reviews');
      return _list(response.data).map(mapUserReview).toList();
    } catch (_) {
      return const <UserReview>[];
    }
  }

  @override
  Future<List<FollowUser>> getFollowers(String userId) async {
    final response = await _dio.get<dynamic>('v1/users/$userId/followers');
    return _list(response.data).map(mapFollowUser).toList();
  }

  @override
  Future<List<FollowUser>> getFollowing(String userId) async {
    final response = await _dio.get<dynamic>('v1/users/$userId/following');
    return _list(response.data).map(mapFollowUser).toList();
  }

  @override
  Future<void> follow(String userId) async {
    await _dio.put<dynamic>('v1/users/$userId/follow');
  }

  @override
  Future<void> unfollow(String userId) async {
    await _dio.delete<dynamic>('v1/users/$userId/follow');
  }

  @override
  Future<void> reportUser(String userId, String reason) async {
    await _dio.post<dynamic>(
      'v1/users/$userId/report',
      data: <String, dynamic>{'reason': reason},
    );
  }

  List<dynamic> _list(Object? data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final key in const <String>['data', 'items', 'users', 'results']) {
        if (data[key] is List) return data[key] as List<dynamic>;
      }
    }
    return const <dynamic>[];
  }
}
