import 'package:klozy/src/feature/{{name}}/data/datasource/remote_{{name}}_data_source.dart';
import 'package:klozy/src/feature/{{name}}/domain/{{name}}_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: {{#pascalCase}}{{name}}{{/pascalCase}}Repository)
class {{#pascalCase}}{{name}}{{/pascalCase}}RepositoryImpl extends {{#pascalCase}}{{name}}{{/pascalCase}}Repository {
  final Remote{{#pascalCase}}{{name}}{{/pascalCase}}DataSource _remoteDataSource;

  {{#pascalCase}}{{name}}{{/pascalCase}}RepositoryImpl(this._remoteDataSource);
}
