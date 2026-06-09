import 'package:equatable/equatable.dart';

/// Support/contact channels (`GET /v1/app/contact`).
class ContactInfo extends Equatable {
  final String? supportEmail;
  final String? instagram;

  const ContactInfo({this.supportEmail, this.instagram});

  @override
  List<Object?> get props => [supportEmail, instagram];
}
