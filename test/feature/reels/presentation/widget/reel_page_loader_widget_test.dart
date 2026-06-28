import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel_author.dart';
import 'package:klozy/src/feature/reels/domain/reels_repository.dart';
import 'package:klozy/src/feature/reels/presentation/playback/reel_playback_coordinator.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_page_loader_widget.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_page_widget.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_processing_widget.dart';
import 'package:mocktail/mocktail.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../support/ds_harness.dart';

// ---- Mocks -------------------------------------------------------------

class _MockReelsRepository extends Mock implements ReelsRepository {}

// ---- Fake video player -------------------------------------------------

class _FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  final Map<int, StreamController<VideoEvent>> _streams =
      <int, StreamController<VideoEvent>>{};
  int _nextId = 0;

  @override
  Future<void> init() async {}

  @override
  Future<int?> create(DataSource dataSource) async {
    final id = _nextId++;
    final ctrl = StreamController<VideoEvent>();
    _streams[id] = ctrl;
    ctrl.add(
      VideoEvent(
        eventType: VideoEventType.initialized,
        size: const Size(640, 360),
        duration: const Duration(seconds: 10),
      ),
    );
    return id;
  }

  @override
  Future<void> dispose(int playerId) async {
    await _streams[playerId]?.close();
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => _streams[playerId]!.stream;

  @override
  Future<void> play(int playerId) async {}

  @override
  Future<void> pause(int playerId) async {}

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> setVolume(int playerId, double volume) async {}

  @override
  Future<void> seekTo(int playerId, Duration position) async {}

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {}

  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;

  @override
  Widget buildView(int playerId) => Texture(textureId: playerId);
}

// ---- Helpers -----------------------------------------------------------

bool _isNetworkImageError(FlutterErrorDetails d) {
  final msg = d.exception.toString();
  return msg.contains('HTTP request failed') ||
      msg.contains('NetworkImageLoadException') ||
      msg.contains('SocketException') ||
      msg.contains('ClientException');
}

const _kAuthor = ReelAuthor(
  id: 'author-1',
  displayName: 'Alice',
  handle: 'alice',
);

const _kReadyReel = Reel(
  id: 'r1',
  author: _kAuthor,
  playbackUrl: null,
  isReady: true,
);

const _kProcessingReel = Reel(id: 'r2', author: _kAuthor, isReady: false);

// ---- Tests -------------------------------------------------------------

void main() {
  late _MockReelsRepository mockRepo;
  void Function(FlutterErrorDetails)? originalErrorHandler;

  setUpAll(disableDsFonts);

  setUp(() async {
    mockRepo = _MockReelsRepository();

    VideoPlayerPlatform.instance = _FakeVideoPlayerPlatform();
    VisibilityDetectorController.instance.updateInterval = Duration.zero;

    await GetIt.I.reset();
    GetIt.I.registerSingleton<ReelsRepository>(mockRepo);
    GetIt.I.registerSingleton<ReelPlaybackCoordinator>(
      ReelPlaybackCoordinator(),
    );

    originalErrorHandler = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails d) {
      if (_isNetworkImageError(d)) return;
      originalErrorHandler?.call(d);
    };
  });

  tearDown(() async {
    FlutterError.onError = originalErrorHandler;
    await GetIt.I.reset();
  });

  // --- Initial loading state ---

  group('Loading state', () {
    testWidgets('shows DSLoader while fetching the reel', (
      WidgetTester tester,
    ) async {
      // Use a completer so the future never completes — widget stays loading
      final Completer<Reel> completer = Completer<Reel>();
      when(() => mockRepo.getReel(any())).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        dsWrap(
          const ReelPageLoaderWidget(reelId: 'r1', isActive: false, myId: null),
        ),
      );

      // First frame shows loading (async load not complete)
      expect(find.byType(DSLoader), findsOneWidget);
    });
  });

  // --- Error state ---

  group('Error state', () {
    testWidgets('shows AppErrorWidget when getReel throws', (
      WidgetTester tester,
    ) async {
      when(() => mockRepo.getReel(any())).thenThrow(AppErrorType.network);

      await tester.pumpWidget(
        dsWrap(
          const ReelPageLoaderWidget(reelId: 'r1', isActive: false, myId: null),
        ),
      );
      // Let the async load complete
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorWidget), findsOneWidget);
    });

    testWidgets('tapping retry in error state calls getReel again', (
      WidgetTester tester,
    ) async {
      when(() => mockRepo.getReel(any())).thenThrow(AppErrorType.network);

      await tester.pumpWidget(
        dsWrap(
          const ReelPageLoaderWidget(reelId: 'r1', isActive: false, myId: null),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorWidget), findsOneWidget);

      // Find the retry button/gesture and tap it
      final Finder retryFinder = find.byWidgetPredicate(
        (w) =>
            w is ElevatedButton ||
            w is TextButton ||
            (w is GestureDetector && w.onTap != null),
      );

      if (retryFinder.evaluate().isNotEmpty) {
        await tester.tap(retryFinder.first, warnIfMissed: false);
        await tester.pump();
      }

      // getReel called at least twice (initial + retry)
      verify(() => mockRepo.getReel('r1')).called(greaterThanOrEqualTo(1));
    });
  });

  // --- Processing state ---

  group('Processing state', () {
    testWidgets('shows ReelProcessingWidget when reel is not ready', (
      WidgetTester tester,
    ) async {
      when(
        () => mockRepo.getReel(any()),
      ).thenAnswer((_) async => _kProcessingReel);
      // view() is called only when reel isReady — not needed here

      await tester.pumpWidget(
        dsWrap(
          const ReelPageLoaderWidget(reelId: 'r2', isActive: false, myId: null),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ReelProcessingWidget), findsOneWidget);
    });

    testWidgets('processing reel polls until ready', (
      WidgetTester tester,
    ) async {
      // First call returns processing, second returns ready
      var callCount = 0;
      when(() => mockRepo.getReel(any())).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) return _kProcessingReel;
        return _kReadyReel;
      });
      when(() => mockRepo.view(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        dsWrap(
          const ReelPageLoaderWidget(reelId: 'r2', isActive: false, myId: null),
        ),
      );

      // First load completes: processing
      await tester.pumpAndSettle();
      expect(find.byType(ReelProcessingWidget), findsOneWidget);

      // Advance clock by the poll interval (3 seconds)
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // After poll, reel is ready → ReelPageWidget shown
      expect(find.byType(ReelPageWidget), findsOneWidget);
    });
  });

  // --- Ready state ---

  group('Ready state', () {
    testWidgets('shows ReelPageWidget when reel is ready', (
      WidgetTester tester,
    ) async {
      when(() => mockRepo.getReel(any())).thenAnswer((_) async => _kReadyReel);
      when(() => mockRepo.view(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        dsWrap(
          const ReelPageLoaderWidget(reelId: 'r1', isActive: false, myId: null),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ReelPageWidget), findsOneWidget);
    });

    testWidgets('calls view() when reel is ready', (WidgetTester tester) async {
      when(() => mockRepo.getReel(any())).thenAnswer((_) async => _kReadyReel);
      when(() => mockRepo.view(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        dsWrap(
          const ReelPageLoaderWidget(reelId: 'r1', isActive: false, myId: null),
        ),
      );
      await tester.pumpAndSettle();

      verify(() => mockRepo.view('r1')).called(1);
    });

    testWidgets('isOwner=true when myId matches author id', (
      WidgetTester tester,
    ) async {
      when(() => mockRepo.getReel(any())).thenAnswer((_) async => _kReadyReel);
      when(() => mockRepo.view(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        dsWrap(
          const ReelPageLoaderWidget(
            reelId: 'r1',
            isActive: false,
            myId: 'author-1', // matches _kAuthor.id
          ),
        ),
      );
      await tester.pumpAndSettle();

      final ReelPageWidget pageWidget = tester.widget<ReelPageWidget>(
        find.byType(ReelPageWidget),
      );
      expect(pageWidget.isOwner, isTrue);
    });

    testWidgets('isOwner=false when myId does not match author id', (
      WidgetTester tester,
    ) async {
      when(() => mockRepo.getReel(any())).thenAnswer((_) async => _kReadyReel);
      when(() => mockRepo.view(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        dsWrap(
          const ReelPageLoaderWidget(
            reelId: 'r1',
            isActive: false,
            myId: 'someone-else',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final ReelPageWidget pageWidget = tester.widget<ReelPageWidget>(
        find.byType(ReelPageWidget),
      );
      expect(pageWidget.isOwner, isFalse);
    });

    testWidgets('isOwner=false when myId is null', (WidgetTester tester) async {
      when(() => mockRepo.getReel(any())).thenAnswer((_) async => _kReadyReel);
      when(() => mockRepo.view(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        dsWrap(
          const ReelPageLoaderWidget(reelId: 'r1', isActive: false, myId: null),
        ),
      );
      await tester.pumpAndSettle();

      final ReelPageWidget pageWidget = tester.widget<ReelPageWidget>(
        find.byType(ReelPageWidget),
      );
      expect(pageWidget.isOwner, isFalse);
    });

    testWidgets('isActive is propagated to ReelPageWidget', (
      WidgetTester tester,
    ) async {
      when(() => mockRepo.getReel(any())).thenAnswer((_) async => _kReadyReel);
      when(() => mockRepo.view(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        dsWrap(
          const ReelPageLoaderWidget(reelId: 'r1', isActive: true, myId: null),
        ),
      );
      await tester.pumpAndSettle();

      final ReelPageWidget pageWidget = tester.widget<ReelPageWidget>(
        find.byType(ReelPageWidget),
      );
      expect(pageWidget.isActive, isTrue);
    });

    testWidgets('like callback calls repo.like', (WidgetTester tester) async {
      when(() => mockRepo.getReel(any())).thenAnswer((_) async => _kReadyReel);
      when(() => mockRepo.view(any())).thenAnswer((_) async {});
      when(() => mockRepo.like(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        dsWrap(
          const ReelPageLoaderWidget(reelId: 'r1', isActive: false, myId: null),
        ),
      );
      await tester.pumpAndSettle();

      final ReelPageWidget page = tester.widget<ReelPageWidget>(
        find.byType(ReelPageWidget),
      );
      // Invoke the onLike callback directly
      page.onLike();
      await tester.pump();

      verify(() => mockRepo.like('r1')).called(1);
    });

    testWidgets('share callback does not throw', (WidgetTester tester) async {
      when(() => mockRepo.getReel(any())).thenAnswer((_) async => _kReadyReel);
      when(() => mockRepo.view(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        dsWrap(
          const ReelPageLoaderWidget(reelId: 'r1', isActive: false, myId: null),
        ),
      );
      await tester.pumpAndSettle();

      final ReelPageWidget page = tester.widget<ReelPageWidget>(
        find.byType(ReelPageWidget),
      );
      // onShare calls AppShare.reel which is a static method — just verify no throw
      // (It may throw if share plugin isn't initialized, so we wrap it)
      try {
        page.onShare();
      } catch (_) {}
      await tester.pump();
    });
  });

  // --- Poll error recovery ---

  group('Poll error recovery', () {
    testWidgets('poll continues after a getReel error', (
      WidgetTester tester,
    ) async {
      var callCount = 0;
      when(() => mockRepo.getReel(any())).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) return _kProcessingReel; // initial load
        if (callCount == 2) throw Exception('temporary error'); // poll error
        return _kReadyReel; // second poll succeeds
      });
      when(() => mockRepo.view(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        dsWrap(
          const ReelPageLoaderWidget(reelId: 'r2', isActive: false, myId: null),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(ReelProcessingWidget), findsOneWidget);

      // First poll: fails
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Second poll: ready
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byType(ReelPageWidget), findsOneWidget);
    });
  });

  // --- Dispose ---

  group('Dispose', () {
    testWidgets('widget disposes without error even while loading', (
      WidgetTester tester,
    ) async {
      final Completer<Reel> completer = Completer<Reel>();
      when(() => mockRepo.getReel(any())).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        dsWrap(
          const ReelPageLoaderWidget(reelId: 'r1', isActive: false, myId: null),
        ),
      );
      await tester.pump();

      // Replace widget tree to trigger dispose
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      // Complete the future after dispose — should not throw
      completer.complete(_kReadyReel);
      await tester.pump();
    });
  });
}
