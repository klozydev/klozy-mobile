import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/onboarding/presentation/widget/personalize_add_chip_widget.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: dsTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('PersonalizeAddChipWidget', () {
    testWidgets('renders label text', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(PersonalizeAddChipWidget(label: 'Add categories', onTap: () {})),
      );
      await tester.pump();

      expect(find.text('Add categories'), findsOneWidget);
    });

    testWidgets('renders add icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(PersonalizeAddChipWidget(label: 'Add', onTap: () {})),
      );
      await tester.pump();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          PersonalizeAddChipWidget(
            label: 'Add something',
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Add something'));
      expect(tapped, isTrue);
    });
  });
}
