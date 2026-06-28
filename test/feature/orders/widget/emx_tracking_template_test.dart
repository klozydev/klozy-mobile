import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/domain/orders/entity/order_status.dart';
import 'package:klozy/src/domain/orders/entity/order_tracking.dart';
import 'package:klozy/src/feature/orders/presentation/widget/emx_tracking_template.dart';

import '../../../support/ds_harness.dart';

/// Pumps a minimal localized tree and resolves [AppLocalizations] so we can
/// call [buildEmxTrackingSteps] with real copy without touching the network.
Future<AppLocalizations> _l10n(WidgetTester tester) async {
  AppLocalizations? result;
  await tester.pumpWidget(
    MaterialApp(
      theme: dsTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (ctx) {
          result = AppLocalizations.of(ctx);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return result!;
}

void main() {
  setUpAll(disableDsFonts);

  group('buildEmxTrackingSteps', () {
    testWidgets('always returns exactly 4 steps', (tester) async {
      final l10n = await _l10n(tester);
      for (final status in OrderStatus.values) {
        final steps = buildEmxTrackingSteps(l10n, status);
        expect(steps.length, 4, reason: 'status: $status');
      }
    });

    testWidgets('pending: step 0 active, steps 1-3 pending', (tester) async {
      final l10n = await _l10n(tester);
      final steps = buildEmxTrackingSteps(l10n, OrderStatus.pending);
      expect(steps[0].state, TrackStepState.active);
      expect(steps[1].state, TrackStepState.pending);
      expect(steps[2].state, TrackStepState.pending);
      expect(steps[3].state, TrackStepState.pending);
    });

    testWidgets('inDelivery: step 0 done, step 1 active, steps 2-3 pending', (
      tester,
    ) async {
      final l10n = await _l10n(tester);
      final steps = buildEmxTrackingSteps(l10n, OrderStatus.inDelivery);
      expect(steps[0].state, TrackStepState.done);
      expect(steps[1].state, TrackStepState.active);
      expect(steps[2].state, TrackStepState.pending);
      expect(steps[3].state, TrackStepState.pending);
    });

    testWidgets(
      'deliveryCompleted: steps 0-1 done, step 2 active, step 3 pending',
      (tester) async {
        final l10n = await _l10n(tester);
        final steps = buildEmxTrackingSteps(
          l10n,
          OrderStatus.deliveryCompleted,
        );
        expect(steps[0].state, TrackStepState.done);
        expect(steps[1].state, TrackStepState.done);
        expect(steps[2].state, TrackStepState.active);
        expect(steps[3].state, TrackStepState.pending);
      },
    );

    testWidgets('completed: steps 0-2 done, step 3 active', (tester) async {
      final l10n = await _l10n(tester);
      final steps = buildEmxTrackingSteps(l10n, OrderStatus.completed);
      expect(steps[0].state, TrackStepState.done);
      expect(steps[1].state, TrackStepState.done);
      expect(steps[2].state, TrackStepState.done);
      expect(steps[3].state, TrackStepState.active);
    });

    testWidgets('canceled collapses to last step active', (tester) async {
      final l10n = await _l10n(tester);
      final steps = buildEmxTrackingSteps(l10n, OrderStatus.canceled);
      expect(steps[3].state, TrackStepState.active);
    });

    testWidgets('step labels are non-empty strings', (tester) async {
      final l10n = await _l10n(tester);
      final steps = buildEmxTrackingSteps(l10n, OrderStatus.pending);
      for (final step in steps) {
        expect(step.label, isNotEmpty, reason: 'label should not be empty');
      }
    });

    testWidgets('all steps carry sublabels', (tester) async {
      final l10n = await _l10n(tester);
      final steps = buildEmxTrackingSteps(l10n, OrderStatus.pending);
      for (final step in steps) {
        expect(step.sublabel, isNotNull);
        expect(step.sublabel, isNotEmpty);
      }
    });
  });
}
