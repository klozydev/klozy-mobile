import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class {{#pascalCase}}{{name}}{{/pascalCase}}Event extends Equatable {
  @override
  List<Object?> get props => [];
}

@immutable
final class {{#pascalCase}}{{name}}{{/pascalCase}}InitEvent extends {{#pascalCase}}{{name}}{{/pascalCase}}Event {}
