import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
import 'package:klozy/src/domain/social/entity/social_profile.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_actions_widget.dart';

import '../../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  const notFollowing = SocialProfile(
    id: 'u1',
    displayName: 'Alice',
    isFollowing: false,
  );
  const following = SocialProfile(
    id: 'u1',
    displayName: 'Alice',
    isFollowing: true,
  );

  testWidgets('shows DSButtonElevated when not following', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      dsWrap(
        ProfileActionsWidget(
          profile: notFollowing,
          onFollow: () {},
          onMessage: () {},
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(DSButtonElevated), findsOneWidget);
    expect(find.byType(DSButtonOutline), findsNothing);
    expect(find.text('Follow'), findsOneWidget);
  });

  testWidgets('shows DSButtonOutline when following', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      dsWrap(
        ProfileActionsWidget(
          profile: following,
          onFollow: () {},
          onMessage: () {},
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(DSButtonOutline), findsOneWidget);
    expect(find.byType(DSButtonElevated), findsNothing);
    expect(find.text('Following'), findsOneWidget);
  });

  testWidgets('calls onFollow when follow button is tapped', (
    WidgetTester tester,
  ) async {
    int calls = 0;
    await tester.pumpWidget(
      dsWrap(
        ProfileActionsWidget(
          profile: notFollowing,
          onFollow: () => calls++,
          onMessage: () {},
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Follow'));
    expect(calls, 1);
  });

  testWidgets('shows message icon button', (WidgetTester tester) async {
    await tester.pumpWidget(
      dsWrap(
        ProfileActionsWidget(
          profile: notFollowing,
          onFollow: () {},
          onMessage: () {},
        ),
      ),
    );
    await tester.pump();
    expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);
  });

  testWidgets('calls onMessage when message button is tapped', (
    WidgetTester tester,
  ) async {
    int calls = 0;
    await tester.pumpWidget(
      dsWrap(
        ProfileActionsWidget(
          profile: notFollowing,
          onFollow: () {},
          onMessage: () => calls++,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded));
    expect(calls, 1);
  });
}
