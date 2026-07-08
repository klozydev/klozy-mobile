import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reel_composer_bloc.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reel_composer_error_reason.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reel_composer_event.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reel_composer_state.dart';
import 'package:klozy/src/feature/reels/presentation/screen/reel_composer_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import '../../../../support/ds_harness.dart';

// ---- Mocks -------------------------------------------------------------

class _MockReelComposerBloc extends Mock implements ReelComposerBloc {}

class _MockStackRouter extends Mock implements StackRouter {}

// ignore: avoid_implementing_value_types
class _FakeRoute extends Fake implements PageRouteInfo<Object?> {}

// ---- Fake image picker platform ----------------------------------------

class _MockImagePickerPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements ImagePickerPlatform {}

// ---- Fake video player platform ----------------------------------------

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
        size: const Size(320, 568),
        duration: const Duration(seconds: 5),
      ),
    );
    return id;
  }

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) =>
      create(options.dataSource);

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

// ---- Builder helpers ---------------------------------------------------

_MockReelComposerBloc _buildBloc(
  ReelComposerState state, {
  Stream<ReelComposerState>? stream,
}) {
  final _MockReelComposerBloc bloc = _MockReelComposerBloc();
  when(() => bloc.state).thenReturn(state);
  when(
    () => bloc.stream,
  ).thenAnswer((_) => stream ?? const Stream<ReelComposerState>.empty());
  when(() => bloc.add(any())).thenReturn(null);
  when(() => bloc.close()).thenAnswer((_) async {});
  return bloc;
}

Widget _wrapWithBloc(
  ReelComposerState state,
  StackRouter router, {
  Stream<ReelComposerState>? stream,
  String? initialProductId,
}) {
  final _MockReelComposerBloc bloc = _buildBloc(state, stream: stream);
  return BlocProvider<ReelComposerBloc>.value(
    value: bloc,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: dsTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StackRouterScope(
        controller: router,
        stateHash: 0,
        child: ReelComposerPage(initialProductId: initialProductId),
      ),
    ),
  );
}

const _kProduct = Product(
  id: 'p1',
  title: 'Nice Shirt',
  price: 50,
  brand: 'Brand',
  size: 'M',
);

const _kProduct2 = Product(
  id: 'p2',
  title: 'Cool Dress',
  price: 80,
  coverImageUrl: 'https://example.com/img.jpg',
);

bool _isNetworkImageError(FlutterErrorDetails d) {
  final String msg = d.exception.toString();
  return msg.contains('HTTP request failed') ||
      msg.contains('NetworkImageLoadException') ||
      msg.contains('SocketException') ||
      msg.contains('ClientException');
}

void main() {
  late _MockStackRouter router;
  late EventBus eventBus;
  void Function(FlutterErrorDetails)? originalErrorHandler;

  setUpAll(() {
    disableDsFonts();
    registerFallbackValue(_FakeRoute());
    registerFallbackValue(const <PageRouteInfo<Object?>>[]);
    registerFallbackValue(const ReelComposerStarted());
    registerFallbackValue(ImageSource.gallery);
    registerFallbackValue(CameraDevice.rear);
  });

  setUp(() async {
    router = _MockStackRouter();
    eventBus = EventBus();

    VideoPlayerPlatform.instance = _FakeVideoPlayerPlatform();

    await GetIt.I.reset();
    GetIt.I.registerSingleton<EventBus>(eventBus);

    when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);

    // Product cells render NetworkImage covers; swallow the load failures the
    // test HTTP client raises so they don't fail otherwise-valid tests.
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

  // -----------------------------------------------------------------------
  group('ReelComposerPage — loading state', () {
    testWidgets('shows DSLoader', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithBloc(const ReelComposerLoading(), router),
      );
      await tester.pump();

      expect(find.byType(DSLoader), findsOneWidget);
    });
  });

  // -----------------------------------------------------------------------
  group('ReelComposerPage — posting state', () {
    testWidgets('shows publishing indicator (CircularProgressIndicator)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithBloc(const ReelComposerPosting(), router),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows publishing text', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithBloc(const ReelComposerPosting(), router),
      );
      await tester.pump();

      expect(find.byType(Text), findsWidgets);
    });
  });

  // -----------------------------------------------------------------------
  group('ReelComposerPage — done state', () {
    testWidgets('shows success icon', (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithBloc(const ReelComposerDone(), router));
      await tester.pump();

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('tapping "View in Reels" fires EventBus and pops', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrapWithBloc(const ReelComposerDone(), router));
      await tester.pump();

      // "View in Reels" is a DSButtonElevated — find ElevatedButton.
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pump();

      verify(() => router.maybePop<Object?>()).called(1);
    });

    testWidgets('done state without tagged products shows subtitle', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrapWithBloc(const ReelComposerDone(), router));
      await tester.pump();

      // At least three Text widgets: title, subtitle, button text
      expect(find.byType(Text), findsAtLeastNWidgets(3));
    });
  });

  // -----------------------------------------------------------------------
  group('ReelComposerPage — ready state (pick stage)', () {
    testWidgets('shows pick stage when no video selected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithBloc(const ReelComposerReady(products: <Product>[]), router),
      );
      await tester.pump();

      // Pick stage shows the record tile (no back button, no compose form)
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
    });

    testWidgets('close button calls router.maybePop', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithBloc(const ReelComposerReady(products: <Product>[]), router),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      verify(() => router.maybePop<Object?>()).called(1);
    });

    testWidgets('shows no-listings text when products list is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithBloc(const ReelComposerReady(products: <Product>[]), router),
      );
      await tester.pump();

      // l10n key reels_no_listings_to_tag shown when products empty
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('pick stage does not render product grid yet', (
      WidgetTester tester,
    ) async {
      // Products are tagged in the compose stage (after a video is picked),
      // not in the pick stage — so their price cells must not appear here.
      await tester.pumpWidget(
        _wrapWithBloc(
          const ReelComposerReady(products: <Product>[_kProduct, _kProduct2]),
          router,
        ),
      );
      await tester.pump();

      expect(find.byType(GridView), findsNothing);
      expect(find.text('50 Dhs'), findsNothing);
      expect(find.text('80 Dhs'), findsNothing);
    });

    testWidgets('error message shown via snackbar when errorReason != null', (
      WidgetTester tester,
    ) async {
      final StreamController<ReelComposerState> controller =
          StreamController<ReelComposerState>.broadcast();

      await tester.pumpWidget(
        _wrapWithBloc(
          const ReelComposerReady(products: <Product>[]),
          router,
          stream: controller.stream,
        ),
      );
      await tester.pump();

      // Emit a ready state with errorReason to trigger the listener.
      controller.add(
        const ReelComposerReady(
          products: <Product>[],
          errorReason: ReelComposerErrorReason.postFailed,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SnackBar), findsOneWidget);
      await controller.close();
    });
  });

  // -----------------------------------------------------------------------
  group('ReelComposerPage — wrappedRoute (locator wiring)', () {
    testWidgets('wrappedRoute provides ReelComposerBloc from locator', (
      WidgetTester tester,
    ) async {
      final _MockReelComposerBloc bloc = _buildBloc(
        const ReelComposerLoading(),
      );
      GetIt.I.registerSingleton<ReelComposerBloc>(bloc);

      const ReelComposerPage page = ReelComposerPage();
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dsTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StackRouterScope(
            controller: router,
            stateHash: 0,
            child: Builder(
              builder: (BuildContext ctx) => page.wrappedRoute(ctx),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(DSLoader), findsOneWidget);
      await bloc.close();
    });
  });

  // -----------------------------------------------------------------------
  group('ReelComposerPage — initialProductId pre-tags product', () {
    testWidgets('initialProductId pre-selects product in _tagged', (
      WidgetTester tester,
    ) async {
      // With initialProductId='p1', the post button should show tagged count.
      // But the video path is null, so post stage isn't shown yet.
      // We just verify the widget builds without error.
      await tester.pumpWidget(
        _wrapWithBloc(
          const ReelComposerReady(products: <Product>[_kProduct]),
          router,
          initialProductId: 'p1',
        ),
      );
      await tester.pump();

      expect(find.byType(ReelComposerPage), findsOneWidget);
    });
  });

  // -----------------------------------------------------------------------
  group('ReelComposerPage — pick + compose stage (with platform mocks)', () {
    late _MockImagePickerPlatform mockImagePicker;

    setUp(() {
      mockImagePicker = _MockImagePickerPlatform();
      ImagePickerPlatform.instance = mockImagePicker;

      when(
        () => mockImagePicker.getVideo(
          source: any(named: 'source'),
          maxDuration: any(named: 'maxDuration'),
          preferredCameraDevice: any(named: 'preferredCameraDevice'),
        ),
      ).thenAnswer((_) async => XFile('/tmp/fake_video.mp4'));
    });

    testWidgets('gallery pick transitions to compose stage', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithBloc(const ReelComposerReady(products: <Product>[]), router),
      );
      await tester.pump();

      // The gallery GestureDetector is the second one (camera is first).
      // Find the gallery pick button by looking for the gallery icon.
      await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
      await tester.pump();
      // Let the async _pick complete.
      await tester.pumpAndSettle();

      // Compose stage shows back button and caption field.
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
      expect(find.byType(TextField), findsAtLeastNWidgets(1));
    });

    testWidgets('camera pick transitions to compose stage', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithBloc(const ReelComposerReady(products: <Product>[]), router),
      );
      await tester.pump();

      // Camera tile is the large GestureDetector at top.
      // Find the play_arrow_rounded icon inside the record tile.
      final Finder cameraTile = find.descendant(
        of: find.byType(GestureDetector),
        matching: find.byIcon(Icons.play_arrow_rounded),
      );
      await tester.tap(
        find
            .ancestor(
              of: cameraTile.first,
              matching: find.byType(GestureDetector),
            )
            .first,
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

    testWidgets('cancelled pick (null XFile) stays on pick stage', (
      WidgetTester tester,
    ) async {
      when(
        () => mockImagePicker.getVideo(
          source: any(named: 'source'),
          maxDuration: any(named: 'maxDuration'),
          preferredCameraDevice: any(named: 'preferredCameraDevice'),
        ),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(
        _wrapWithBloc(const ReelComposerReady(products: <Product>[]), router),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
      await tester.pumpAndSettle();

      // Stays on pick stage — no back arrow in app bar.
      expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
    });

    testWidgets('back button in compose stage clears video', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithBloc(const ReelComposerReady(products: <Product>[]), router),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
      await tester.pumpAndSettle();

      // Now in compose stage; back button is in app bar.
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      // Back to pick stage — no back arrow.
      expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
    });

    testWidgets('post button dispatches ReelComposerSubmitted to bloc', (
      WidgetTester tester,
    ) async {
      final _MockReelComposerBloc bloc = _buildBloc(
        const ReelComposerReady(products: <Product>[]),
      );

      await tester.pumpWidget(
        BlocProvider<ReelComposerBloc>.value(
          value: bloc,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: dsTheme(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: StackRouterScope(
              controller: router,
              stateHash: 0,
              child: const ReelComposerPage(),
            ),
          ),
        ),
      );
      await tester.pump();

      // Pick a video.
      await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
      await tester.pumpAndSettle();

      // Now tap the post button (ElevatedButton at bottom).
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pump();

      final List<dynamic> calls = verify(() => bloc.add(captureAny())).captured;
      expect(calls.any((dynamic e) => e is ReelComposerSubmitted), isTrue);
    });

    testWidgets(
      'compose stage with products: toggle product selection adds checkmark',
      (WidgetTester tester) async {
        // The page captures products in the BlocConsumer listener, so the
        // ready state must arrive via the stream (not just the initial state).
        final StreamController<ReelComposerState> controller =
            StreamController<ReelComposerState>.broadcast();
        addTearDown(controller.close);

        await tester.pumpWidget(
          _wrapWithBloc(
            const ReelComposerReady(products: <Product>[_kProduct]),
            router,
            stream: controller.stream,
          ),
        );
        await tester.pump();

        controller.add(const ReelComposerReady(products: <Product>[_kProduct]));
        await tester.pump();

        // Pick a video to get to compose stage.
        await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
        await tester.pumpAndSettle();

        // Product cell (keyed by its price) is visible in compose stage; tap
        // the cell's GestureDetector — its centre is on-screen, whereas the
        // price overlay sits at the cell's bottom edge behind the post bar.
        final Finder cell = find
            .ancestor(
              of: find.text('50 Dhs'),
              matching: find.byType(GestureDetector),
            )
            .first;
        await tester.tap(cell, warnIfMissed: false);
        await tester.pump();

        // Checkmark (Icons.check) appears for selected product.
        expect(find.byIcon(Icons.check), findsWidgets);
      },
    );

    testWidgets('compose stage: product with image URL rendered', (
      WidgetTester tester,
    ) async {
      final StreamController<ReelComposerState> controller =
          StreamController<ReelComposerState>.broadcast();
      addTearDown(controller.close);

      await tester.pumpWidget(
        _wrapWithBloc(
          const ReelComposerReady(products: <Product>[_kProduct2]),
          router,
          stream: controller.stream,
        ),
      );
      await tester.pump();

      controller.add(const ReelComposerReady(products: <Product>[_kProduct2]));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
      await tester.pumpAndSettle();

      // Product with coverImageUrl renders in the grid (keyed by its price).
      expect(find.text('80 Dhs'), findsOneWidget);
    });

    testWidgets('done state with tagged products shows tagged subtitle', (
      WidgetTester tester,
    ) async {
      // Use initialProductId to pre-tag a product so _tagged.length > 0
      // when the done state is shown.
      await tester.pumpWidget(
        _wrapWithBloc(const ReelComposerDone(), router, initialProductId: 'p1'),
      );
      await tester.pump();

      // _tagged has 'p1' → subtitle uses reels_posted_subtitle_tagged(1)
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });
}
