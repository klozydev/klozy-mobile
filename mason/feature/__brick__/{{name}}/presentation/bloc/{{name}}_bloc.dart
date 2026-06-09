import 'package:bloc/bloc.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/feature/{{name}}/presentation/bloc/{{name}}_event.dart';
import 'package:klozy/src/feature/{{name}}/presentation/bloc/{{name}}_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class {{#pascalCase}}{{name}}{{/pascalCase}}Bloc extends Bloc<{{#pascalCase}}{{name}}{{/pascalCase}}Event, {{#pascalCase}}{{name}}{{/pascalCase}}State> {
  {{#pascalCase}}{{name}}{{/pascalCase}}Bloc() : super({{#pascalCase}}{{name}}{{/pascalCase}}LoadingState()) {
    on<{{#pascalCase}}{{name}}{{/pascalCase}}InitEvent>(_onInit);
  }

  Future<void> _onInit({{#pascalCase}}{{name}}{{/pascalCase}}Event event, Emitter<{{#pascalCase}}{{name}}{{/pascalCase}}State> emit) async {
    emit({{#pascalCase}}{{name}}{{/pascalCase}}LoadingState());
    try {
      emit({{#pascalCase}}{{name}}{{/pascalCase}}IdleState());
    } catch (error) {
      emit({{#pascalCase}}{{name}}{{/pascalCase}}ErrorState(type: AppErrorType.fromException(error)));
    }
  }
}
