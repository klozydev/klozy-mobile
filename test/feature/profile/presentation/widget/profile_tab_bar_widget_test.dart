import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_tab_bar_widget.dart';

import '../../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  testWidgets('renders three tab labels', (WidgetTester tester) async {
    final controller = TabController(length: 3, vsync: const TestVSync());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      dsWrap(
        ProfileTabBarWidget(tabController: controller),
        wrapInScaffold: true,
      ),
    );
    await tester.pump();

    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Reels'), findsOneWidget);
    expect(find.text('Reviews'), findsOneWidget);
  });
}
