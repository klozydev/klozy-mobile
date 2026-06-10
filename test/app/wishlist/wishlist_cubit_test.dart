import 'package:event_bus/event_bus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/core/events/wishlist_changed_event.dart';
import 'package:klozy/src/domain/wishlist/wishlist_repository.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockWishlistRepository extends Mock implements WishlistRepository {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Collects all [WishlistChangedEvent]s fired on [bus] while [action] runs.
Future<int> _countWishlistEvents(
  EventBus bus,
  Future<void> Function() action,
) async {
  int count = 0;
  final sub = bus.on<WishlistChangedEvent>().listen((_) => count++);
  await action();
  await Future<void>.delayed(Duration.zero); // flush microtasks
  await sub.cancel();
  return count;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _MockWishlistRepository mockRepo;
  late EventBus eventBus;
  late WishlistCubit cubit;

  setUp(() {
    mockRepo = _MockWishlistRepository();
    eventBus = EventBus();
    cubit = WishlistCubit(mockRepo, eventBus);
  });

  tearDown(() => cubit.close());

  // ── load ──────────────────────────────────────────────────────────────────

  test('load emits the ids returned by the repository', () async {
    when(
      () => mockRepo.getWishlistProductIds(),
    ).thenAnswer((_) async => {'a', 'b'});

    await cubit.load();

    expect(cubit.state, {'a', 'b'});
  });

  test('load silently keeps current state on error', () async {
    when(
      () => mockRepo.getWishlistProductIds(),
    ).thenThrow(Exception('network'));

    await cubit.load();

    expect(cubit.state, isEmpty);
  });

  // ── toggle – add ─────────────────────────────────────────────────────────

  test(
    'toggle add: optimistic add + fires WishlistChangedEvent on success',
    () async {
      when(() => mockRepo.add('p1')).thenAnswer((_) async {});

      final states = <Set<String>>[];
      final sub = cubit.stream.listen(states.add);

      final fired = await _countWishlistEvents(
        eventBus,
        () => cubit.toggle('p1'),
      );

      await sub.cancel();

      expect(states, [
        {'p1'}, // optimistic
      ]);
      expect(fired, 1);
      expect(cubit.state, {'p1'});
    },
  );

  test(
    'toggle add: reverts optimistic state and does NOT fire event on error',
    () async {
      when(() => mockRepo.add('p1')).thenThrow(Exception('server error'));

      final states = <Set<String>>[];
      final sub = cubit.stream.listen(states.add);

      final fired = await _countWishlistEvents(
        eventBus,
        () => cubit.toggle('p1'),
      );

      await sub.cancel();

      // optimistic add then revert
      expect(states, [
        {'p1'}, // optimistic
        <String>{}, // reverted
      ]);
      expect(fired, 0);
      expect(cubit.state, isEmpty);
    },
  );

  // ── toggle – remove ───────────────────────────────────────────────────────

  test(
    'toggle remove: optimistic remove + fires WishlistChangedEvent on success',
    () async {
      // Seed with one item.
      when(
        () => mockRepo.getWishlistProductIds(),
      ).thenAnswer((_) async => {'p1'});
      await cubit.load();

      when(() => mockRepo.remove('p1')).thenAnswer((_) async {});

      final states = <Set<String>>[];
      final sub = cubit.stream.listen(states.add);

      final fired = await _countWishlistEvents(
        eventBus,
        () => cubit.toggle('p1'),
      );

      await sub.cancel();

      expect(states, [<String>{}]); // optimistic remove
      expect(fired, 1);
      expect(cubit.state, isEmpty);
    },
  );

  test(
    'toggle remove: reverts optimistic state and does NOT fire event on error',
    () async {
      when(
        () => mockRepo.getWishlistProductIds(),
      ).thenAnswer((_) async => {'p1'});
      await cubit.load();

      when(() => mockRepo.remove('p1')).thenThrow(Exception('server error'));

      final states = <Set<String>>[];
      final sub = cubit.stream.listen(states.add);

      final fired = await _countWishlistEvents(
        eventBus,
        () => cubit.toggle('p1'),
      );

      await sub.cancel();

      expect(states, [
        <String>{}, // optimistic remove
        {'p1'}, // reverted
      ]);
      expect(fired, 0);
      expect(cubit.state, {'p1'});
    },
  );

  // ── isWished ──────────────────────────────────────────────────────────────

  test('isWished returns true only when id is in state', () async {
    when(
      () => mockRepo.getWishlistProductIds(),
    ).thenAnswer((_) async => {'p1'});
    await cubit.load();

    expect(cubit.isWished('p1'), isTrue);
    expect(cubit.isWished('p2'), isFalse);
  });
}
