import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_carousel_backdrop_widget.dart';

import '../../../support/ds_harness.dart';

bool _hasLinearGradient(WidgetTester tester) {
  return tester.widgetList<DecoratedBox>(find.byType(DecoratedBox)).any((
    DecoratedBox box,
  ) {
    final Decoration decoration = box.decoration;
    return decoration is BoxDecoration && decoration.gradient is LinearGradient;
  });
}

void main() {
  setUpAll(disableDsFonts);

  group('ProductCarouselBackdropWidget', () {
    testWidgets('paints an edge-color gradient when the photo is letterboxed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          const SizedBox(
            width: 200,
            height: 600,
            // Portrait photo in a taller frame => top/bottom bars.
            child: ProductCarouselBackdropWidget(
              imageRatio: 0.8,
              topColor: Color(0xFFAAAAAA),
              bottomColor: Color(0xFF333333),
              leftColor: Color(0xFF222222),
              rightColor: Color(0xFF444444),
            ),
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(_hasLinearGradient(tester), isTrue);
    });

    testWidgets('skips the gradient when the photo fills the frame', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          const SizedBox(
            width: 300,
            height: 300,
            // Square photo in a square frame => no bars to paint.
            child: ProductCarouselBackdropWidget(
              imageRatio: 1,
              topColor: Color(0xFFAAAAAA),
              bottomColor: Color(0xFF333333),
              leftColor: Color(0xFF222222),
              rightColor: Color(0xFF444444),
            ),
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(_hasLinearGradient(tester), isFalse);
    });
  });
}
