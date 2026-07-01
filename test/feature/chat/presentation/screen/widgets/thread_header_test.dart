import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_participant.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/chat_avatar.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/thread_header.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockStackRouter extends Mock implements StackRouter {}

Widget _wrap(Widget child, StackRouter router) => MaterialApp(
  theme: dsTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: StackRouterScope(
    controller: router,
    stateHash: 0,
    child: Scaffold(body: child),
  ),
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(UserProfileRoute(userId: ''));
  });

  group('ThreadHeader', () {
    late _MockStackRouter router;

    setUp(() {
      router = _MockStackRouter();
      when(
        () => router.push<Object?>(any(), onFailure: any(named: 'onFailure')),
      ).thenAnswer((_) async => null);
    });

    const ChatParticipant participant = ChatParticipant(
      id: 'u1',
      displayName: 'Alice Martin',
      rating: 4.5,
      isPro: false,
    );

    const ChatParticipant noRating = ChatParticipant(
      id: 'u2',
      displayName: 'Bob',
      rating: 0,
    );

    testWidgets('renders participant display name', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ThreadHeader(other: participant, onBack: () {}, onMenu: () {}),
          router,
        ),
      );
      await tester.pump();

      expect(find.text('Alice Martin'), findsOneWidget);
    });

    testWidgets('renders star rating when rating > 0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ThreadHeader(other: participant, onBack: () {}, onMenu: () {}),
          router,
        ),
      );
      await tester.pump();

      expect(find.textContaining('4.5'), findsOneWidget);
    });

    testWidgets('does not render rating line when rating is 0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ThreadHeader(other: noRating, onBack: () {}, onMenu: () {}),
          router,
        ),
      );
      await tester.pump();

      expect(find.textContaining('★'), findsNothing);
    });

    testWidgets('renders back chevron button', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          ThreadHeader(other: participant, onBack: () {}, onMenu: () {}),
          router,
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('calls onBack when back button pressed', (
      WidgetTester tester,
    ) async {
      var backed = false;
      await tester.pumpWidget(
        _wrap(
          ThreadHeader(
            other: participant,
            onBack: () => backed = true,
            onMenu: () {},
          ),
          router,
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.chevron_left));
      expect(backed, isTrue);
    });

    testWidgets('calls onMenu when overflow button pressed', (
      WidgetTester tester,
    ) async {
      var menuOpened = false;
      await tester.pumpWidget(
        _wrap(
          ThreadHeader(
            other: participant,
            onBack: () {},
            onMenu: () => menuOpened = true,
          ),
          router,
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_horiz));
      expect(menuOpened, isTrue);
    });

    testWidgets('renders ChatAvatar', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          ThreadHeader(other: participant, onBack: () {}, onMenu: () {}),
          router,
        ),
      );
      await tester.pump();

      expect(find.byType(ChatAvatar), findsOneWidget);
    });

    testWidgets('tapping avatar pushes UserProfileRoute', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ThreadHeader(other: participant, onBack: () {}, onMenu: () {}),
          router,
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(ChatAvatar));
      verify(
        () => router.push<Object?>(any(), onFailure: any(named: 'onFailure')),
      ).called(1);
    });
  });
}
