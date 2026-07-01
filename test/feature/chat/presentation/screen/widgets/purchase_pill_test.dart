import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';
import 'package:klozy/src/feature/chat/domain/entity/purchase_data.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/purchase_pill.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: dsTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

const ChatMessage _purchaseMsg = ChatMessage(
  id: 'p1',
  threadId: 'thread1',
  senderId: 'buyer',
  kind: ChatMessageKind.purchase,
  isMine: false,
  purchase: PurchaseData(productName: 'Blue Sofa', amount: 450),
);

const ChatMessage _purchaseWholeAmount = ChatMessage(
  id: 'p2',
  threadId: 'thread1',
  senderId: 'buyer',
  kind: ChatMessageKind.purchase,
  isMine: true,
  purchase: PurchaseData(productName: 'Red Chair', amount: 200),
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('PurchasePill', () {
    testWidgets('renders product name', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const PurchasePill(message: _purchaseMsg)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Blue Sofa'), findsOneWidget);
    });

    testWidgets('renders integer amount without decimal', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const PurchasePill(message: _purchaseWholeAmount)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('200'), findsOneWidget);
    });

    testWidgets('renders when purchase is null gracefully', (
      WidgetTester tester,
    ) async {
      const ChatMessage noPurchase = ChatMessage(
        id: 'p3',
        threadId: 'thread1',
        senderId: 'buyer',
        kind: ChatMessageKind.purchase,
        isMine: false,
      );
      await tester.pumpWidget(_wrap(const PurchasePill(message: noPurchase)));
      await tester.pumpAndSettle();

      expect(find.byType(PurchasePill), findsOneWidget);
    });
  });
}
