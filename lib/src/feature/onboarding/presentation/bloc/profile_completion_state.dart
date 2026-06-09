import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class ProfileCompletionState extends Equatable {
  const ProfileCompletionState();

  @override
  List<Object?> get props => [];
}

final class ProfileCompletionIdle extends ProfileCompletionState {
  const ProfileCompletionIdle();
}

final class ProfileCompletionSubmitting extends ProfileCompletionState {
  const ProfileCompletionSubmitting();
}

final class ProfileCompletionDone extends ProfileCompletionState {
  const ProfileCompletionDone();
}

final class ProfileCompletionFailure extends ProfileCompletionState {
  final String message;

  const ProfileCompletionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
