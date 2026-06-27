import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/reels/presentation/playback/reel_playback_coordinator.dart';

void main() {
  late ReelPlaybackCoordinator coordinator;

  setUp(() => coordinator = ReelPlaybackCoordinator());

  group('ReelPlaybackCoordinator', () {
    test('first request becomes the active owner without preempting', () {
      final tokenA = Object();
      var aPaused = 0;

      coordinator.requestPlayback(tokenA, () => aPaused++);

      expect(coordinator.isActive(tokenA), isTrue);
      expect(aPaused, 0);
    });

    test('a new request preempts (pauses) the previous owner exactly once', () {
      final tokenA = Object();
      final tokenB = Object();
      var aPaused = 0;
      var bPaused = 0;

      coordinator.requestPlayback(tokenA, () => aPaused++);
      coordinator.requestPlayback(tokenB, () => bPaused++);

      expect(aPaused, 1, reason: 'A is preempted by B');
      expect(bPaused, 0);
      expect(coordinator.isActive(tokenA), isFalse);
      expect(coordinator.isActive(tokenB), isTrue);
    });

    test(
      're-requesting from the same active token does not preempt itself',
      () {
        final tokenA = Object();
        var aPaused = 0;

        coordinator.requestPlayback(tokenA, () => aPaused++);
        coordinator.requestPlayback(tokenA, () => aPaused++);

        expect(aPaused, 0);
        expect(coordinator.isActive(tokenA), isTrue);
      },
    );

    test('releasing the active token clears ownership', () {
      final tokenA = Object();

      coordinator.requestPlayback(tokenA, () {});
      coordinator.release(tokenA);

      expect(coordinator.isActive(tokenA), isFalse);
    });

    test('releasing a non-active token leaves the active owner untouched', () {
      final tokenA = Object();
      final tokenB = Object();

      coordinator.requestPlayback(tokenA, () {});
      coordinator.release(tokenB);

      expect(coordinator.isActive(tokenA), isTrue);
    });
  });
}
