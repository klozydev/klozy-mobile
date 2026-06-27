import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/attach_choice.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/attach_sheet.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AttachSheet', () {
    testWidgets('renders photo and camera options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: dsTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: AttachSheet()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
      expect(find.byIcon(Icons.photo_camera_outlined), findsOneWidget);
    });

    testWidgets('pops AttachChoice.photo when photo option tapped', (
      WidgetTester tester,
    ) async {
      AttachChoice? result;

      await tester.pumpWidget(
        MaterialApp(
          theme: dsTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await showModalBottomSheet<AttachChoice>(
                    context: context,
                    builder: (_) => const AttachSheet(),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.photo_library_outlined));
      await tester.pumpAndSettle();

      expect(result, equals(AttachChoice.photo));
    });

    testWidgets('pops AttachChoice.camera when camera option tapped', (
      WidgetTester tester,
    ) async {
      AttachChoice? result;

      await tester.pumpWidget(
        MaterialApp(
          theme: dsTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await showModalBottomSheet<AttachChoice>(
                    context: context,
                    builder: (_) => const AttachSheet(),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.photo_camera_outlined));
      await tester.pumpAndSettle();

      expect(result, equals(AttachChoice.camera));
    });
  });
}
