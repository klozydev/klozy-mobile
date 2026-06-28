import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_menu_sheet.dart';

import '../../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  testWidgets('shows Report user and Block user rows', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      dsWrap(
        ProfileMenuSheet(onReport: () {}, onBlock: () {}),
        wrapInScaffold: true,
      ),
    );
    await tester.pump();
    expect(find.text('Report user'), findsOneWidget);
    expect(find.text('Block user'), findsOneWidget);
  });

  testWidgets('calls onReport when report row is tapped', (
    WidgetTester tester,
  ) async {
    int reportCalls = 0;
    await tester.pumpWidget(
      dsWrap(
        ProfileMenuSheet(onReport: () => reportCalls++, onBlock: () {}),
        wrapInScaffold: true,
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Report user'));
    expect(reportCalls, 1);
  });

  testWidgets('calls onBlock when block row is tapped', (
    WidgetTester tester,
  ) async {
    int blockCalls = 0;
    await tester.pumpWidget(
      dsWrap(
        ProfileMenuSheet(onReport: () {}, onBlock: () => blockCalls++),
        wrapInScaffold: true,
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Block user'));
    expect(blockCalls, 1);
  });
}
