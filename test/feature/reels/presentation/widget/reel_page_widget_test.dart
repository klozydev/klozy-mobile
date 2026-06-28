import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel_author.dart';
import 'package:klozy/src/feature/reels/presentation/playback/reel_playback_coordinator.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_action_widget.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_page_widget.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../support/ds_harness.dart';

// ---- Fake VideoPlayer platform -----------------------------------------

class _FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  final Map<int, StreamController<VideoEvent>> _streams =
      <int, StreamController<VideoEvent>>{};
  int _nextId = 0;
  bool forceError = false;

  @override
  Future<void> init() async {}

  @override
  Future<int?> create(DataSource dataSource) async {
    final id = _nextId++;
    final ctrl = StreamController<VideoEvent>();
    _streams[id] = ctrl;
    if (forceError) {
      ctrl.addError(
        PlatformException(code: 'VideoError', message: 'forced error'),
      );
    } else {
      ctrl.add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          size: const Size(640, 360),
          duration: const Duration(seconds: 10),
        ),
      );
    }
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

// ---- Mock router -------------------------------------------------------

class _MockStackRouter extends Mock implements StackRouter {}

// ---- Helpers -----------------------------------------------------------

bool _isNetworkImageError(FlutterErrorDetails d) {
  final msg = d.exception.toString();
  return msg.contains('HTTP request failed') ||
      msg.contains('NetworkImageLoadException') ||
      msg.contains('SocketException') ||
      msg.contains('Connection refused') ||
      msg.contains('ClientException');
}

void _suppressNetworkImageErrors(void Function(FlutterErrorDetails)? original) {
  FlutterError.onError = (FlutterErrorDetails d) {
    if (_isNetworkImageError(d)) return;
    original?.call(d);
  };
}

const _kAuthor = ReelAuthor(
  id: 'author-1',
  displayName: 'Alice',
  handle: 'alice',
  isPro: false,
);

const _kProAuthor = ReelAuthor(
  id: 'author-2',
  displayName: 'Bob',
  handle: 'bob',
  isPro: true,
);

Reel _makeReel({
  String id = 'r1',
  String? playbackUrl,
  String? posterUrl,
  String caption = '',
  int likes = 0,
  bool isLiked = false,
  int taggedCount = 0,
  ReelAuthor author = _kAuthor,
}) {
  return Reel(
    id: id,
    author: author,
    playbackUrl: playbackUrl,
    posterUrl: posterUrl,
    caption: caption,
    likes: likes,
    isLiked: isLiked,
    taggedCount: taggedCount,
    isReady: true,
  );
}

Widget _wrapWidget(ReelPageWidget widget, {StackRouter? router}) {
  if (router != null) {
    return dsWrapRouted(widget, router: router);
  }
  return dsWrap(widget);
}

// ---- Tests -------------------------------------------------------------

void main() {
  late _FakeVideoPlayerPlatform fakePlatform;
  void Function(FlutterErrorDetails)? originalErrorHandler;

  setUpAll(() {
    disableDsFonts();
    registerFallbackValue(UserProfileRoute(userId: 'x'));
  });

  setUp(() async {
    fakePlatform = _FakeVideoPlayerPlatform();
    VideoPlayerPlatform.instance = fakePlatform;

    VisibilityDetectorController.instance.updateInterval = Duration.zero;

    await GetIt.I.reset();
    GetIt.I.registerSingleton<ReelPlaybackCoordinator>(
      ReelPlaybackCoordinator(),
    );

    originalErrorHandler = FlutterError.onError;
    _suppressNetworkImageErrors(originalErrorHandler);
  });

  tearDown(() async {
    FlutterError.onError = originalErrorHandler;
    await GetIt.I.reset();
  });

  // --- No video, no poster ---

  group('No video URL, no poster', () {
    testWidgets('renders without crashing and shows no VideoPlayer', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWidget(
          ReelPageWidget(
            reel: _makeReel(),
            isActive: false,
            isOwner: false,
            onLike: () {},
            onShop: () {},
            onShare: () {},
            onMenu: () {},
            onComments: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(VideoPlayer), findsNothing);
      expect(find.byType(ReelActionWidget), findsWidgets);
    });
  });

  // --- Poster URL (no video) ---

  group('No video URL, with poster', () {
    testWidgets('attempts Image.network for poster', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWidget(
          ReelPageWidget(
            reel: _makeReel(posterUrl: 'https://example.com/poster.jpg'),
            isActive: false,
            isOwner: false,
            onLike: () {},
            onShop: () {},
            onShare: () {},
            onMenu: () {},
            onComments: () {},
          ),
        ),
      );
      await tester.pump();

      // Image.network should appear (will fail to load, but widget is built)
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(VideoPlayer), findsNothing);
    });
  });

  // --- Video URL ---

  group('With video URL', () {
    testWidgets('shows VideoPlayer after initialization', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWidget(
          ReelPageWidget(
            reel: _makeReel(playbackUrl: 'https://example.com/video.m3u8'),
            isActive: true,
            isOwner: false,
            onLike: () {},
            onShop: () {},
            onShare: () {},
            onMenu: () {},
            onComments: () {},
          ),
        ),
      );

      // Wait for controller initialization callback
      await tester.pumpAndSettle();

      expect(find.byType(VideoPlayer), findsOneWidget);
    });

    testWidgets('falls back to SizedBox when URL produces error', (
      WidgetTester tester,
    ) async {
      fakePlatform.forceError = true;

      await tester.pumpWidget(
        _wrapWidget(
          ReelPageWidget(
            reel: _makeReel(playbackUrl: 'https://example.com/bad.m3u8'),
            isActive: true,
            isOwner: false,
            onLike: () {},
            onShop: () {},
            onShare: () {},
            onMenu: () {},
            onComments: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // After error, no VideoPlayer should appear
      expect(find.byType(VideoPlayer), findsNothing);
    });
  });

  // --- isActive flag ---

  group('isActive flag', () {
    testWidgets('inactive reel does not show play overlay when idle', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWidget(
          ReelPageWidget(
            reel: _makeReel(),
            isActive: false,
            isOwner: false,
            onLike: () {},
            onShop: () {},
            onShare: () {},
            onMenu: () {},
            onComments: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    });

    testWidgets('rebuilds when isActive changes from false to true', (
      WidgetTester tester,
    ) async {
      bool isActive = false;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return dsWrap(
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => isActive = true),
                    child: const Text('Activate'),
                  ),
                  Expanded(
                    child: ReelPageWidget(
                      reel: _makeReel(),
                      isActive: isActive,
                      isOwner: false,
                      onLike: () {},
                      onShop: () {},
                      onShare: () {},
                      onMenu: () {},
                      onComments: () {},
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      await tester.tap(find.text('Activate'));
      await tester.pump();
      // No crash — the didUpdateWidget path is covered
    });
  });

  // --- Tap to toggle play ---

  group('Tap to toggle playback', () {
    testWidgets('tapping reel with no controller is a no-op', (
      WidgetTester tester,
    ) async {
      // No playbackUrl → _controller is null → tap is no-op
      await tester.pumpWidget(
        _wrapWidget(
          ReelPageWidget(
            reel: _makeReel(),
            isActive: true,
            isOwner: false,
            onLike: () {},
            onShop: () {},
            onShare: () {},
            onMenu: () {},
            onComments: () {},
          ),
        ),
      );
      await tester.pump();

      // Tap the VisibilityDetector/GestureDetector — should not throw
      await tester.tap(find.byType(VisibilityDetector));
      await tester.pump();

      expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    });

    testWidgets(
      'tapping initialized reel shows pause icon (_userPaused becomes true '
      'when controller is playing)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          _wrapWidget(
            ReelPageWidget(
              reel: _makeReel(playbackUrl: 'https://example.com/video.m3u8'),
              isActive: true,
              isOwner: false,
              onLike: () {},
              onShop: () {},
              onShare: () {},
              onMenu: () {},
              onComments: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        // The controller is initialized. Emit an isPlaying event so the
        // controller reflects the playing state, then tap.
        final streamCtrl = fakePlatform._streams[0]!;
        streamCtrl.add(
          VideoEvent(
            eventType: VideoEventType.isPlayingStateUpdate,
            isPlaying: true,
          ),
        );
        await tester.pump();

        // Tap the GestureDetector that wraps the whole reel
        final GestureDetector reelGesture = tester.widget<GestureDetector>(
          find.byType(GestureDetector).first,
        );
        reelGesture.onTap?.call();
        await tester.pump();

        // _userPaused == true → play icon appears
        expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

        // Tap again to resume (_userPaused becomes false)
        reelGesture.onTap?.call();
        await tester.pump();

        expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
      },
    );
  });

  // --- Visibility detector ---

  group('Visibility changes', () {
    testWidgets('onVisibilityChanged fires with updateInterval=zero', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWidget(
          ReelPageWidget(
            reel: _makeReel(),
            isActive: true,
            isOwner: false,
            onLike: () {},
            onShop: () {},
            onShare: () {},
            onMenu: () {},
            onComments: () {},
          ),
        ),
      );

      // Pump — VisibilityDetector fires with the widget visible
      await tester.pump();
      // No crash, no assertions needed: just verifying it doesn't throw
    });
  });

  // --- Action rail callbacks ---

  group('Action callbacks', () {
    Future<void> pumpReel(
      WidgetTester tester, {
      required VoidCallback onLike,
      required VoidCallback onComments,
      required VoidCallback onShop,
      required VoidCallback onShare,
      required VoidCallback onMenu,
    }) async {
      await tester.pumpWidget(
        _wrapWidget(
          ReelPageWidget(
            reel: _makeReel(likes: 10, taggedCount: 2),
            isActive: false,
            isOwner: false,
            onLike: onLike,
            onComments: onComments,
            onShop: onShop,
            onShare: onShare,
            onMenu: onMenu,
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('tapping like button calls onLike', (
      WidgetTester tester,
    ) async {
      int likeCount = 0;
      await pumpReel(
        tester,
        onLike: () => likeCount++,
        onComments: () {},
        onShop: () {},
        onShare: () {},
        onMenu: () {},
      );

      await tester.tap(find.byIcon(Icons.favorite_border));
      expect(likeCount, 1);
    });

    testWidgets('liked reel shows filled heart icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWidget(
          ReelPageWidget(
            reel: _makeReel(isLiked: true, likes: 5),
            isActive: false,
            isOwner: false,
            onLike: () {},
            onShop: () {},
            onShare: () {},
            onMenu: () {},
            onComments: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('not-liked reel shows border heart icon', (
      WidgetTester tester,
    ) async {
      await pumpReel(
        tester,
        onLike: () {},
        onComments: () {},
        onShop: () {},
        onShare: () {},
        onMenu: () {},
      );

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('tapping comments button calls onComments', (
      WidgetTester tester,
    ) async {
      int commentCount = 0;
      await pumpReel(
        tester,
        onLike: () {},
        onComments: () => commentCount++,
        onShop: () {},
        onShare: () {},
        onMenu: () {},
      );

      await tester.tap(find.byIcon(Icons.mode_comment_outlined));
      expect(commentCount, 1);
    });

    testWidgets('tapping shop icon in rail calls onShop', (
      WidgetTester tester,
    ) async {
      int shopCount = 0;
      await pumpReel(
        tester,
        onLike: () {},
        onComments: () {},
        onShop: () => shopCount++,
        onShare: () {},
        onMenu: () {},
      );

      await tester.tap(find.byIcon(Icons.shopping_bag_outlined).first);
      expect(shopCount, 1);
    });

    testWidgets('tapping share button calls onShare', (
      WidgetTester tester,
    ) async {
      int shareCount = 0;
      await pumpReel(
        tester,
        onLike: () {},
        onComments: () {},
        onShop: () {},
        onShare: () => shareCount++,
        onMenu: () {},
      );

      await tester.tap(find.byIcon(Icons.ios_share_rounded));
      expect(shareCount, 1);
    });

    testWidgets('tapping menu button calls onMenu', (
      WidgetTester tester,
    ) async {
      int menuCount = 0;
      await pumpReel(
        tester,
        onLike: () {},
        onComments: () {},
        onShop: () {},
        onShare: () {},
        onMenu: () => menuCount++,
      );

      await tester.tap(find.byIcon(Icons.more_horiz));
      expect(menuCount, 1);
    });
  });

  // --- Caption ---

  group('Caption rendering', () {
    testWidgets('shows caption text when non-empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWidget(
          ReelPageWidget(
            reel: _makeReel(caption: 'My awesome reel'),
            isActive: false,
            isOwner: false,
            onLike: () {},
            onShop: () {},
            onShare: () {},
            onMenu: () {},
            onComments: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('My awesome reel'), findsOneWidget);
    });

    testWidgets('does not show empty caption text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWidget(
          ReelPageWidget(
            reel: _makeReel(caption: ''),
            isActive: false,
            isOwner: false,
            onLike: () {},
            onShop: () {},
            onShare: () {},
            onMenu: () {},
            onComments: () {},
          ),
        ),
      );
      await tester.pump();

      // Caption text is empty — no text for the caption itself
      // (author label and like count are still present)
      expect(find.text(''), findsNothing);
    });
  });

  // --- Author info ---

  group('Author info', () {
    testWidgets('displays author handle when present', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWidget(
          ReelPageWidget(
            reel: _makeReel(author: _kAuthor),
            isActive: false,
            isOwner: false,
            onLike: () {},
            onShop: () {},
            onShare: () {},
            onMenu: () {},
            onComments: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('@alice'), findsOneWidget);
    });

    testWidgets('shows PRO badge for pro author', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWidget(
          ReelPageWidget(
            reel: _makeReel(author: _kProAuthor),
            isActive: false,
            isOwner: false,
            onLike: () {},
            onShop: () {},
            onShare: () {},
            onMenu: () {},
            onComments: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('PRO'), findsOneWidget);
    });

    testWidgets('does not show PRO badge for non-pro author', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWidget(
          ReelPageWidget(
            reel: _makeReel(author: _kAuthor),
            isActive: false,
            isOwner: false,
            onLike: () {},
            onShop: () {},
            onShare: () {},
            onMenu: () {},
            onComments: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('PRO'), findsNothing);
    });

    testWidgets('shows person icon when avatar URL is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWidget(
          ReelPageWidget(
            reel: _makeReel(author: _kAuthor), // avatarUrl is null
            isActive: false,
            isOwner: false,
            onLike: () {},
            onShop: () {},
            onShare: () {},
            onMenu: () {},
            onComments: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('tapping author navigates to UserProfileRoute', (
      WidgetTester tester,
    ) async {
      final router = _MockStackRouter();
      when(
        () => router.push<Object?>(any(), onFailure: any(named: 'onFailure')),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(
        dsWrapRouted(
          ReelPageWidget(
            reel: _makeReel(author: _kAuthor),
            isActive: false,
            isOwner: false,
            onLike: () {},
            onShop: () {},
            onShare: () {},
            onMenu: () {},
            onComments: () {},
          ),
          router: router,
        ),
      );
      await tester.pump();

      // The author avatar/name is inside a CircleAvatar. Find the
      // GestureDetector that is an ancestor of the CircleAvatar.
      final Finder circleAvatarFinder = find.byType(CircleAvatar);
      expect(circleAvatarFinder, findsOneWidget);

      final Finder authorGestureFinder = find.ancestor(
        of: circleAvatarFinder,
        matching: find.byType(GestureDetector),
      );

      // Invoke the onTap of the innermost GestureDetector wrapping the author
      final GestureDetector authorGesture = tester.widget<GestureDetector>(
        authorGestureFinder.first,
      );
      authorGesture.onTap?.call();
      await tester.pump();

      verify(
        () => router.push<Object?>(any(), onFailure: any(named: 'onFailure')),
      ).called(1);
    });
  });

  // --- Shop CTA button in caption ---

  group('Shop CTA in caption', () {
    testWidgets('tapping shop CTA calls onShop', (WidgetTester tester) async {
      int shopCount = 0;
      await tester.pumpWidget(
        _wrapWidget(
          ReelPageWidget(
            reel: _makeReel(taggedCount: 3),
            isActive: false,
            isOwner: false,
            onLike: () {},
            onShop: () => shopCount++,
            onShare: () {},
            onMenu: () {},
            onComments: () {},
          ),
        ),
      );
      await tester.pump();

      // The caption area has a GestureDetector for the shop CTA.
      // Find the shopping bag icon in the caption (not the rail — use last)
      await tester.tap(find.byIcon(Icons.shopping_bag_outlined).last);
      expect(shopCount, greaterThanOrEqualTo(1));
    });
  });

  // --- Dispose ---

  group('Dispose', () {
    testWidgets('widget disposes without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWidget(
          ReelPageWidget(
            reel: _makeReel(playbackUrl: 'https://example.com/v.m3u8'),
            isActive: true,
            isOwner: false,
            onLike: () {},
            onShop: () {},
            onShare: () {},
            onMenu: () {},
            onComments: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Replace widget tree to trigger dispose
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      // No assertion — verifies no exception during dispose
    });
  });
}
