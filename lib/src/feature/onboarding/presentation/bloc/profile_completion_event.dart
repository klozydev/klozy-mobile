import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/domain/me/entity/address_input.dart';

@immutable
sealed class ProfileCompletionEvent extends Equatable {
  const ProfileCompletionEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileCompletionSubmitted extends ProfileCompletionEvent {
  final String firstName;
  final String lastName;
  final String? bio;
  final AddressInput address;

  const ProfileCompletionSubmitted({
    required this.firstName,
    required this.lastName,
    required this.address,
    this.bio,
  });

  @override
  List<Object?> get props => [firstName, lastName, bio, address];
}
