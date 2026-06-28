import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/onboarding/presentation/widget/personalize_removable_chip_widget.dart';

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

  group('PersonalizeRemovableChipWidget', () {
    testWidgets('renders label text', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(PersonalizeRemovableChipWidget(label: 'Nike', onRemove: () {})),
      );
      await tester.pump();

      expect(find.text('Nike'), findsOneWidget);
    });

    testWidgets('renders close icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(PersonalizeRemovableChipWidget(label: 'Adidas', onRemove: () {})),
      );
      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('calls onRemove when tapped', (WidgetTester tester) async {
      var removed = false;
      await tester.pumpWidget(
        _wrap(
          PersonalizeRemovableChipWidget(
            label: 'Zara',
            onRemove: () => removed = true,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Zara'));
      expect(removed, isTrue);
    });
  });
}
