import 'package:klozy/src/core/pagination/paginated_list.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel_comment.dart';

/// Result of creating a reel — the new reel id plus the Mux direct-upload URL
/// the client PUTs the video file to.
typedef CreatedReel = ({String reelId, String uploadUrl});

abstract class ReelsRepository {
  Future<PaginatedList<Reel>> feed({int page = 1, int limit = 10});

  /// `GET /v1/reels/{id}` — a single reel (profile reel viewer).
  Future<Reel> getReel(String id);

  /// `PATCH /v1/reels/{id}` — edit my reel's caption (tags unchanged when
  /// omitted).
  Future<void> updateReel(String id, {String? caption});

  Future<void> like(String id);
  Future<void> unlike(String id);
  Future<void> view(String id);
  Future<void> report(String id, String reason);
  Future<void> delete(String id);

  /// `GET /v1/reels/{id}/comments`.
  Future<List<ReelComment>> comments(String id, {int page = 1});

  /// `POST /v1/reels/{id}/comments`.
  Future<ReelComment> addComment(String id, String body);

  /// `DELETE /v1/reels/{id}/comments/{commentId}` (author or reel owner).
  Future<void> deleteComment(String id, String commentId);

  /// Tagged products for a reel's "shop the look" sheet.
  Future<List<Product>> shopTheLook(String id);

  /// The current user's active listings — taggable in the composer.
  Future<List<Product>> myProducts();

  /// `POST /v1/reels` → reel id + Mux upload URL.
  Future<CreatedReel> createReel({
    String? caption,
    List<String> taggedProductIds = const <String>[],
  });

  /// Raw `PUT` of the video file to the Mux upload URL.
  Future<void> uploadVideo(String uploadUrl, String filePath);
}
