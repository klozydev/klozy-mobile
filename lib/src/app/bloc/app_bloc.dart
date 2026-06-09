import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/app/bloc/app_event.dart';
import 'package:klozy/src/app/bloc/app_state.dart';

@injectable
class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppIdleState()) {
    on<AppInitEvent>(_onInit);
  }

  void _onInit(AppInitEvent event, Emitter<AppState> emit) {}
}
