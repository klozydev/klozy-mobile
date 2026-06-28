import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/config/entity/legal_doc.dart';
import 'package:klozy/src/domain/config/public_config_repository.dart';
import 'package:klozy/src/feature/home/presentation/widget/legal_acceptance_sheet.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/ds_harness.dart';

class _MockPublicConfigRepository extends Mock
    implements PublicConfigRepository {}

class _MockStackRouter extends Mock implements StackRouter {}

Widget _buildSheet(List<LegalDoc> docs, {StackRouter? router}) {
  final sheet = LegalAcceptanceSheet(docs: docs);
  if (router != null) {
    return dsWrapRouted(
      Scaffold(body: SingleChildScrollView(child: sheet)),
      router: router,
    );
  }
  return dsWrap(Scaffold(body: SingleChildScrollView(child: sheet)));
}

void main() {
  setUpAll(() {
    disableDsFonts();
    registerFallbackValue(LegalDocRoute(docKey: 'fallback'));
  });

  late _MockPublicConfigRepository mockConfigRepo;

  setUp(() {
    mockConfigRepo = _MockPublicConfigRepository();
    if (locator.isRegistered<PublicConfigRepository>()) {
      locator.unregister<PublicConfigRepository>();
    }
    locator.registerSingleton<PublicConfigRepository>(mockConfigRepo);
  });

  tearDown(() {
    if (locator.isRegistered<PublicConfigRepository>()) {
      locator.unregister<PublicConfigRepository>();
    }
  });

  const docs = [
    LegalDoc(key: 'tos', name: 'Terms of Service'),
    LegalDoc(key: 'privacy', name: 'Privacy Policy'),
  ];

  group('LegalAcceptanceSheet', () {
    testWidgets('renders legal pending message', (WidgetTester tester) async {
      await tester.pumpWidget(_buildSheet(docs));
      await tester.pump();

      expect(
        find.textContaining("We've updated our legal documents"),
        findsOneWidget,
      );
    });

    testWidgets('renders each document name', (WidgetTester tester) async {
      await tester.pumpWidget(_buildSheet(docs));
      await tester.pump();

      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
    });

    testWidgets('renders accept button', (WidgetTester tester) async {
      await tester.pumpWidget(_buildSheet(docs));
      await tester.pump();

      expect(find.text('Accept & continue'), findsOneWidget);
    });

    testWidgets('renders description icon for each doc', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_buildSheet(docs));
      await tester.pump();

      expect(find.byIcon(Icons.description_outlined), findsNWidgets(2));
    });

    testWidgets('tapping doc name pushes LegalDocRoute via router', (
      WidgetTester tester,
    ) async {
      final router = _MockStackRouter();
      when(
        () => router.push<Object?>(any(), onFailure: any(named: 'onFailure')),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(_buildSheet(docs, router: router));
      await tester.pump();

      await tester.tap(find.text('Terms of Service'));
      await tester.pump();

      final captured = verify(
        () => router.push<Object?>(
          captureAny(),
          onFailure: any(named: 'onFailure'),
        ),
      ).captured;
      expect(captured.single, isA<LegalDocRoute>());
    });

    testWidgets('tapping accept calls acceptLegal for each doc', (
      WidgetTester tester,
    ) async {
      when(() => mockConfigRepo.acceptLegal(any())).thenAnswer((_) async {});

      await tester.pumpWidget(_buildSheet(docs));
      await tester.pump();

      await tester.tap(find.text('Accept & continue'));
      // Kick off the async chain: each pump flushes one microtask layer.
      // _acceptAll sets _busy=true (no _busy=false on success) so we must NOT
      // use pumpAndSettle — the loading spinner would spin forever.
      await tester.pump(); // setState _busy=true
      await tester.pump(); // await acceptLegal('tos') resolves
      await tester.pump(); // await acceptLegal('privacy') resolves
      await tester.pump(); // maybePop + remaining frame

      verify(() => mockConfigRepo.acceptLegal('tos')).called(1);
      verify(() => mockConfigRepo.acceptLegal('privacy')).called(1);
    });
  });
}
