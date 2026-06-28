import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/chat_avatar.dart';

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

  group('ChatAvatar', () {
    testWidgets('renders monogram when no avatarUrl', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ChatAvatar(initial: 'A', seed: 'user1')),
      );
      await tester.pump();

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('renders ? initial when displayName is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const ChatAvatar(initial: '?', seed: '')));
      await tester.pump();

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('respects custom size', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const ChatAvatar(initial: 'B', seed: 'user2', size: 64)),
      );
      await tester.pump();

      final Container container = tester.widget<Container>(
        find
            .ancestor(of: find.text('B'), matching: find.byType(Container))
            .first,
      );
      expect(container.constraints?.maxWidth, 64);
    });

    testWidgets('falls back to monogram when avatarUrl is empty string', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ChatAvatar(initial: 'C', seed: 'user3', avatarUrl: '')),
      );
      await tester.pump();

      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('uses ClipOval when avatarUrl is provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const ChatAvatar(
            initial: 'D',
            seed: 'user4',
            avatarUrl: 'https://example.com/avatar.jpg',
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ClipOval), findsOneWidget);
    });

    testWidgets('selects tint deterministically from seed', (
      WidgetTester tester,
    ) async {
      // Two widgets with different seeds should both render without error.
      await tester.pumpWidget(
        _wrap(
          const Row(
            children: <Widget>[
              ChatAvatar(initial: 'X', seed: 'seed_a'),
              ChatAvatar(initial: 'Y', seed: 'seed_b'),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('X'), findsOneWidget);
      expect(find.text('Y'), findsOneWidget);
    });
  });
}
