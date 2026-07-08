import 'package:equatable/equatable.dart';
import 'package:klozy/src/core/constants/app_defaults.dart';

/// A saved delivery address (`/v1/me/addresses`).
class Address extends Equatable {
  final String id;
  final String? label;
  final String? recipientName;
  final String? phone;
  final String line1;
  final String? line2;
  final String? area;
  final String city;
  final String emirate;
  final String country;
  final bool isDefault;

  const Address({
    required this.id,
    required this.line1,
    required this.city,
    required this.emirate,
    this.label,
    this.recipientName,
    this.phone,
    this.line2,
    this.area,
    this.country = kDefaultCountry,
    this.isDefault = false,
  });

  /// "Marina Gate 1, Dubai Marina, Dubai".
  String get summary => <String?>[
    line1,
    area,
    city,
    emirate,
  ].where((String? s) => s != null && s.isNotEmpty).join(', ');

  String get title => label != null && label!.isNotEmpty ? label! : city;

  @override
  List<Object?> get props => [
    id,
    label,
    recipientName,
    phone,
    line1,
    line2,
    area,
    city,
    emirate,
    country,
    isDefault,
  ];
}
