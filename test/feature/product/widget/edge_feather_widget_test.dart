import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/product/presentation/widget/edge_feather_widget.dart';

import '../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  group('EdgeFeatherWidget', () {
    testWidgets('renders its child', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          const EdgeFeatherWidget(
            child: SizedBox(key: Key('feather-child'), width: 100, height: 100),
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('feather-child')), findsOneWidget);
    });

    testWidgets('feathers a single axis with one dstIn shader mask', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          const EdgeFeatherWidget(
            axis: Axis.horizontal,
            child: SizedBox(width: 100, height: 100),
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      final List<ShaderMask> masks = tester
          .widgetList<ShaderMask>(find.byType(ShaderMask))
          .toList();
      expect(masks.length, 1);
      expect(masks.single.blendMode, BlendMode.dstIn);
    });
  });
}
