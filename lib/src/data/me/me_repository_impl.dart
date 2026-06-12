import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/domain/me/entity/address.dart';
import 'package:klozy/src/domain/me/entity/address_input.dart';
import 'package:klozy/src/domain/me/entity/blocked_user.dart';
import 'package:klozy/src/domain/me/entity/connect_status.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/entity/notification_settings.dart';
import 'package:klozy/src/domain/me/entity/payout.dart';
import 'package:klozy/src/domain/me/entity/preferences_input.dart';
import 'package:klozy/src/domain/me/entity/seller_stats.dart';
import 'package:klozy/src/domain/me/me_repository.dart';

@LazySingleton(as: MeRepository)
class MeRepositoryImpl implements MeRepository {
  final Dio _dio;

  MeRepositoryImpl(this._dio);

  // ── getMe cache ───────────────────────────────────────────────────────────
  // One network round-trip per "dirty" window: all concurrent callers share
  // a single in-flight Future; once resolved the result is cached until
  // invalidate() is called (on mutation or sign-out).

  MeProfile? _cached;
  Future<MeProfile>? _inFlight;

  @override
  Future<MeProfile> getMe() {
    if (_cached != null) return Future<MeProfile>.value(_cached);
    if (_inFlight != null) return _inFlight!;
    late final Future<MeProfile> fetch;
    fetch = _fetchMe().then(
      (profile) {
        // Only commit if this fetch is still the current one — invalidate()
        // (e.g. sign-out) may have run while it was in flight, and committing
        // would resurrect the previous user's profile.
        if (identical(_inFlight, fetch)) {
          _cached = profile;
          _inFlight = null;
        }
        return profile;
      },
      onError: (Object e) {
        // Don't cache errors; allow the next caller to retry.
        if (identical(_inFlight, fetch)) {
          _inFlight = null;
        }
        throw e;
      },
    );
    _inFlight = fetch;
    return fetch;
  }

  Future<MeProfile> _fetchMe() async {
    final response = await _dio.get<Map<String, dynamic>>('v1/me');
    return _mapProfile(_unwrap(response.data));
  }

  @override
  void invalidate() {
    _cached = null;
    _inFlight = null;
  }

  @override
  Future<MeProfile> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
    String? handle,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      'v1/me',
      data: <String, dynamic>{
        if (handle != null) 'handle': handle,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (bio != null) 'bio': bio,
      },
    );
    final updated = _mapProfile(_unwrap(response.data));
    // Warm the cache with the fresh profile returned by the server.
    _cached = updated;
    _inFlight = null;
    return updated;
  }

  @override
  Future<String?> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap(<String, dynamic>{
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      'v1/me/avatar',
      data: formData,
    );
    invalidate();
    final json = _unwrap(response.data);
    return _str(json, ['avatarUrl', 'avatar', 'url', 'photoUrl']);
  }

  @override
  Future<void> setAddress(AddressInput address) async {
    await _dio.put<dynamic>('v1/me/address', data: address.toJson());
    invalidate();
  }

  @override
  Future<List<Address>> getAddresses() async {
    final response = await _dio.get<dynamic>('v1/me/addresses');
    return _addressList(response.data);
  }

  @override
  Future<Address> createAddress(AddressInput input) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'v1/me/addresses',
      data: input.toJson(),
    );
    return _mapAddress(_unwrap(response.data));
  }

  @override
  Future<Address> updateAddress(String id, AddressInput input) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      'v1/me/addresses/$id',
      data: input.toJson(),
    );
    return _mapAddress(_unwrap(response.data));
  }

  @override
  Future<void> deleteAddress(String id) async {
    await _dio.delete<dynamic>('v1/me/addresses/$id');
  }

  @override
  Future<List<Address>> setDefaultAddress(String id) async {
    final response = await _dio.put<dynamic>('v1/me/addresses/$id/default');
    return _addressList(response.data);
  }

  List<Address> _addressList(Object? data) {
    final list = data is List
        ? data
        : (data is Map<String, dynamic> && data['data'] is List
              ? data['data'] as List<dynamic>
              : const <dynamic>[]);
    return list.whereType<Map<String, dynamic>>().map(_mapAddress).toList();
  }

  Address _mapAddress(Map<String, dynamic> json) {
    return Address(
      id: _str(json, ['id', '_id']) ?? '',
      label: _str(json, ['label']),
      recipientName: _str(json, ['recipientName']),
      phone: _str(json, ['phone']),
      line1: _str(json, ['line1']) ?? '',
      line2: _str(json, ['line2']),
      area: _str(json, ['area']),
      city: _str(json, ['city']) ?? '',
      emirate: _str(json, ['emirate']) ?? '',
      country: _str(json, ['country']) ?? 'United Arab Emirates',
      isDefault: json['isDefault'] == true,
    );
  }

  @override
  Future<PayoutSummary> getPayouts() async {
    final response = await _dio.get<Map<String, dynamic>>('v1/me/payouts');
    final json = _unwrap(response.data);
    final rawItems = json['items'] is List
        ? json['items'] as List<dynamic>
        : const <dynamic>[];
    return PayoutSummary(
      pendingFils: _int(json, ['pendingFils', 'pending']),
      lifetimePaidFils: _int(json, ['lifetimePaidFils', 'lifetimePaid']),
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(_mapPayout)
          .toList(),
    );
  }

  PayoutItem _mapPayout(Map<String, dynamic> json) {
    return PayoutItem(
      orderId: _str(json, ['orderId', 'id']) ?? '',
      grossFils: _int(json, ['grossFils', 'gross']),
      commissionFils: _int(json, ['commissionFils', 'commission']),
      netFils: _int(json, ['netFils', 'net']),
      status: switch ((_str(json, ['status']) ?? '').toUpperCase()) {
        'COMPLETED' => PayoutStatus.completed,
        'REVERSAL' => PayoutStatus.reversal,
        _ => PayoutStatus.pending,
      },
      method: switch ((_str(json, ['method']) ?? '').toUpperCase()) {
        'STRIPE_CONNECT' => PayoutMethod.stripeConnect,
        'IBAN' => PayoutMethod.iban,
        _ => PayoutMethod.unknown,
      },
      createdAt: DateTime.tryParse(_str(json, ['createdAt']) ?? ''),
    );
  }

  @override
  Future<ConnectStatus> getConnectStatus() async {
    final response = await _dio.get<Map<String, dynamic>>(
      'v1/me/seller-connect',
    );
    final json = _unwrap(response.data);
    return ConnectStatus(
      accountId: _str(json, ['accountId']),
      onboarding: switch ((_str(json, ['onboardingStatus']) ?? '')
          .toUpperCase()) {
        'COMPLETE' => ConnectOnboarding.complete,
        'PENDING' => ConnectOnboarding.pending,
        _ => ConnectOnboarding.notStarted,
      },
      detailsSubmitted: json['detailsSubmitted'] == true,
      chargesEnabled: json['chargesEnabled'] == true,
      payoutsEnabled: json['payoutsEnabled'] == true,
    );
  }

  @override
  Future<String?> createKybLink() async {
    final response = await _dio.post<Map<String, dynamic>>(
      'v1/me/seller-connect/kyb-link',
    );
    invalidate();
    return _str(_unwrap(response.data), ['url']);
  }

  @override
  Future<PreferencesInput> getPreferences() async {
    final response = await _dio.get<Map<String, dynamic>>('v1/me/preferences');
    final json = _unwrap(response.data);
    List<String> strings(String key) => json[key] is List
        ? (json[key] as List<dynamic>).whereType<String>().toList()
        : const <String>[];
    return PreferencesInput(
      sizeSystem: _str(json, ['sizeSystem']) ?? 'EU',
      sizes: strings('sizes'),
      categoryIds: strings('categoryIds'),
      brandIds: strings('brandIds'),
    );
  }

  @override
  Future<void> updatePreferences(PreferencesInput preferences) async {
    await _dio.put<dynamic>('v1/me/preferences', data: preferences.toJson());
    invalidate();
  }

  @override
  Future<void> setSellerRole({required SellerRole role, String? iban}) async {
    await _dio.put<dynamic>(
      'v1/me/seller-role',
      data: <String, dynamic>{
        'role': role == SellerRole.particular ? 'PARTICULAR' : 'VENDOR',
        if (iban != null && iban.isNotEmpty) 'iban': iban,
      },
    );
    invalidate();
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    // There is no GET for notification-settings; the toggles live in the
    // profile response (`notificationSettings: {push, email}`).
    final response = await _dio.get<Map<String, dynamic>>('v1/me');
    final json = _unwrap(response.data);
    final settings = json['notificationSettings'] is Map<String, dynamic>
        ? json['notificationSettings'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return NotificationSettings(
      push: settings['push'] != false,
      email: settings['email'] != false,
    );
  }

  @override
  Future<void> updateNotificationSettings({bool? push, bool? email}) async {
    await _dio.put<dynamic>(
      'v1/me/notification-settings',
      data: <String, dynamic>{
        if (push != null) 'push': push,
        if (email != null) 'email': email,
      },
    );
  }

  @override
  Future<void> setPayoutIban(String iban) async {
    await _dio.put<dynamic>(
      'v1/me/payout-iban',
      data: <String, dynamic>{'iban': iban},
    );
    invalidate();
  }

  @override
  Future<SellerStats> getSellerStats() async {
    final response = await _dio.get<Map<String, dynamic>>('v1/me/seller-stats');
    final json = _unwrap(response.data);
    final entries = <SellerStat>[];
    json.forEach((String key, dynamic value) {
      if (value is num || value is String) {
        entries.add(SellerStat(label: key, value: '$value'));
      }
    });
    return SellerStats(entries: entries);
  }

  @override
  Future<List<BlockedUser>> getBlocked() async {
    final response = await _dio.get<dynamic>('v1/me/blocked');
    final data = response.data;
    final list = data is List
        ? data
        : (data is Map<String, dynamic> && data['data'] is List
              ? data['data'] as List<dynamic>
              : const <dynamic>[]);
    return list.whereType<Map<String, dynamic>>().map((Map<String, dynamic> j) {
      return BlockedUser(
        id: _str(j, ['id', '_id', 'uid']) ?? '',
        displayName: _str(j, ['displayName', 'name']) ?? '',
        handle: _str(j, ['handle', 'username']) ?? '',
        avatarUrl: _str(j, ['avatarUrl', 'avatar']),
      );
    }).toList();
  }

  @override
  Future<void> block(String userId) async {
    await _dio.put<dynamic>('v1/me/blocked/$userId');
  }

  @override
  Future<void> unblock(String userId) async {
    await _dio.delete<dynamic>('v1/me/blocked/$userId');
  }

  @override
  Future<void> deleteAccount() async {
    await _dio.delete<dynamic>('v1/me');
  }

  // ── Defensive parsing (the API documents /v1/me as an opaque object) ───────

  Map<String, dynamic> _unwrap(Map<String, dynamic>? data) {
    if (data == null) return const <String, dynamic>{};
    final inner = data['data'];
    if (inner is Map<String, dynamic>) return inner;
    return data;
  }

  MeProfile _mapProfile(Map<String, dynamic> json) {
    final address = json['address'];
    final hasAddress =
        json['hasAddress'] == true ||
        (address is Map && address.isNotEmpty) ||
        (address is String && address.isNotEmpty);
    final payout = json['payout'] is Map<String, dynamic>
        ? json['payout'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return MeProfile(
      payoutIbanMasked: _str(payout, ['ibanMasked']),
      id: _str(json, ['id', 'uid', '_id']) ?? '',
      handle: _str(json, ['handle', 'username']),
      firstName: _str(json, ['firstName', 'first_name']),
      lastName: _str(json, ['lastName', 'last_name']),
      bio: _str(json, ['bio']),
      email: _str(json, ['email']),
      phoneNumber: _str(json, ['phoneNumber', 'phone']),
      avatarUrl: _str(json, ['avatarUrl', 'avatar', 'photoUrl']),
      hasAddress: hasAddress,
      sellerRole: _role(_str(json, ['sellerRole', 'role'])),
    );
  }

  String? _str(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  int _int(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = num.tryParse(value);
        if (parsed != null) return parsed.toInt();
      }
    }
    return 0;
  }

  SellerRole? _role(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'PARTICULAR':
        return SellerRole.particular;
      case 'VENDOR':
        return SellerRole.vendor;
      default:
        return null;
    }
  }
}
