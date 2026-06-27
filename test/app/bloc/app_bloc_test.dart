import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/app/bloc/app_bloc.dart';
import 'package:klozy/src/app/bloc/app_event.dart';
import 'package:klozy/src/app/bloc/app_state.dart';

void main() {
  late AppBloc bloc;

  setUp(() {
    bloc = AppBloc();
  });

  tearDown(() => bloc.close());

  test('initial state is AppIdleState', () {
    expect(bloc.state, isA<AppIdleState>());
  });

  test('AppInitEvent does not emit new states (empty handler)', () async {
    final states = <AppState>[];
    final sub = bloc.stream.listen(states.add);
    bloc.add(AppInitEvent());
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    expect(states, isEmpty);
  });
}
