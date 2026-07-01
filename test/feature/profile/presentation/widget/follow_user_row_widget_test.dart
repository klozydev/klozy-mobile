import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/social/entity/follow_user.dart';
import 'package:klozy/src/feature/profile/presentation/widget/follow_user_row_widget.dart';

import '../../../../support/ds_harness.dart';

bool _isNetworkError(FlutterErrorDetails d) {
  final msg = d.exception.toString();
  return msg.contains('HTTP request failed') ||
      msg.contains('NetworkImageLoadException') ||
      msg.contains('SocketException') ||
      msg.contains('Failed to load');
}

void main() {
  setUpAll(disableDsFonts);

  const user = FollowUser(
    id: 'u1',
    displayName: 'Bob Jones',
    isFollowing: false,
    isPro: false,
  );

  testWidgets('shows display name', (WidgetTester tester) async {
    await tester.pumpWidget(
      dsWrap(
        FollowUserRowWidget(user: user, onTap: () {}, onToggleFollow: () {}),
        wrapInScaffold: true,
      ),
    );
    await tester.pump();
    expect(find.text('Bob Jones'), findsOneWidget);
  });

  testWidgets('shows "Follow" when not following', (WidgetTester tester) async {
    await tester.pumpWidget(
      dsWrap(
        FollowUserRowWidget(user: user, onTap: () {}, onToggleFollow: () {}),
        wrapInScaffold: true,
      ),
    );
    await tester.pump();
    expect(find.text('Follow'), findsOneWidget);
    expect(find.text('Following'), findsNothing);
  });

  testWidgets('shows "Following" when already following', (
    WidgetTester tester,
  ) async {
    const followingUser = FollowUser(
      id: 'u1',
      displayName: 'Bob',
      isFollowing: true,
    );
    await tester.pumpWidget(
      dsWrap(
        FollowUserRowWidget(
          user: followingUser,
          onTap: () {},
          onToggleFollow: () {},
        ),
        wrapInScaffold: true,
      ),
    );
    await tester.pump();
    expect(find.text('Following'), findsOneWidget);
    expect(find.text('Follow'), findsNothing);
  });

  testWidgets('shows PRO badge when isPro is true', (
    WidgetTester tester,
  ) async {
    const proUser = FollowUser(id: 'u1', displayName: 'Pro', isPro: true);
    await tester.pumpWidget(
      dsWrap(
        FollowUserRowWidget(user: proUser, onTap: () {}, onToggleFollow: () {}),
        wrapInScaffold: true,
      ),
    );
    await tester.pump();
    expect(find.text('PRO'), findsOneWidget);
  });

  testWidgets('does not show PRO badge when isPro is false', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      dsWrap(
        FollowUserRowWidget(user: user, onTap: () {}, onToggleFollow: () {}),
        wrapInScaffold: true,
      ),
    );
    await tester.pump();
    expect(find.text('PRO'), findsNothing);
  });

  testWidgets('shows person icon when avatarUrl is null', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      dsWrap(
        FollowUserRowWidget(user: user, onTap: () {}, onToggleFollow: () {}),
        wrapInScaffold: true,
      ),
    );
    await tester.pump();
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('does not show person icon when avatarUrl is set', (
    WidgetTester tester,
  ) async {
    final prev = FlutterError.onError;
    FlutterError.onError = (d) {
      if (_isNetworkError(d)) return;
      prev?.call(d);
    };
    addTearDown(() => FlutterError.onError = prev);

    const userWithAvatar = FollowUser(
      id: 'u1',
      displayName: 'Bob',
      avatarUrl: 'https://example.com/bob.jpg',
    );
    await tester.pumpWidget(
      dsWrap(
        FollowUserRowWidget(
          user: userWithAvatar,
          onTap: () {},
          onToggleFollow: () {},
        ),
        wrapInScaffold: true,
      ),
    );
    await tester.pump();
    expect(find.byIcon(Icons.person), findsNothing);
  });

  testWidgets('calls onTap when row is tapped', (WidgetTester tester) async {
    int tapCalls = 0;
    await tester.pumpWidget(
      dsWrap(
        FollowUserRowWidget(
          user: user,
          onTap: () => tapCalls++,
          onToggleFollow: () {},
        ),
        wrapInScaffold: true,
      ),
    );
    await tester.pump();
    // Tap on the name to trigger the GestureDetector wrapping the row
    await tester.tap(find.text('Bob Jones'));
    expect(tapCalls, 1);
  });

  testWidgets('calls onToggleFollow when follow button is tapped', (
    WidgetTester tester,
  ) async {
    int toggleCalls = 0;
    await tester.pumpWidget(
      dsWrap(
        FollowUserRowWidget(
          user: user,
          onTap: () {},
          onToggleFollow: () => toggleCalls++,
        ),
        wrapInScaffold: true,
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Follow'));
    expect(toggleCalls, 1);
  });
}
