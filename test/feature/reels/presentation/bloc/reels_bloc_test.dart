import 'package:event_bus/event_bus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/pagination/paginated_list.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel_author.dart';
import 'package:klozy/src/feature/reels/domain/reels_repository.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reels_bloc.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reels_event.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reels_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockReelsRepository extends Mock implements ReelsRepository {}

Future<List<ReelsState>> _collectStates(
  ReelsBloc bloc,
  ReelsEvent event,
) async {
  final states = <ReelsState>[];
  final sub = bloc.stream.listen(states.add);
  bloc.add(event);
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

const _kAuthor = ReelAuthor(id: 'a1', displayName: 'Alice');
const _kReel = Reel(id: 'r1', author: _kAuthor, likes: 10, isLiked: false);

void main() {
  late _MockReelsRepository mockRepo;
  late ReelsBloc bloc;

  setUp(() {
    mockRepo = _MockReelsRepository();
    bloc = ReelsBloc(mockRepo, EventBus());
  });

  tearDown(() => bloc.close());

  test('initial state is ReelsLoadingState', () {
    expect(bloc.state, const ReelsLoadingState());
  });

  group('ReelsInitEvent', () {
    test('emits [loading, ready] on success', () async {
      when(
        () => mockRepo.feed(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Reel>(data: <Reel>[_kReel]),
      );

      final states = await _collectStates(bloc, const ReelsInitEvent());

      expect(states.first, const ReelsLoadingState());
      final ready = states.last as ReelsReadyState;
      expect(ready.reels, [_kReel]);
    });

    test('emits [loading, error] on failure', () async {
      when(
        () => mockRepo.feed(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('network'));

      final states = await _collectStates(bloc, const ReelsInitEvent());

      expect(states.first, const ReelsLoadingState());
      expect(states.last, isA<ReelsErrorState>());
    });

    test('sets hasMore=false when results < limit', () async {
      when(
        () => mockRepo.feed(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Reel>(data: <Reel>[_kReel]),
      );

      final states = await _collectStates(bloc, const ReelsInitEvent());

      final ready = states.last as ReelsReadyState;
      expect(ready.hasMore, isFalse); // 1 < limit(10)
    });
  });

  group('ReelsLoadMoreEvent', () {
    Future<void> startBloc({int count = 10}) async {
      final reels = List.generate(
        count,
        (i) => Reel(id: 'r$i', author: _kAuthor),
      );
      when(
        () => mockRepo.feed(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => PaginatedList<Reel>(data: reels));
      final sub = bloc.stream.listen((_) {});
      bloc.add(const ReelsInitEvent());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('appends reels on success', () async {
      await startBloc(count: 10); // hasMore=true
      const newReel = Reel(id: 'r-new', author: _kAuthor);
      when(() => mockRepo.feed(page: 2, limit: any(named: 'limit'))).thenAnswer(
        (_) async => const PaginatedList<Reel>(data: <Reel>[newReel]),
      );

      final states = await _collectStates(bloc, const ReelsLoadMoreEvent());

      expect((states.first as ReelsReadyState).isLoadingMore, isTrue);
      final last = states.last as ReelsReadyState;
      expect(last.reels.length, 11);
    });

    test('does nothing when hasMore=false', () async {
      await startBloc(count: 3); // 3 < 10 → hasMore=false

      final states = await _collectStates(bloc, const ReelsLoadMoreEvent());
      expect(states, isEmpty);
    });

    test('settles isLoadingMore=false on error', () async {
      await startBloc(count: 10);
      when(
        () => mockRepo.feed(page: 2, limit: any(named: 'limit')),
      ).thenThrow(Exception('network'));

      final states = await _collectStates(bloc, const ReelsLoadMoreEvent());

      expect((states.last as ReelsReadyState).isLoadingMore, isFalse);
    });
  });

  group('ReelsLikeToggledEvent', () {
    Future<void> startBloc() async {
      when(
        () => mockRepo.feed(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Reel>(data: <Reel>[_kReel]),
      );
      final sub = bloc.stream.listen((_) {});
      bloc.add(const ReelsInitEvent());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('optimistically likes and calls repo', () async {
      await startBloc();
      when(() => mockRepo.like(any())).thenAnswer((_) async {});

      final states = await _collectStates(
        bloc,
        const ReelsLikeToggledEvent(_kReel),
      );

      final updated = states.first as ReelsReadyState;
      expect(updated.reels.first.isLiked, isTrue);
      expect(updated.reels.first.likes, 11);
      verify(() => mockRepo.like('r1')).called(1);
    });

    test('reverts on like error', () async {
      await startBloc();
      when(() => mockRepo.like(any())).thenThrow(Exception('server'));

      final states = await _collectStates(
        bloc,
        const ReelsLikeToggledEvent(_kReel),
      );

      final reverted = states.last as ReelsReadyState;
      expect(reverted.reels.first.isLiked, isFalse); // reverted
    });

    test('optimistically unlikes', () async {
      // Seed with liked reel
      const likedReel = Reel(
        id: 'r1',
        author: _kAuthor,
        likes: 5,
        isLiked: true,
      );
      when(
        () => mockRepo.feed(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Reel>(data: <Reel>[likedReel]),
      );
      final sub = bloc.stream.listen((_) {});
      bloc.add(const ReelsInitEvent());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      when(() => mockRepo.unlike(any())).thenAnswer((_) async {});

      final states = await _collectStates(
        bloc,
        const ReelsLikeToggledEvent(likedReel),
      );

      final updated = states.first as ReelsReadyState;
      expect(updated.reels.first.isLiked, isFalse);
      expect(updated.reels.first.likes, 4);
      verify(() => mockRepo.unlike('r1')).called(1);
    });
  });

  group('ReelsViewedEvent', () {
    test('calls repo view (fire-and-forget)', () async {
      when(() => mockRepo.view(any())).thenAnswer((_) async {});

      // Dispatch and just check the call was made
      bloc.add(const ReelsViewedEvent('r1'));
      await Future<void>.delayed(Duration.zero);

      verify(() => mockRepo.view('r1')).called(1);
    });
  });

  group('ReelsDeletedEvent', () {
    Future<void> startBloc() async {
      when(
        () => mockRepo.feed(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const PaginatedList<Reel>(data: <Reel>[_kReel]),
      );
      final sub = bloc.stream.listen((_) {});
      bloc.add(const ReelsInitEvent());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
    }

    test('removes reel from list on success', () async {
      await startBloc();
      when(() => mockRepo.delete(any())).thenAnswer((_) async {});

      final states = await _collectStates(bloc, const ReelsDeletedEvent('r1'));

      final last = states.last as ReelsReadyState;
      expect(last.reels, isEmpty);
    });

    test('still removes reel when delete throws', () async {
      await startBloc();
      when(() => mockRepo.delete(any())).thenThrow(Exception('server'));

      final states = await _collectStates(bloc, const ReelsDeletedEvent('r1'));

      final last = states.last as ReelsReadyState;
      expect(last.reels, isEmpty);
    });
  });
}
