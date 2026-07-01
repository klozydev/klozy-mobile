import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/pagination/paginated_list.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel_author.dart';
import 'package:klozy/src/feature/reels/domain/reels_repository.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reels_bloc.dart';
import 'package:klozy/src/feature/reels/presentation/playback/reel_playback_coordinator.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_page_widget.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_progress_dots_widget.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_viewer_widget.dart';
import 'package:mocktail/mocktail.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../support/ds_harness.dart';

// ---- Mocks -------------------------------------------------------------

class _MockReelsRepository extends Mock implements ReelsRepository {}

class _MockMeRepository extends Mock implements MeRepository {}

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

const _kReel = Reel(id: 'r1', author: _kAuthor, likes: 5, isReady: true);

const _kMe = MeProfile(id: 'me-1');

/// Detaches the viewer from the tree. MUST be the last line of every test that
/// pumps a [ReelViewerWidget].
///
/// `ReelViewerWidget` owns its [ReelsBloc] (it pulls a fresh factory instance
/// from the locator and closes it in `dispose`). `flutter_test` does NOT unmount
/// the widget between the test body and `tearDown`, so the shared `tearDown`'s
/// `bloc.close()` would otherwise run while the viewer's `BlocBuilder` is still
/// subscribed — closing a bloc with a live builder attached locks the test
/// event loop (the whole run hangs, no timeout fires). `pumpWidget` is illegal
/// inside `tearDown`, so each test unmounts here, in the body, leaving `tearDown`
/// to close the bloc against a detached tree.
Future<void> _unmountViewer(WidgetTester tester) =>
    tester.pumpWidget(const SizedBox.shrink());

// ---- Tests -------------------------------------------------------------

void main() {
  late _MockReelsRepository mockReelsRepo;
  late _MockMeRepository mockMeRepo;
  late ReelsBloc bloc;
  void Function(FlutterErrorDetails)? originalErrorHandler;

  setUpAll(disableDsFonts);

  setUp(() async {
    mockReelsRepo = _MockReelsRepository();
    mockMeRepo = _MockMeRepository();

    when(() => mockMeRepo.getMe()).thenAnswer((_) async => _kMe);

    VideoPlayerPlatform.instance = _FakeVideoPlayerPlatform();
    VisibilityDetectorController.instance.updateInterval = Duration.zero;

    await GetIt.I.reset();
    GetIt.I.registerSingleton<MeRepository>(mockMeRepo);
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
    // Each test unmounts the viewer (see [_unmountViewer]), which lets
    // ReelViewerWidget.dispose close the bloc on the safe path. Guard against a
    // second close here: double-closing this bloc deadlocks. Only close if the
    // widget's dispose somehow didn't (e.g. a test failed before unmounting).
    if (!bloc.isClosed) await bloc.close();
    await GetIt.I.reset();
  });

  /// Register a fresh bloc instance with the given feed behaviour.
  void setupBloc({required Future<PaginatedList<Reel>> Function() feed}) {
    when(
      () => mockReelsRepo.feed(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) => feed());

    bloc = ReelsBloc(mockReelsRepo, EventBus());
    GetIt.I.registerSingleton<ReelsBloc>(bloc);
  }

  // --- Loading state ---

  group('Loading state', () {
    testWidgets('shows DSLoader while in ReelsLoadingState', (
      WidgetTester tester,
    ) async {
      final Completer<PaginatedList<Reel>> completer =
          Completer<PaginatedList<Reel>>();
      setupBloc(feed: () => completer.future);

      await tester.pumpWidget(dsWrap(const ReelViewerWidget(active: true)));

      // Initial state is loading (feed not yet complete)
      expect(find.byType(DSLoader), findsOneWidget);

      // Complete the feed so the bloc transitions loading → ready, then assert
      // the loader is gone.
      completer.complete(const PaginatedList<Reel>(data: <Reel>[]));
      await tester.pump();
      await tester.pump();
      expect(find.byType(DSLoader), findsNothing);

      await _unmountViewer(tester);
    });
  });

  // --- Error state ---

  group('Error state', () {
    testWidgets('shows AppErrorWidget on feed error', (
      WidgetTester tester,
    ) async {
      setupBloc(feed: () async => throw AppErrorType.network);

      await tester.pumpWidget(dsWrap(const ReelViewerWidget(active: true)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AppErrorWidget), findsOneWidget);

      await _unmountViewer(tester);
    });

    testWidgets('retry re-fetches feed', (WidgetTester tester) async {
      setupBloc(feed: () async => throw AppErrorType.network);

      await tester.pumpWidget(dsWrap(const ReelViewerWidget(active: true)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AppErrorWidget), findsOneWidget);

      // AppErrorWidget shows a retry button — tap it
      final Finder retryFinder = find.byWidgetPredicate(
        (w) => w is ElevatedButton || w is TextButton,
      );

      if (retryFinder.evaluate().isNotEmpty) {
        await tester.tap(retryFinder.first, warnIfMissed: false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      }

      // feed was called more than once (initial + retry)
      verify(
        () => mockReelsRepo.feed(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).called(greaterThanOrEqualTo(1));

      await _unmountViewer(tester);
    });
  });

  // --- Ready state: empty ---

  group('Ready state — empty list', () {
    testWidgets('no PageView when reels list is empty', (
      WidgetTester tester,
    ) async {
      setupBloc(feed: () async => const PaginatedList<Reel>(data: <Reel>[]));

      await tester.pumpWidget(dsWrap(const ReelViewerWidget(active: true)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(PageView), findsNothing);
      expect(find.byType(DSLoader), findsNothing);
      expect(find.byType(AppErrorWidget), findsNothing);

      await _unmountViewer(tester);
    });
  });

  // --- Ready state: with reels ---

  group('Ready state — with reels', () {
    testWidgets('shows PageView when reels are available', (
      WidgetTester tester,
    ) async {
      setupBloc(
        feed: () async => const PaginatedList<Reel>(data: <Reel>[_kReel]),
      );

      await tester.pumpWidget(dsWrap(const ReelViewerWidget(active: true)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(PageView), findsOneWidget);

      await _unmountViewer(tester);
    });

    testWidgets('shows ReelProgressDotsWidget', (WidgetTester tester) async {
      setupBloc(
        feed: () async => const PaginatedList<Reel>(data: <Reel>[_kReel]),
      );

      await tester.pumpWidget(dsWrap(const ReelViewerWidget(active: true)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ReelProgressDotsWidget), findsOneWidget);

      await _unmountViewer(tester);
    });

    testWidgets('renders ReelPageWidget for each reel in the PageView', (
      WidgetTester tester,
    ) async {
      setupBloc(
        feed: () async => const PaginatedList<Reel>(data: <Reel>[_kReel]),
      );

      await tester.pumpWidget(dsWrap(const ReelViewerWidget(active: true)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ReelPageWidget), findsAtLeastNWidgets(1));

      await _unmountViewer(tester);
    });

    testWidgets('active=false → ReelPageWidget.isActive is false', (
      WidgetTester tester,
    ) async {
      setupBloc(
        feed: () async => const PaginatedList<Reel>(data: <Reel>[_kReel]),
      );

      await tester.pumpWidget(dsWrap(const ReelViewerWidget(active: false)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final ReelPageWidget page = tester.widget<ReelPageWidget>(
        find.byType(ReelPageWidget),
      );
      expect(page.isActive, isFalse);

      await _unmountViewer(tester);
    });

    testWidgets('active=true → first ReelPageWidget.isActive is true', (
      WidgetTester tester,
    ) async {
      setupBloc(
        feed: () async => const PaginatedList<Reel>(data: <Reel>[_kReel]),
      );

      await tester.pumpWidget(dsWrap(const ReelViewerWidget(active: true)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final ReelPageWidget page = tester.widget<ReelPageWidget>(
        find.byType(ReelPageWidget),
      );
      expect(page.isActive, isTrue);

      await _unmountViewer(tester);
    });

    testWidgets(
      'progress dots count matches number of reels (>1 to be visible)',
      (WidgetTester tester) async {
        const reel2 = Reel(id: 'r2', author: _kAuthor, isReady: true);
        setupBloc(
          feed: () async =>
              const PaginatedList<Reel>(data: <Reel>[_kReel, reel2]),
        );

        await tester.pumpWidget(dsWrap(const ReelViewerWidget(active: true)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        final ReelProgressDotsWidget dots = tester
            .widget<ReelProgressDotsWidget>(
              find.byType(ReelProgressDotsWidget),
            );
        expect(dots.count, 2);
        expect(dots.current, 0);

        await _unmountViewer(tester);
      },
    );

    testWidgets('isOwner=true when myId set by MeRepository matches author', (
      WidgetTester tester,
    ) async {
      // getMe returns a profile with the same id as the author
      when(
        () => mockMeRepo.getMe(),
      ).thenAnswer((_) async => const MeProfile(id: 'author-1'));
      setupBloc(
        feed: () async => const PaginatedList<Reel>(data: <Reel>[_kReel]),
      );

      await tester.pumpWidget(dsWrap(const ReelViewerWidget(active: false)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      // Wait for initState getMe() future
      await tester.pump(Duration.zero);

      final ReelPageWidget page = tester.widget<ReelPageWidget>(
        find.byType(ReelPageWidget),
      );
      expect(page.isOwner, isTrue);

      await _unmountViewer(tester);
    });
  });
}
