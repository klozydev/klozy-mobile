import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/media_lightbox.dart';

// Note: MediaLightbox's video path creates a VideoPlayerController and
// initialises it via a network call (unavailable in tests). The image path
// uses Image.network which fails in tests (no real HTTP). Tests therefore
// only cover the image mode and suppress expected network image errors.

bool _isNetworkImageError(FlutterErrorDetails d) =>
    d.exception.toString().contains('HTTP request failed') ||
    d.exception.toString().contains('NetworkImageLoadException');

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('MediaLightbox — image mode', () {
    testWidgets('renders close button', (WidgetTester tester) async {
      final void Function(FlutterErrorDetails)? original = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails d) {
        if (_isNetworkImageError(d)) return;
        original?.call(d);
      };
      addTearDown(() => FlutterError.onError = original);

      await tester.pumpWidget(
        MaterialApp(
          theme: dsTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MediaLightbox(
            url: 'https://example.com/img.jpg',
            isVideo: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('renders InteractiveViewer for image', (
      WidgetTester tester,
    ) async {
      final void Function(FlutterErrorDetails)? original = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails d) {
        if (_isNetworkImageError(d)) return;
        original?.call(d);
      };
      addTearDown(() => FlutterError.onError = original);

      await tester.pumpWidget(
        MaterialApp(
          theme: dsTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MediaLightbox(
            url: 'https://example.com/img.jpg',
            isVideo: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('close button pops the route', (WidgetTester tester) async {
      final void Function(FlutterErrorDetails)? original = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails d) {
        if (_isNetworkImageError(d)) return;
        original?.call(d);
      };
      addTearDown(() => FlutterError.onError = original);

      await tester.pumpWidget(
        MaterialApp(
          theme: dsTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MediaLightbox(
                      url: 'https://example.com/img.jpg',
                      isVideo: false,
                    ),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Note: pumpAndSettle can't be used here — the pushed MediaLightbox's
      // DSNetworkImage shows a ShimmerBoxWidget placeholder with a
      // perpetually-repeating AnimationController while the (unmockable,
      // always-failing in tests) network image resolves, so frames never
      // stop being scheduled. Bounded pumps that outlast the route
      // transition (300ms) are used instead.
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(MediaLightbox), findsOneWidget);

      // Invoke the close GestureDetector's onTap directly — the Positioned
      // button is outside the default test-viewport hit area.
      final GestureDetector closeGesture = tester.widget<GestureDetector>(
        find
            .ancestor(
              of: find.byIcon(Icons.close),
              matching: find.byType(GestureDetector),
            )
            .first,
      );
      closeGesture.onTap?.call();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      expect(find.byType(MediaLightbox), findsNothing);
    });

    testWidgets('MediaLightbox.open pushes fullscreen route', (
      WidgetTester tester,
    ) async {
      final void Function(FlutterErrorDetails)? original = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails d) {
        if (_isNetworkImageError(d)) return;
        original?.call(d);
      };
      addTearDown(() => FlutterError.onError = original);

      await tester.pumpWidget(
        MaterialApp(
          theme: dsTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => MediaLightbox.open(
                  context,
                  url: 'https://example.com/img.jpg',
                  isVideo: false,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(MediaLightbox), findsOneWidget);
    });
  });
}
