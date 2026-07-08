import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/seller_role_failure_reason.dart';

@immutable
sealed class SellerRoleState extends Equatable {
  const SellerRoleState();

  @override
  List<Object?> get props => [];
}

final class SellerRoleIdle extends SellerRoleState {
  const SellerRoleIdle();
}

final class SellerRoleSubmitting extends SellerRoleState {
  const SellerRoleSubmitting();
}

final class SellerRoleDone extends SellerRoleState {
  const SellerRoleDone();
}

final class SellerRoleFailure extends SellerRoleState {
  final SellerRoleFailureReason reason;

  const SellerRoleFailure(this.reason);

  @override
  List<Object?> get props => [reason];
}
