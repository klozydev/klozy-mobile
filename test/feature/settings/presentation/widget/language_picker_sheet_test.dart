import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/app/theme/app_config_change_notifier.dart';
import 'package:klozy/src/core/l10n/app_language.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/feature/settings/presentation/widget/language_picker_sheet.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockAppConfigChangeNotifier extends Mock
    implements AppConfigChangeNotifier {}

void main() {
  setUpAll(disableDsFonts);

  late _MockAppConfigChangeNotifier mockConfig;

  setUp(() {
    mockConfig = _MockAppConfigChangeNotifier();
    when(() => mockConfig.setLocale(any())).thenAnswer((_) async {});

    if (locator.isRegistered<AppConfigChangeNotifier>()) {
      locator.unregister<AppConfigChangeNotifier>();
    }
    locator.registerSingleton<AppConfigChangeNotifier>(mockConfig);
  });

  tearDown(() {
    if (locator.isRegistered<AppConfigChangeNotifier>()) {
      locator.unregister<AppConfigChangeNotifier>();
    }
  });

  Widget pump(String currentCode) {
    return dsWrap(
      Scaffold(body: LanguagePickerSheet(currentCode: currentCode)),
    );
  }

  group('LanguagePickerSheet', () {
    testWidgets('renders ListTiles for languages (at least 10 visible)', (
      tester,
    ) async {
      // Widen the virtual screen so the full list fits without clipping.
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(pump('en'));
      await tester.pump();
      expect(find.byType(ListTile), findsNWidgets(kAppLanguages.length));
    });

    testWidgets('visible languages include English and French', (tester) async {
      await tester.pumpWidget(pump('en'));
      await tester.pump();
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Français'), findsOneWidget);
    });

    testWidgets('shows check icon for the currently selected language', (
      tester,
    ) async {
      await tester.pumpWidget(pump('fr'));
      await tester.pump();
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('no check icon when current code matches no language', (
      tester,
    ) async {
      await tester.pumpWidget(pump('zz'));
      await tester.pump();
      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });

    testWidgets('tapping a language calls setLocale with correct code', (
      tester,
    ) async {
      await tester.pumpWidget(pump('en'));
      await tester.pump();

      // Tap the second language (Arabic)
      final arabic = kAppLanguages[1];
      await tester.tap(find.text(arabic.name));
      await tester.pumpAndSettle();

      verify(() => mockConfig.setLocale(arabic.code)).called(1);
    });

    testWidgets('tapping a language dismisses the sheet (pops navigator)', (
      tester,
    ) async {
      await tester.pumpWidget(pump('en'));
      await tester.pump();

      final english = kAppLanguages[0];
      await tester.tap(find.text(english.name));
      await tester.pumpAndSettle();

      // After pop the LanguagePickerSheet should no longer be in the tree
      expect(find.byType(LanguagePickerSheet), findsNothing);
    });

    testWidgets('show() presents LanguagePickerSheet inside a bottom sheet', (
      tester,
    ) async {
      // Covers the static show() method body (lines 17-21).
      BuildContext? capturedCtx;
      await tester.pumpWidget(
        dsWrap(
          Scaffold(
            body: Builder(
              builder: (ctx) {
                capturedCtx = ctx;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Call the static helper — it pushes a bottom sheet via DSBottomSheet.
      unawaited(LanguagePickerSheet.show(capturedCtx!, 'Language', 'en'));
      await tester.pumpAndSettle();

      expect(find.byType(LanguagePickerSheet), findsOneWidget);
    });
  });
}
