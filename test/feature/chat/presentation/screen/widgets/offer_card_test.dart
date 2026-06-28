import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';
import 'package:klozy/src/feature/chat/domain/entity/offer_data.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/offer_card.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: dsTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

// Pending incoming offer (not mine, pending).
const ChatMessage _incomingPending = ChatMessage(
  id: 'o1',
  threadId: 'thread1',
  senderId: 'other',
  kind: ChatMessageKind.offer,
  isMine: false,
  offer: OfferData(
    offerId: 'offer1',
    productName: 'Blue Sofa',
    listedPrice: 600,
    offerPrice: 450,
  ),
);

// Pending mine offer (mine, pending).
const ChatMessage _minePending = ChatMessage(
  id: 'o2',
  threadId: 'thread1',
  senderId: 'me',
  kind: ChatMessageKind.offer,
  isMine: true,
  offer: OfferData(
    offerId: 'offer2',
    productName: 'Red Chair',
    listedPrice: 300,
    offerPrice: 250,
  ),
);

// Accepted offer.
const ChatMessage _accepted = ChatMessage(
  id: 'o3',
  threadId: 'thread1',
  senderId: 'other',
  kind: ChatMessageKind.offer,
  isMine: false,
  offer: OfferData(
    offerId: 'offer3',
    productName: 'Table',
    listedPrice: 200,
    offerPrice: 180,
    accepted: true,
  ),
);

// Refused offer.
const ChatMessage _refused = ChatMessage(
  id: 'o4',
  threadId: 'thread1',
  senderId: 'other',
  kind: ChatMessageKind.offer,
  isMine: false,
  offer: OfferData(
    offerId: 'offer4',
    productName: 'Lamp',
    listedPrice: 50,
    offerPrice: 40,
    accepted: false,
  ),
);

// No offer payload.
const ChatMessage _noOffer = ChatMessage(
  id: 'o5',
  threadId: 'thread1',
  senderId: 'other',
  kind: ChatMessageKind.offer,
  isMine: false,
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('OfferCard', () {
    testWidgets('renders SizedBox.shrink when offer is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(OfferCard(message: _noOffer)));
      await tester.pump();

      expect(find.byType(SizedBox), findsWidgets);
      // The card container must NOT appear.
      expect(find.byType(OfferCard), findsOneWidget);
    });

    testWidgets('renders offer price for incoming pending offer', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          OfferCard(
            message: _incomingPending,
            onAccept: () {},
            onRefuse: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('450'), findsOneWidget);
    });

    testWidgets('shows accept and refuse buttons for incoming pending offer', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          OfferCard(
            message: _incomingPending,
            onAccept: () {},
            onRefuse: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Both action buttons must exist (accept + refuse).
      expect(find.byType(GestureDetector), findsAtLeastNWidgets(2));
    });

    testWidgets('calls onAccept when accept button tapped', (
      WidgetTester tester,
    ) async {
      var accepted = false;
      await tester.pumpWidget(
        _wrap(
          OfferCard(
            message: _incomingPending,
            onAccept: () => accepted = true,
            onRefuse: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The accept button text comes from localisation; find by text key.
      // Tap the last GestureDetector which is the accept button.
      final Finder acceptFinder = find.byType(GestureDetector).last;
      await tester.tap(acceptFinder);
      expect(accepted, isTrue);
    });

    testWidgets('calls onRefuse when refuse button tapped', (
      WidgetTester tester,
    ) async {
      var refused = false;
      await tester.pumpWidget(
        _wrap(
          OfferCard(
            message: _incomingPending,
            onAccept: () {},
            onRefuse: () => refused = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Refuse button is the first GestureDetector action button.
      final Finder refuseFinder = find.byType(GestureDetector).first;
      await tester.tap(refuseFinder);
      expect(refused, isTrue);
    });

    testWidgets('renders pending status for mine pending offer', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(OfferCard(message: _minePending)));
      await tester.pumpAndSettle();

      expect(find.textContaining('250'), findsOneWidget);
    });

    testWidgets('renders accepted offer without action buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(OfferCard(message: _accepted)));
      await tester.pumpAndSettle();

      expect(find.textContaining('180'), findsOneWidget);
    });

    testWidgets('renders refused offer', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(OfferCard(message: _refused)));
      await tester.pumpAndSettle();

      expect(find.textContaining('40'), findsOneWidget);
    });

    testWidgets('renders product name in header', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          OfferCard(
            message: _incomingPending,
            onAccept: () {},
            onRefuse: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Blue Sofa'), findsOneWidget);
    });
  });
}
