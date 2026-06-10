import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/domain/account/entity/account_status.dart';

@immutable
sealed class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Before bootstrap has run.
@immutable
final class AccountInitial extends AccountState {
  const AccountInitial();
}

/// Session resolution in flight.
@immutable
final class AccountResolving extends AccountState {
  const AccountResolving();
}

/// Session resolved to a concrete [AccountStatus].
@immutable
final class AccountResolved extends AccountState {
  final AccountStatus status;

  const AccountResolved(this.status);

  @override
  List<Object?> get props => <Object?>[status];
}
