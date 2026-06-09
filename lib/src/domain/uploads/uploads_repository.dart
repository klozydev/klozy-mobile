/// Image uploads (`/v1/uploads/images`).
abstract class UploadsRepository {
  /// Uploads the local image files and returns their public URLs (cover first,
  /// order preserved).
  Future<List<String>> uploadImages(List<String> filePaths);
}
