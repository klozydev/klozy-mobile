import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/design/components/ds_network_image/ds_network_image.dart';
import 'package:klozy/src/design/components/ds_network_image/ds_network_image_shape.dart';

import '../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  const Key fallbackKey = Key('fallback');
  const Widget fallback = SizedBox(key: fallbackKey);

  group('DSNetworkImage', () {
    testWidgets('shows fallback and no network image when url is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          const DSNetworkImage(imageUrl: null, fallback: fallback),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.byKey(fallbackKey), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets('shows fallback and no network image when url is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          const DSNetworkImage(imageUrl: '', fallback: fallback),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.byKey(fallbackKey), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets('renders a CachedNetworkImage when url is provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          const DSNetworkImage(
            imageUrl: 'https://example.com/photo.jpg',
            width: 100,
            height: 100,
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.byType(CachedNetworkImage), findsOneWidget);

      // The loading placeholder is an infinitely-animating shimmer; unmount and
      // flush so no timer is left pending at teardown.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('rounded shape clips with a ClipRRect', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          const DSNetworkImage(imageUrl: null, fallback: fallback),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.byType(ClipRRect), findsOneWidget);
      expect(find.byType(ClipOval), findsNothing);
    });

    testWidgets('circle shape clips with a ClipOval', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          const DSNetworkImage(
            imageUrl: null,
            width: 48,
            height: 48,
            shape: DSNetworkImageShape.circle,
            fallback: fallback,
          ),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.byType(ClipOval), findsOneWidget);
    });
  });
}
