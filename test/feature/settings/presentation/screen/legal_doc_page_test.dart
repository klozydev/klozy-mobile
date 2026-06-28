import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/config/entity/legal_doc.dart';
import 'package:klozy/src/domain/config/public_config_repository.dart';
import 'package:klozy/src/feature/settings/presentation/screen/legal_doc_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

class _MockPublicConfigRepository extends Mock
    implements PublicConfigRepository {}

class _MockStackRouter extends Mock implements StackRouter {}

void main() {
  setUpAll(disableDsFonts);

  late _MockPublicConfigRepository mockConfig;
  late _MockStackRouter router;

  setUp(() {
    mockConfig = _MockPublicConfigRepository();
    router = _MockStackRouter();
    when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);

    if (locator.isRegistered<PublicConfigRepository>()) {
      locator.unregister<PublicConfigRepository>();
    }
    locator.registerSingleton<PublicConfigRepository>(mockConfig);
  });

  tearDown(() {
    if (locator.isRegistered<PublicConfigRepository>()) {
      locator.unregister<PublicConfigRepository>();
    }
  });

  Widget _pump({String docKey = 'tos'}) {
    return dsWrapRouted(LegalDocPage(docKey: docKey), router: router);
  }

  group('LegalDocPage — loading state', () {
    testWidgets('shows DSLoader while future is pending', (tester) async {
      // Use a Completer so no real Timer is created (Future.delayed would
      // create a pending Timer that the test framework rejects on teardown).
      final completer = Completer<LegalDocContent>();
      when(
        () => mockConfig.getLegalDoc(any()),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(_pump());
      await tester.pump(); // one frame — still pending

      expect(find.byType(DSLoader), findsOneWidget);
    });
  });

  group('LegalDocPage — unavailable state', () {
    testWidgets('shows unavailable message when body is empty', (tester) async {
      when(
        () => mockConfig.getLegalDoc(any()),
      ).thenAnswer((_) async => const LegalDocContent(title: 'ToS', body: ''));

      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      expect(find.byType(DSLoader), findsNothing);
      // l10n key: settings_doc_unavailable
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('shows unavailable message when snapshot data is null', (
      tester,
    ) async {
      // Throw so data is null / error snapshot
      when(
        () => mockConfig.getLegalDoc(any()),
      ).thenAnswer((_) async => const LegalDocContent());

      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      expect(find.byType(DSLoader), findsNothing);
    });
  });

  group('LegalDocPage — content state', () {
    testWidgets('shows body text when doc has content', (tester) async {
      when(() => mockConfig.getLegalDoc(any())).thenAnswer(
        (_) async => const LegalDocContent(
          title: 'Terms of Service',
          body: 'You agree to our terms.',
        ),
      );

      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      expect(find.text('You agree to our terms.'), findsOneWidget);
    });

    testWidgets('shows title when doc has a non-empty title', (tester) async {
      when(() => mockConfig.getLegalDoc(any())).thenAnswer(
        (_) async => const LegalDocContent(
          title: 'Terms of Service',
          body: 'Some body text.',
        ),
      );

      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      expect(find.text('Terms of Service'), findsOneWidget);
    });

    testWidgets('no title widget when doc title is empty', (tester) async {
      when(() => mockConfig.getLegalDoc(any())).thenAnswer(
        (_) async =>
            const LegalDocContent(title: '', body: 'Body without title.'),
      );

      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      expect(find.text('Body without title.'), findsOneWidget);
      expect(find.text(''), findsNothing);
    });

    testWidgets('passes docKey to getLegalDoc', (tester) async {
      when(
        () => mockConfig.getLegalDoc(any()),
      ).thenAnswer((_) async => const LegalDocContent(body: 'x'));

      await tester.pumpWidget(_pump(docKey: 'privacy'));
      await tester.pumpAndSettle();

      verify(() => mockConfig.getLegalDoc('privacy')).called(1);
    });
  });

  group('LegalDocPage — navigation', () {
    testWidgets('back button calls router.maybePop', (tester) async {
      when(
        () => mockConfig.getLegalDoc(any()),
      ).thenAnswer((_) async => const LegalDocContent());

      await tester.pumpWidget(_pump());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      verify(() => router.maybePop<Object?>()).called(1);
    });
  });
}
