import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/audio_waveform.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: dsTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Center(child: SizedBox(width: 200, child: child)),
  ),
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AudioWaveform', () {
    testWidgets('renders at 0 progress', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          const AudioWaveform(
            barCount: 10,
            progress: 0,
            barColor: Colors.white,
            accent: Colors.yellow,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(AudioWaveform), findsOneWidget);
    });

    testWidgets('renders at 0.5 progress', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          const AudioWaveform(
            barCount: 22,
            progress: 0.5,
            barColor: Colors.white,
            accent: Colors.blue,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(AudioWaveform), findsOneWidget);
    });

    testWidgets('clamps progress above 1.0', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          const AudioWaveform(
            barCount: 5,
            progress: 1.5,
            barColor: Colors.grey,
            accent: Colors.green,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(AudioWaveform), findsOneWidget);
    });

    testWidgets('clamps progress below 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          const AudioWaveform(
            barCount: 5,
            progress: -0.5,
            barColor: Colors.grey,
            accent: Colors.green,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(AudioWaveform), findsOneWidget);
    });
  });
}
