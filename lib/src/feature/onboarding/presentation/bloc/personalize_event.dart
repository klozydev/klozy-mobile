import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/domain/me/entity/preferences_input.dart';

@immutable
sealed class PersonalizeEvent extends Equatable {
  const PersonalizeEvent();

  @override
  List<Object?> get props => [];
}

final class PersonalizeStarted extends PersonalizeEvent {
  const PersonalizeStarted();
}

final class PersonalizeBrandQueryChanged extends PersonalizeEvent {
  final String query;

  const PersonalizeBrandQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

final class PersonalizeSubmitted extends PersonalizeEvent {
  final PreferencesInput preferences;

  const PersonalizeSubmitted(this.preferences);

  @override
  List<Object?> get props => [preferences];
}
