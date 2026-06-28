import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_rating_summary.dart';

import '../../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  testWidgets('shows "No reviews yet" when reviewCount is 0', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      dsWrap(const ProfileRatingSummary(rating: 0, reviewCount: 0)),
    );
    await tester.pump();
    expect(find.text('No reviews yet'), findsOneWidget);
  });

  testWidgets('shows rating value and review count when reviewCount > 0', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      dsWrap(const ProfileRatingSummary(rating: 4.5, reviewCount: 12)),
    );
    await tester.pump();
    expect(find.text('4.5'), findsOneWidget);
    expect(find.text('(12)'), findsOneWidget);
    // "No reviews yet" must not appear.
    expect(find.text('No reviews yet'), findsNothing);
  });
}
