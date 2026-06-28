import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
import 'package:klozy/src/domain/offers/entity/offer.dart';
import 'package:klozy/src/feature/orders/presentation/widget/offer_row_widget.dart';

import '../../../support/ds_harness.dart';

const _kPendingOffer = Offer(
  id: 'offer-1',
  amount: 150,
  status: OfferStatus.pending,
  counterpartName: 'Bob',
);

const _kAcceptedOffer = Offer(
  id: 'offer-2',
  amount: 200,
  status: OfferStatus.accepted,
  counterpartName: 'Carol',
);

const _kDeclinedOffer = Offer(
  id: 'offer-3',
  amount: 80,
  status: OfferStatus.declined,
  counterpartName: 'Dave',
);

Widget _build({
  required Offer offer,
  required bool incoming,
  VoidCallback? onAccept,
  VoidCallback? onDecline,
  VoidCallback? onCancel,
}) => dsWrap(
  OfferRowWidget(
    offer: offer,
    incoming: incoming,
    onAccept: onAccept ?? () {},
    onDecline: onDecline ?? () {},
    onCancel: onCancel ?? () {},
  ),
  wrapInScaffold: true,
);

void main() {
  setUpAll(disableDsFonts);

  group('OfferRowWidget', () {
    group('counterpart info', () {
      testWidgets('renders counterpart name', (tester) async {
        await tester.pumpWidget(_build(offer: _kPendingOffer, incoming: true));
        await tester.pump();
        expect(find.text('Bob'), findsOneWidget);
      });

      testWidgets('renders offer amount in Dhs', (tester) async {
        await tester.pumpWidget(_build(offer: _kPendingOffer, incoming: true));
        await tester.pump();
        expect(find.text('150 Dhs'), findsOneWidget);
      });
    });

    group('pending + incoming', () {
      testWidgets('shows Accept (elevated) and Decline (outline) buttons', (
        tester,
      ) async {
        await tester.pumpWidget(_build(offer: _kPendingOffer, incoming: true));
        await tester.pump();
        expect(find.byType(DSButtonElevated), findsOneWidget);
        expect(find.byType(DSButtonOutline), findsOneWidget);
        expect(find.text('Accept'), findsOneWidget);
        expect(find.text('Decline'), findsOneWidget);
      });

      testWidgets('tapping Accept fires onAccept callback', (tester) async {
        bool accepted = false;
        await tester.pumpWidget(
          _build(
            offer: _kPendingOffer,
            incoming: true,
            onAccept: () => accepted = true,
          ),
        );
        await tester.pump();
        await tester.tap(find.text('Accept'));
        expect(accepted, isTrue);
      });

      testWidgets('tapping Decline fires onDecline callback', (tester) async {
        bool declined = false;
        await tester.pumpWidget(
          _build(
            offer: _kPendingOffer,
            incoming: true,
            onDecline: () => declined = true,
          ),
        );
        await tester.pump();
        await tester.tap(find.text('Decline'));
        expect(declined, isTrue);
      });
    });

    group('pending + outgoing', () {
      testWidgets('shows Cancel offer button (outline only)', (tester) async {
        await tester.pumpWidget(_build(offer: _kPendingOffer, incoming: false));
        await tester.pump();
        expect(find.byType(DSButtonElevated), findsNothing);
        expect(find.byType(DSButtonOutline), findsOneWidget);
        expect(find.text('Cancel offer'), findsOneWidget);
      });

      testWidgets('tapping Cancel offer fires onCancel callback', (
        tester,
      ) async {
        bool cancelled = false;
        await tester.pumpWidget(
          _build(
            offer: _kPendingOffer,
            incoming: false,
            onCancel: () => cancelled = true,
          ),
        );
        await tester.pump();
        await tester.tap(find.text('Cancel offer'));
        expect(cancelled, isTrue);
      });
    });

    group('non-pending offers', () {
      testWidgets('accepted offer hides action buttons', (tester) async {
        await tester.pumpWidget(_build(offer: _kAcceptedOffer, incoming: true));
        await tester.pump();
        expect(find.byType(DSButtonElevated), findsNothing);
        expect(find.byType(DSButtonOutline), findsNothing);
      });

      testWidgets('declined offer hides action buttons', (tester) async {
        await tester.pumpWidget(
          _build(offer: _kDeclinedOffer, incoming: false),
        );
        await tester.pump();
        expect(find.byType(DSButtonElevated), findsNothing);
        expect(find.byType(DSButtonOutline), findsNothing);
      });

      testWidgets('accepted offer shows ACCEPTED status pill', (tester) async {
        await tester.pumpWidget(
          _build(offer: _kAcceptedOffer, incoming: false),
        );
        await tester.pump();
        expect(find.text('ACCEPTED'), findsOneWidget);
      });

      testWidgets('pending offer shows PENDING status pill', (tester) async {
        await tester.pumpWidget(_build(offer: _kPendingOffer, incoming: true));
        await tester.pump();
        expect(find.text('PENDING'), findsOneWidget);
      });
    });
  });
}
