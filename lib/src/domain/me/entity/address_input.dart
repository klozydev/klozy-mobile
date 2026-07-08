import 'package:equatable/equatable.dart';
import 'package:klozy/src/core/constants/app_defaults.dart';

/// Payload for `PUT /v1/me/address` and `POST/PATCH /v1/me/addresses`.
class AddressInput extends Equatable {
  final String line1;
  final String? line2;
  final String? area;
  final String city;
  final String emirate;
  final String country;
  final String? label;
  final String? recipientName;
  final String? phone;

  const AddressInput({
    required this.line1,
    required this.city,
    required this.emirate,
    this.line2,
    this.area,
    this.country = kDefaultCountry,
    this.label,
    this.recipientName,
    this.phone,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
    'line1': line1,
    if (line2 != null && line2!.isNotEmpty) 'line2': line2,
    if (area != null && area!.isNotEmpty) 'area': area,
    'city': city,
    'emirate': emirate,
    'country': country,
    if (label != null && label!.isNotEmpty) 'label': label,
    if (recipientName != null && recipientName!.isNotEmpty)
      'recipientName': recipientName,
    if (phone != null && phone!.isNotEmpty) 'phone': phone,
  };

  @override
  List<Object?> get props => [
    line1,
    line2,
    area,
    city,
    emirate,
    country,
    label,
    recipientName,
    phone,
  ];
}
