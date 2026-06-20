import 'package:equatable/equatable.dart';

enum SellerRole { particular, vendor }

/// The Klozy profile behind `GET /v1/me` (distinct from the Firebase identity).
/// Parsed defensively — the API documents this payload as an opaque object, so
/// every field is nullable and [isProfileComplete] is computed client-side.
class MeProfile extends Equatable {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? bio;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final bool hasAddress;
  final SellerRole? sellerRole;
  final String? payoutIbanMasked;

  const MeProfile({
    required this.id,
    this.firstName,
    this.lastName,
    this.bio,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.hasAddress = false,
    this.sellerRole,
    this.payoutIbanMasked,
  });

  /// First-run onboarding gate: a usable profile needs a name and a delivery
  /// address (per the design's required fields).
  bool get isProfileComplete =>
      (firstName?.trim().isNotEmpty ?? false) &&
      (lastName?.trim().isNotEmpty ?? false) &&
      hasAddress;

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    bio,
    email,
    phoneNumber,
    avatarUrl,
    hasAddress,
    sellerRole,
    payoutIbanMasked,
  ];
}
