import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/onboarding/presentation/widget/personalize_section_title_widget.dart';

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

  group('PersonalizeSectionTitleWidget', () {
    testWidgets('renders title text', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const PersonalizeSectionTitleWidget(title: 'Categories')),
      );
      await tester.pump();

      expect(find.text('Categories'), findsOneWidget);
    });

    testWidgets('renders hint when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          const PersonalizeSectionTitleWidget(
            title: 'Brands',
            hint: 'Follow your favourites',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Brands'), findsOneWidget);
      expect(find.text('Follow your favourites'), findsOneWidget);
    });

    testWidgets('does not render hint when null', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const PersonalizeSectionTitleWidget(title: 'Sizes')),
      );
      await tester.pump();

      expect(find.text('Sizes'), findsOneWidget);
      // Only one text widget in the row — no hint.
      expect(
        tester
            .widgetList<Text>(
              find.descendant(
                of: find.byType(PersonalizeSectionTitleWidget),
                matching: find.byType(Text),
              ),
            )
            .length,
        1,
      );
    });

    testWidgets('renders trailing widget when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const PersonalizeSectionTitleWidget(
            title: 'Sizes',
            trailing: Icon(Icons.edit, key: Key('trailing-icon')),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('trailing-icon')), findsOneWidget);
    });
  });
}
