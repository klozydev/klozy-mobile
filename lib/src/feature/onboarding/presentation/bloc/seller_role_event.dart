import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';

@immutable
sealed class SellerRoleEvent extends Equatable {
  const SellerRoleEvent();

  @override
  List<Object?> get props => [];
}

final class SellerRoleSubmitted extends SellerRoleEvent {
  final SellerRole role;
  final String? iban;

  const SellerRoleSubmitted({required this.role, this.iban});

  @override
  List<Object?> get props => [role, iban];
}
