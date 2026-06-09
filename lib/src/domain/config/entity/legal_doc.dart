import 'package:equatable/equatable.dart';

/// A legal document reference (`GET /v1/legal`).
class LegalDoc extends Equatable {
  final String key;
  final String name;
  final String? version;

  const LegalDoc({required this.key, this.name = '', this.version});

  @override
  List<Object?> get props => [key, name, version];
}

/// A legal document's content (`GET /v1/legal/{key}`).
class LegalDocContent extends Equatable {
  final String title;
  final String body;

  const LegalDocContent({this.title = '', this.body = ''});

  @override
  List<Object?> get props => [title, body];
}
