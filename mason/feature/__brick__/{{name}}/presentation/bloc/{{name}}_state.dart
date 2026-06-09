import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class {{#pascalCase}}{{name}}{{/pascalCase}}State extends Equatable {
  @override
  List<Object?> get props => [];
}

@immutable
final class {{#pascalCase}}{{name}}{{/pascalCase}}LoadingState extends {{#pascalCase}}{{name}}{{/pascalCase}}State {}

@immutable
final class {{#pascalCase}}{{name}}{{/pascalCase}}IdleState extends {{#pascalCase}}{{name}}{{/pascalCase}}State {}

@immutable
final class {{#pascalCase}}{{name}}{{/pascalCase}}ErrorState extends {{#pascalCase}}{{name}}{{/pascalCase}}State {
  final AppErrorType type;

  {{#pascalCase}}{{name}}{{/pascalCase}}ErrorState({required this.type});

  @override
  List<Object?> get props => [type];
}
