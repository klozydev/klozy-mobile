import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Fired at app start (and after sign-in/out) to resolve the session integrity
/// into an [AccountStatus].
@immutable
final class AccountBootstrapRequested extends AccountEvent {
  const AccountBootstrapRequested();
}
