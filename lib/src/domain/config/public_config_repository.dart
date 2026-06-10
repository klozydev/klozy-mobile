import 'package:klozy/src/domain/config/entity/contact_info.dart';
import 'package:klozy/src/domain/config/entity/legal_doc.dart';

/// Public app config — legal docs + support channels.
abstract class PublicConfigRepository {
  /// `GET /v1/legal`.
  Future<List<LegalDoc>> getLegalDocs();

  /// `GET /v1/legal/{key}`.
  Future<LegalDocContent> getLegalDoc(String key);

  /// `GET /v1/app/contact`.
  Future<ContactInfo> getContact();

  /// `GET /v1/me/legal/pending` — docs the user must (re-)accept.
  Future<List<LegalDoc>> getPendingLegal();

  /// `POST /v1/me/legal/{key}/accept`.
  Future<void> acceptLegal(String key);
}
