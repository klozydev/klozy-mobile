import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_circle_button.dart';

import '../../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  testWidgets('renders the given icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      dsWrap(ProfileCircleButton(icon: Icons.settings_outlined, onTap: () {})),
    );
    await tester.pump();
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('does not show badge when showBadge is false', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      dsWrap(
        ProfileCircleButton(
          icon: Icons.notifications_none_rounded,
          onTap: () {},
          showBadge: false,
        ),
      ),
    );
    await tester.pump();
    // Badge is a Positioned inside a Stack — presence detected by the
    // number of Container children inside the Stack.
    final stack = tester.widget<Stack>(find.byType(Stack).first);
    expect(stack.children.length, 1); // only the Icon, no badge
  });

  testWidgets('shows badge dot when showBadge is true', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      dsWrap(
        ProfileCircleButton(
          icon: Icons.notifications_none_rounded,
          onTap: () {},
          showBadge: true,
        ),
      ),
    );
    await tester.pump();
    final stack = tester.widget<Stack>(find.byType(Stack).first);
    expect(stack.children.length, 2); // Icon + Positioned badge
  });

  testWidgets('calls onTap when tapped', (WidgetTester tester) async {
    int calls = 0;
    await tester.pumpWidget(
      dsWrap(
        ProfileCircleButton(
          icon: Icons.shopping_bag_outlined,
          onTap: () => calls++,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byType(ProfileCircleButton));
    expect(calls, 1);
  });
}
