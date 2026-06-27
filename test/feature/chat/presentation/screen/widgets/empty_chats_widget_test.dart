import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/empty_chats_widget.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: dsTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('EmptyChatsWidget', () {
    testWidgets('renders forum icon', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const EmptyChatsWidget()));
      await tester.pump();

      expect(find.byIcon(Icons.forum_outlined), findsOneWidget);
    });

    testWidgets('renders centered in parent', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const EmptyChatsWidget()));
      await tester.pump();

      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('renders title and subtitle text', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const EmptyChatsWidget()));
      await tester.pumpAndSettle();

      // At least two Text widgets present (title + subtitle).
      expect(find.byType(Text), findsAtLeastNWidgets(2));
    });
  });
}
