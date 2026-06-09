import 'package:klozy/src/domain/sell/entity/sell_draft.dart';

/// AI listing assistant (`/v1/sell`).
abstract class SellRepository {
  /// `POST /v1/sell/analyze` — photos (1–6 URLs) → draft listing fields.
  Future<SellDraft> analyze(List<String> imageUrls);
}
