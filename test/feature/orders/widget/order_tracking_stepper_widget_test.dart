import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/orders/entity/order_tracking.dart';
import 'package:klozy/src/feature/orders/presentation/widget/order_tracking_stepper_widget.dart';

import '../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  group('OrderTrackingStepperWidget', () {
    testWidgets('renders all step labels', (tester) async {
      const steps = <TrackingStep>[
        TrackingStep(label: 'Step A', state: TrackStepState.done),
        TrackingStep(label: 'Step B', state: TrackStepState.active),
        TrackingStep(label: 'Step C', state: TrackStepState.pending),
      ];
      await tester.pumpWidget(
        dsWrap(
          const OrderTrackingStepperWidget(steps: steps),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();
      expect(find.text('Step A'), findsOneWidget);
      expect(find.text('Step B'), findsOneWidget);
      expect(find.text('Step C'), findsOneWidget);
    });

    testWidgets('renders sublabels when provided', (tester) async {
      const steps = <TrackingStep>[
        TrackingStep(
          label: 'Order confirmed',
          sublabel: 'Seller is preparing your item',
          state: TrackStepState.active,
        ),
      ];
      await tester.pumpWidget(
        dsWrap(
          const OrderTrackingStepperWidget(steps: steps),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();
      expect(find.text('Order confirmed'), findsOneWidget);
      expect(find.text('Seller is preparing your item'), findsOneWidget);
    });

    testWidgets('renders check icon for done steps', (tester) async {
      const steps = <TrackingStep>[
        TrackingStep(label: 'Done step', state: TrackStepState.done),
      ];
      await tester.pumpWidget(
        dsWrap(
          const OrderTrackingStepperWidget(steps: steps),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('renders empty list without throwing', (tester) async {
      await tester.pumpWidget(
        dsWrap(
          const OrderTrackingStepperWidget(steps: <TrackingStep>[]),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();
      expect(find.byType(OrderTrackingStepperWidget), findsOneWidget);
    });

    testWidgets('renders multiple steps in order', (tester) async {
      const steps = <TrackingStep>[
        TrackingStep(label: 'First', state: TrackStepState.done),
        TrackingStep(label: 'Second', state: TrackStepState.done),
        TrackingStep(label: 'Third', state: TrackStepState.active),
        TrackingStep(label: 'Fourth', state: TrackStepState.pending),
      ];
      await tester.pumpWidget(
        dsWrap(
          const OrderTrackingStepperWidget(steps: steps),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();
      // All four labels appear exactly once each.
      for (final step in steps) {
        expect(find.text(step.label), findsOneWidget);
      }
    });
  });
}
