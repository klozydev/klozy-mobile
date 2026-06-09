import 'package:equatable/equatable.dart';

/// One address autocomplete row: a primary line + a secondary (region) line.
class DSAddressSuggestion extends Equatable {
  final String main;
  final String sub;

  const DSAddressSuggestion({required this.main, required this.sub});

  @override
  List<Object?> get props => [main, sub];
}
