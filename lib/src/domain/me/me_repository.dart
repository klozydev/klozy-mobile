import 'package:klozy/src/domain/me/entity/address.dart';
import 'package:klozy/src/domain/me/entity/address_input.dart';
import 'package:klozy/src/domain/me/entity/blocked_user.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/entity/notification_settings.dart';
import 'package:klozy/src/domain/me/entity/payout.dart';
import 'package:klozy/src/domain/me/entity/preferences_input.dart';
import 'package:klozy/src/domain/me/entity/seller_stats.dart';

/// The current user's Klozy profile and onboarding mutations (`/v1/me/**`).
abstract class MeRepository {
  /// `GET /v1/me` — provisions the user on first call.
  Future<MeProfile> getMe();

  /// `PATCH /v1/me` — name + bio + handle.
  Future<MeProfile> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
    String? handle,
  });

  /// `POST /v1/me/avatar` (multipart) — returns the new avatar URL.
  Future<String?> uploadAvatar(String filePath);

  /// `PUT /v1/me/address` — back-compat default-address upsert (onboarding).
  Future<void> setAddress(AddressInput address);

  /// `GET /v1/me/addresses` — saved address book (default first).
  Future<List<Address>> getAddresses();

  /// `POST /v1/me/addresses`.
  Future<Address> createAddress(AddressInput input);

  /// `PATCH /v1/me/addresses/{id}`.
  Future<Address> updateAddress(String id, AddressInput input);

  /// `DELETE /v1/me/addresses/{id}`.
  Future<void> deleteAddress(String id);

  /// `PUT /v1/me/addresses/{id}/default` — returns the full list.
  Future<List<Address>> setDefaultAddress(String id);

  /// `PUT /v1/me/preferences`.
  Future<void> updatePreferences(PreferencesInput preferences);

  /// `PUT /v1/me/seller-role` — [iban] required for the particular role.
  Future<void> setSellerRole({required SellerRole role, String? iban});

  /// `GET /v1/me/notification-settings`.
  Future<NotificationSettings> getNotificationSettings();

  /// `PUT /v1/me/notification-settings`.
  Future<void> updateNotificationSettings({bool? push, bool? email});

  /// `PUT /v1/me/payout-iban`.
  Future<void> setPayoutIban(String iban);

  /// `GET /v1/me/seller-stats`.
  Future<SellerStats> getSellerStats();

  /// `GET /v1/me/payouts` — payout history + pending/lifetime totals (fils).
  Future<PayoutSummary> getPayouts();

  /// `GET /v1/me/blocked`.
  Future<List<BlockedUser>> getBlocked();

  /// `DELETE /v1/me/blocked/{userId}`.
  Future<void> unblock(String userId);

  /// `DELETE /v1/me` — delete the account (irreversible).
  Future<void> deleteAccount();
}
