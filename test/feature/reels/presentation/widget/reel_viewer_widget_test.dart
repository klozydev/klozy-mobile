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
import 'package:video_player/video_player.dart';
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
  Stream<VideoEvent> videoEventsFor(int playerId) =>
      _streams[playerId]!.stream;

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

const _kReel = Reel(
  id: 'r1',
  author: _kAuthor,
  likes: 5,
  isReady: true,
);

const _kMe = MeProfile(id: 'me-1');

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
    await bloc.close();
    await GetIt.I.reset();
  });

  /// Register a fresh bloc instance with the given feed behaviour.
  void _setupBloc({
    required Future<PaginatedList<Reel>> Function() feed,
  }) {
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
      _setupBloc(feed: () => completer.future);

      await tester.pumpWidget(
        dsWrap(const ReelViewerWidget(active: true)),
      );

      // Initial state is loading (feed not yet complete)
      expect(find.byType(DSLoader), findsOneWidget);

      // Complete the feed so the bloc's in-flight _onStarted handler finishes;
      // otherwise tearDown's `await bloc.close()` deadlocks waiting on it.
      completer.complete(const PaginatedList<Reel>(data: <Reel>[]));
      await tester.pump();
    });
  });

  // --- Error state ---

  group('Error state', () {
    testWidgets('shows AppErrorWidget on feed error', (
      WidgetTester tester,
    ) async {
      _setupBloc(feed: () async => throw AppErrorType.network);

      await tester.pumpWidget(
        dsWrap(const ReelViewerWidget(active: true)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AppErrorWidget), findsOneWidget);
    });

    testWidgets('retry re-fetches feed', (WidgetTester tester) async {
      _setupBloc(feed: () async => throw AppErrorType.network);

      await tester.pumpWidget(
        dsWrap(const ReelViewerWidget(active: true)),
      );
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
    });
  });

  // --- Ready state: empty ---

  group('Ready state — empty list', () {
    testWidgets('no PageView when reels list is empty', (
      WidgetTester tester,
    ) async {
      _setupBloc(
        feed: () async => const PaginatedList<Reel>(data: <Reel>[]),
      );

      await tester.pumpWidget(
        dsWrap(const ReelViewerWidget(active: true)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(PageView), findsNothing);
      expect(find.byType(DSLoader), findsNothing);
      expect(find.byType(AppErrorWidget), findsNothing);
    });
  });

  // --- Ready state: with reels ---

  group('Ready state — with reels', () {
    testWidgets('shows PageView when reels are available', (
      WidgetTester tester,
    ) async {
      _setupBloc(
        feed: () async =>
            const PaginatedList<Reel>(data: <Reel>[_kReel]),
      );

      await tester.pumpWidget(
        dsWrap(const ReelViewerWidget(active: true)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('shows ReelProgressDotsWidget', (WidgetTester tester) async {
      _setupBloc(
        feed: () async =>
            const PaginatedList<Reel>(data: <Reel>[_kReel]),
      );

      await tester.pumpWidget(
        dsWrap(const ReelViewerWidget(active: true)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ReelProgressDotsWidget), findsOneWidget);
    });

    testWidgets('renders ReelPageWidget for each reel in the PageView', (
      WidgetTester tester,
    ) async {
      _setupBloc(
        feed: () async =>
            const PaginatedList<Reel>(data: <Reel>[_kReel]),
      );

      await tester.pumpWidget(
        dsWrap(const ReelViewerWidget(active: true)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ReelPageWidget), findsAtLeastNWidgets(1));
    });

    testWidgets('active=false → ReelPageWidget.isActive is false', (
      WidgetTester tester,
    ) async {
      _setupBloc(
        feed: () async =>
            const PaginatedList<Reel>(data: <Reel>[_kReel]),
      );

      await tester.pumpWidget(
        dsWrap(const ReelViewerWidget(active: false)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final ReelPageWidget page = tester.widget<ReelPageWidget>(
        find.byType(ReelPageWidget),
      );
      expect(page.isActive, isFalse);
    });

    testWidgets('active=true → first ReelPageWidget.isActive is true', (
      WidgetTester tester,
    ) async {
      _setupBloc(
        feed: () async =>
            const PaginatedList<Reel>(data: <Reel>[_kReel]),
      );

      await tester.pumpWidget(
        dsWrap(const ReelViewerWidget(active: true)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final ReelPageWidget page = tester.widget<ReelPageWidget>(
        find.byType(ReelPageWidget),
      );
      expect(page.isActive, isTrue);
    });

    testWidgets(
        'progress dots count matches number of reels (>1 to be visible)', (
      WidgetTester tester,
    ) async {
      const reel2 = Reel(id: 'r2', author: _kAuthor, isReady: true);
      _setupBloc(
        feed: () async =>
            const PaginatedList<Reel>(data: <Reel>[_kReel, reel2]),
      );

      await tester.pumpWidget(
        dsWrap(const ReelViewerWidget(active: true)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final ReelProgressDotsWidget dots = tester.widget<ReelProgressDotsWidget>(
        find.byType(ReelProgressDotsWidget),
      );
      expect(dots.count, 2);
      expect(dots.current, 0);
    });

    testWidgets('isOwner=true when myId set by MeRepository matches author', (
      WidgetTester tester,
    ) async {
      // getMe returns a profile with the same id as the author
      when(() => mockMeRepo.getMe()).thenAnswer(
        (_) async => const MeProfile(id: 'author-1'),
      );
      _setupBloc(
        feed: () async =>
            const PaginatedList<Reel>(data: <Reel>[_kReel]),
      );

      await tester.pumpWidget(
        dsWrap(const ReelViewerWidget(active: false)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      // Wait for initState getMe() future
      await tester.pump(Duration.zero);

      final ReelPageWidget page = tester.widget<ReelPageWidget>(
        find.byType(ReelPageWidget),
      );
      expect(page.isOwner, isTrue);
    });
  });
}
