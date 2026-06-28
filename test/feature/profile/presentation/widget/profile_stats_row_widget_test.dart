import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_stats_row_widget.dart';

import '../../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  testWidgets('shows formatted follower and following counts', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      dsWrap(
        ProfileStatsRowWidget(
          followersCount: 1234,
          followingCount: 56,
          onFollowers: () {},
          onFollowing: () {},
        ),
      ),
    );
    await tester.pump();
    // intl decimal format: 1,234
    expect(find.text('1,234'), findsOneWidget);
    expect(find.text('56'), findsOneWidget);
    expect(find.text('Followers'), findsOneWidget);
    expect(find.text('Following'), findsOneWidget);
  });

  testWidgets('calls onFollowers when followers column is tapped', (
    WidgetTester tester,
  ) async {
    int calls = 0;
    await tester.pumpWidget(
      dsWrap(
        ProfileStatsRowWidget(
          followersCount: 10,
          followingCount: 5,
          onFollowers: () => calls++,
          onFollowing: () {},
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Followers'));
    expect(calls, 1);
  });

  testWidgets('calls onFollowing when following column is tapped', (
    WidgetTester tester,
  ) async {
    int calls = 0;
    await tester.pumpWidget(
      dsWrap(
        ProfileStatsRowWidget(
          followersCount: 10,
          followingCount: 5,
          onFollowers: () {},
          onFollowing: () => calls++,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Following'));
    expect(calls, 1);
  });
}
