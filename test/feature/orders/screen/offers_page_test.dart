import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/offers/entity/offer.dart';
import 'package:klozy/src/domain/offers/offers_repository.dart';
import 'package:klozy/src/feature/orders/presentation/screen/offers_page.dart';
import 'package:klozy/src/feature/orders/presentation/widget/offer_row_widget.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/ds_harness.dart';

class _MockOffersRepository extends Mock implements OffersRepository {}

class _MockStackRouter extends Mock implements StackRouter {}

Widget _wrap(StackRouter router) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: dsTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: StackRouterScope(
      controller: router,
      stateHash: 0,
      child: const OffersPage(),
    ),
  );
}

const _kOffer = Offer(
  id: 'offer-1',
  amount: 100,
  status: OfferStatus.pending,
  counterpartName: 'Alice',
);

void main() {
  setUpAll(disableDsFonts);

  late _MockOffersRepository mockRepo;
  late _MockStackRouter router;

  setUp(() async {
    mockRepo = _MockOffersRepository();
    router = _MockStackRouter();
    when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);
    // Register mock so OffersPage field initializer resolves to the mock.
    await locator.reset();
    locator.registerSingleton<OffersRepository>(mockRepo);
  });

  tearDown(() async {
    await locator.reset();
  });

  group('OffersPage', () {
    testWidgets('shows DSLoader while loading', (tester) async {
      // Use Completers that never resolve so the loading state persists.
      final incomingCompleter = Completer<List<Offer>>();
      final outgoingCompleter = Completer<List<Offer>>();
      when(
        () => mockRepo.listOffers(incoming: true),
      ).thenAnswer((_) => incomingCompleter.future);
      when(
        () => mockRepo.listOffers(incoming: false),
      ).thenAnswer((_) => outgoingCompleter.future);

      await tester.pumpWidget(_wrap(router));
      // First frame: _loading == true, futures pending → DSLoader visible.
      expect(find.byType(DSLoader), findsOneWidget);

      // Resolve completers to allow clean teardown.
      incomingCompleter.complete(<Offer>[]);
      outgoingCompleter.complete(<Offer>[]);
      await tester.pumpAndSettle();
    });

    testWidgets('shows empty message when no incoming offers', (tester) async {
      when(
        () => mockRepo.listOffers(incoming: true),
      ).thenAnswer((_) async => <Offer>[]);
      when(
        () => mockRepo.listOffers(incoming: false),
      ).thenAnswer((_) async => <Offer>[]);

      await tester.pumpWidget(_wrap(router));
      await tester.pumpAndSettle();

      expect(find.text('No offers here yet.'), findsOneWidget);
    });

    testWidgets('shows OfferRowWidget for each incoming offer', (tester) async {
      when(
        () => mockRepo.listOffers(incoming: true),
      ).thenAnswer((_) async => <Offer>[_kOffer]);
      when(
        () => mockRepo.listOffers(incoming: false),
      ).thenAnswer((_) async => <Offer>[]);

      await tester.pumpWidget(_wrap(router));
      await tester.pumpAndSettle();

      expect(find.byType(OfferRowWidget), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('renders Incoming and Outgoing tab labels', (tester) async {
      when(
        () => mockRepo.listOffers(incoming: true),
      ).thenAnswer((_) async => <Offer>[]);
      when(
        () => mockRepo.listOffers(incoming: false),
      ).thenAnswer((_) async => <Offer>[]);

      await tester.pumpWidget(_wrap(router));
      await tester.pumpAndSettle();

      expect(find.text('Incoming'), findsOneWidget);
      expect(find.text('Outgoing'), findsOneWidget);
    });

    testWidgets('switching to Outgoing tab shows outgoing offers', (
      tester,
    ) async {
      const outgoing = Offer(
        id: 'offer-out-1',
        amount: 200,
        status: OfferStatus.pending,
        counterpartName: 'Bob',
      );
      when(
        () => mockRepo.listOffers(incoming: true),
      ).thenAnswer((_) async => <Offer>[]);
      when(
        () => mockRepo.listOffers(incoming: false),
      ).thenAnswer((_) async => <Offer>[outgoing]);

      await tester.pumpWidget(_wrap(router));
      await tester.pumpAndSettle();

      // Currently on Incoming tab → empty
      expect(find.byType(OfferRowWidget), findsNothing);

      // Switch to Outgoing tab
      await tester.tap(find.text('Outgoing'));
      await tester.pump();

      expect(find.byType(OfferRowWidget), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('app bar shows Offers title', (tester) async {
      when(
        () => mockRepo.listOffers(incoming: true),
      ).thenAnswer((_) async => <Offer>[]);
      when(
        () => mockRepo.listOffers(incoming: false),
      ).thenAnswer((_) async => <Offer>[]);

      await tester.pumpWidget(_wrap(router));
      await tester.pumpAndSettle();

      expect(find.text('Offers'), findsOneWidget);
    });
  });
}
