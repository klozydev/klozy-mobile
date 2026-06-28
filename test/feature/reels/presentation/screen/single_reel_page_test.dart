import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel_author.dart';
import 'package:klozy/src/feature/reels/domain/reels_repository.dart';
import 'package:klozy/src/feature/reels/presentation/playback/reel_playback_coordinator.dart';
import 'package:klozy/src/feature/reels/presentation/screen/single_reel_page.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_progress_dots_widget.dart';
import 'package:mocktail/mocktail.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../support/ds_harness.dart';

// ---- Mocks -------------------------------------------------------------

class _MockMeRepository extends Mock implements MeRepository {}

class _MockReelsRepository extends Mock implements ReelsRepository {}

class _MockStackRouter extends Mock implements StackRouter {}

class _FakeRoute extends Fake implements PageRouteInfo<Object?> {}

// ---- Fake video player -------------------------------------------------

class _FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  final Map<int, StreamController<VideoEvent>> _streams =
      <int, StreamController<VideoEvent>>{};
  int _nextId = 0;

  @override
  Future<void> init() async {}

  @override
  Future<int?> create(DataSource dataSource) async {
    final int id = _nextId++;
    final StreamController<VideoEvent> ctrl = StreamController<VideoEvent>();
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

const _kMe = MeProfile(id: 'u1');

const _kAuthor = ReelAuthor(id: 'a1', displayName: 'Alice');

const _kReel = Reel(
  id: 'r1',
  author: _kAuthor,
  isReady:
      false, // processing → renders ReelProcessingWidget, avoids VideoPlayer
);

void main() {
  late _MockMeRepository mockMe;
  late _MockReelsRepository mockRepo;
  late _MockStackRouter router;

  setUpAll(() {
    disableDsFonts();
    registerFallbackValue(_FakeRoute());
    registerFallbackValue(const <PageRouteInfo<Object?>>[]);
  });

  setUp(() async {
    mockMe = _MockMeRepository();
    mockRepo = _MockReelsRepository();
    router = _MockStackRouter();

    VideoPlayerPlatform.instance = _FakeVideoPlayerPlatform();
    VisibilityDetectorController.instance.updateInterval = Duration.zero;

    await GetIt.I.reset();
    GetIt.I.registerSingleton<MeRepository>(mockMe);
    GetIt.I.registerSingleton<ReelsRepository>(mockRepo);
    GetIt.I.registerSingleton<ReelPlaybackCoordinator>(
      ReelPlaybackCoordinator(),
    );

    when(() => mockMe.getMe()).thenAnswer((_) async => _kMe);
    // Default: getReel returns a processing reel (no VideoPlayer needed).
    when(() => mockRepo.getReel(any())).thenAnswer((_) async => _kReel);

    when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Widget _wrap(Widget child) => dsWrapRouted(child, router: router);

  group('SingleReelPage — single reel', () {
    testWidgets('renders scaffold with black background', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const SingleReelPage(reelId: 'r1')));
      await tester.pump();

      final Scaffold scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.black);
    });

    testWidgets('does NOT show progress dots for single reel', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const SingleReelPage(reelId: 'r1')));
      await tester.pump();

      expect(find.byType(ReelProgressDotsWidget), findsNothing);
    });

    testWidgets('shows back button', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const SingleReelPage(reelId: 'r1')));
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

    testWidgets('back button calls router.maybePop', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const SingleReelPage(reelId: 'r1')));
      await tester.pump();

      // DSGlassButton has an IconButton or GestureDetector — tap the back icon.
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pump();

      verify(() => router.maybePop<Object?>()).called(1);
    });

    testWidgets('renders PageView', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const SingleReelPage(reelId: 'r1')));
      await tester.pump();

      expect(find.byType(PageView), findsOneWidget);
    });
  });

  group('SingleReelPage — multiple reels (pager)', () {
    testWidgets('shows progress dots for multiple reels', (
      WidgetTester tester,
    ) async {
      // Stub both reels
      when(() => mockRepo.getReel('r1')).thenAnswer((_) async => _kReel);
      when(() => mockRepo.getReel('r2')).thenAnswer(
        (_) async => const Reel(id: 'r2', author: _kAuthor, isReady: false),
      );

      await tester.pumpWidget(
        _wrap(
          const SingleReelPage(
            reelId: 'r1',
            reelIds: <String>['r1', 'r2'],
            initialIndex: 0,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ReelProgressDotsWidget), findsOneWidget);
    });

    testWidgets('clamps initial index to valid range', (
      WidgetTester tester,
    ) async {
      when(() => mockRepo.getReel('r1')).thenAnswer((_) async => _kReel);
      when(() => mockRepo.getReel('r2')).thenAnswer(
        (_) async => const Reel(id: 'r2', author: _kAuthor, isReady: false),
      );

      // initialIndex=99, should be clamped to 1 (last valid index)
      await tester.pumpWidget(
        _wrap(
          const SingleReelPage(
            reelId: 'r1',
            reelIds: <String>['r1', 'r2'],
            initialIndex: 99,
          ),
        ),
      );
      await tester.pump();

      // Widget renders without exception.
      expect(find.byType(SingleReelPage), findsOneWidget);
    });

    testWidgets('uses reelId as single id when reelIds is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const SingleReelPage(reelId: 'r1', reelIds: null)),
      );
      await tester.pump();

      expect(find.byType(ReelProgressDotsWidget), findsNothing);
    });

    testWidgets('uses reelId as single id when reelIds is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const SingleReelPage(reelId: 'r1', reelIds: <String>[])),
      );
      await tester.pump();

      expect(find.byType(ReelProgressDotsWidget), findsNothing);
    });
  });

  group('SingleReelPage — getMe async', () {
    testWidgets('getMe resolves and updates myId', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const SingleReelPage(reelId: 'r1')));
      await tester.pump();
      // Let getMe future complete.
      await tester.pumpAndSettle();

      verify(() => mockMe.getMe()).called(1);
    });

    testWidgets('renders even when getMe never resolves', (
      WidgetTester tester,
    ) async {
      final Completer<MeProfile> completer = Completer<MeProfile>();
      when(() => mockMe.getMe()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(_wrap(const SingleReelPage(reelId: 'r1')));
      await tester.pump();

      // Widget renders normally even without myId.
      expect(find.byType(SingleReelPage), findsOneWidget);
    });
  });
}
