import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/onboarding/presentation/widget/personalize_sub_label_widget.dart';

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

  group('PersonalizeSubLabelWidget', () {
    testWidgets('renders label text', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const PersonalizeSubLabelWidget(label: 'Clothing')),
      );
      await tester.pump();

      expect(find.text('Clothing'), findsOneWidget);
    });

    testWidgets('wraps label in a Padding widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const PersonalizeSubLabelWidget(label: 'Shoes')),
      );
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(PersonalizeSubLabelWidget),
          matching: find.byType(Padding),
        ),
        findsOneWidget,
      );
    });
  });
}
