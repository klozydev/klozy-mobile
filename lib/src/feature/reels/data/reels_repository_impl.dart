import 'package:event_bus/event_bus.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/events/reels_changed_event.dart';
import 'package:klozy/src/core/pagination/paginated_list.dart';
import 'package:klozy/src/core/pagination/paginated_list_response.dart';
import 'package:klozy/src/data/product/product_mapper.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/feature/reels/data/datasource/remote_reels_data_source.dart';
import 'package:klozy/src/feature/reels/data/reel_mapper.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel_comment.dart';
import 'package:klozy/src/feature/reels/domain/reels_repository.dart';

@Injectable(as: ReelsRepository)
class ReelsRepositoryImpl extends ReelsRepository {
  final RemoteReelsDataSource _remoteDataSource;
  final MeRepository _meRepository;
  final EventBus _eventBus;

  ReelsRepositoryImpl(
    this._remoteDataSource,
    this._meRepository,
    this._eventBus,
  );

  @override
  Future<PaginatedList<Reel>> feed({int page = 1, int limit = 10}) async {
    final data = await _remoteDataSource.feed(page: page, limit: limit);
    final parsed = PaginatedListResponse<Reel>.fromJson(data, mapReel);
    return PaginatedList<Reel>(data: parsed.data, metadata: parsed.metadata);
  }

  @override
  Future<Reel> getReel(String id) async {
    final data = await _remoteDataSource.getOne(id);
    final inner = data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data;
    return mapReel(inner);
  }

  @override
  Future<List<ReelComment>> comments(String id, {int page = 1}) async {
    final data = await _remoteDataSource.comments(id, page: page);
    final list = data is List
        ? data
        : (data is Map<String, dynamic>
              ? (data['data'] is List
                    ? data['data'] as List<dynamic>
                    : (data['items'] is List
                          ? data['items'] as List<dynamic>
                          : const <dynamic>[]))
              : const <dynamic>[]);
    return list.map(mapReelComment).toList();
  }

  @override
  Future<ReelComment> addComment(String id, String body) async {
    final json = await _remoteDataSource.addComment(id, body);
    final inner = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return mapReelComment(inner);
  }

  @override
  Future<void> deleteComment(String id, String commentId) =>
      _remoteDataSource.deleteComment(id, commentId);

  @override
  Future<void> updateReel(String id, {String? caption}) async {
    await _remoteDataSource.update(id, <String, dynamic>{
      if (caption != null) 'caption': caption,
    });
    _eventBus.fire(const ReelsChangedEvent());
  }

  @override
  Future<void> like(String id) => _remoteDataSource.like(id);

  @override
  Future<void> unlike(String id) => _remoteDataSource.unlike(id);

  @override
  Future<void> view(String id) => _remoteDataSource.view(id);

  @override
  Future<void> report(String id, String reason) =>
      _remoteDataSource.report(id, reason);

  @override
  Future<void> delete(String id) async {
    await _remoteDataSource.delete(id);
    _eventBus.fire(const ReelsChangedEvent());
  }

  @override
  Future<List<Product>> shopTheLook(String id) async {
    final list = await _remoteDataSource.shopTheLook(id);
    return list.map(mapProduct).toList();
  }

  @override
  Future<List<Product>> myProducts() async {
    final me = await _meRepository.getMe();
    if (me.id.isEmpty) return const <Product>[];
    final list = await _remoteDataSource.userProducts(me.id);
    return list.map(mapProduct).toList();
  }

  @override
  Future<CreatedReel> createReel({
    String? caption,
    List<String> taggedProductIds = const <String>[],
  }) async {
    final json = await _remoteDataSource.createReel(
      caption: caption,
      taggedProductIds: taggedProductIds,
    );
    _eventBus.fire(const ReelsChangedEvent());
    return (reelId: _reelId(json), uploadUrl: _uploadUrl(json));
  }

  @override
  Future<void> uploadVideo(String uploadUrl, String filePath) =>
      _remoteDataSource.uploadVideo(uploadUrl, filePath);

  String _reelId(Map<String, dynamic> json) {
    final reel = json['reel'];
    if (reel is Map<String, dynamic>) {
      return _str(reel, ['id', '_id']) ?? '';
    }
    return _str(json, ['id', '_id', 'reelId']) ?? '';
  }

  String _uploadUrl(Map<String, dynamic> json) {
    final upload = json['upload'];
    if (upload is Map<String, dynamic>) {
      return _str(upload, ['url', 'uploadUrl']) ?? '';
    }
    return _str(json, ['uploadUrl', 'muxUploadUrl', 'url']) ?? '';
  }

  String? _str(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }
}
