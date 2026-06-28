import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/home/presentation/widget/notifications_bell_widget.dart';

import '../../../support/ds_harness.dart';

void main() {
  setUpAll(() {
    disableDsFonts();
  });

  group('NotificationsBellWidget', () {
    testWidgets('shows bell icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          NotificationsBellWidget(count: 0, onTap: () {}),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    });

    testWidgets('shows no badge when count is zero', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          NotificationsBellWidget(count: 0, onTap: () {}),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('0'), findsNothing);
    });

    testWidgets('shows badge text when count is positive', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        dsWrap(
          NotificationsBellWidget(count: 5, onTap: () {}),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows 99+ when count exceeds 99', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          NotificationsBellWidget(count: 100, onTap: () {}),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('exactly 99 shows as 99 not 99+', (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          NotificationsBellWidget(count: 99, onTap: () {}),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      expect(find.text('99'), findsOneWidget);
      expect(find.text('99+'), findsNothing);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      var tapped = false;
      await tester.pumpWidget(
        dsWrap(
          NotificationsBellWidget(count: 3, onTap: () => tapped = true),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(NotificationsBellWidget));
      expect(tapped, isTrue);
    });
  });
}
