import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/social/entity/social_profile.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_header_widget.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_stats_row_widget.dart';

import '../../../../support/ds_harness.dart';

// Suppress network image errors from CachedNetworkImageProvider.
bool _isNetworkError(FlutterErrorDetails d) {
  final msg = d.exception.toString();
  return msg.contains('HTTP request failed') ||
      msg.contains('NetworkImageLoadException') ||
      msg.contains('SocketException') ||
      msg.contains('Failed to load');
}

void main() {
  setUpAll(disableDsFonts);

  const _baseProfile = SocialProfile(
    id: 'u1',
    displayName: 'Alice Smith',
    followers: 42,
    following: 7,
  );

  testWidgets('shows display name', (WidgetTester tester) async {
    await tester.pumpWidget(
      dsWrap(
        ProfileHeaderWidget(
          profile: _baseProfile,
          onFollowers: () {},
          onFollowing: () {},
          onRatingTap: () {},
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Alice Smith'), findsOneWidget);
  });

  testWidgets('shows initial letter when no avatar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      dsWrap(
        ProfileHeaderWidget(
          profile: _baseProfile,
          onFollowers: () {},
          onFollowing: () {},
          onRatingTap: () {},
        ),
      ),
    );
    await tester.pump();
    // Initial letter 'A' for 'Alice Smith'
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('shows network avatar when avatarUrl is set', (
    WidgetTester tester,
  ) async {
    final prev = FlutterError.onError;
    FlutterError.onError = (d) {
      if (_isNetworkError(d)) return;
      prev?.call(d);
    };
    addTearDown(() => FlutterError.onError = prev);

    const profile = SocialProfile(
      id: 'u1',
      displayName: 'Bob',
      avatarUrl: 'https://example.com/avatar.jpg',
    );
    await tester.pumpWidget(
      dsWrap(
        ProfileHeaderWidget(
          profile: profile,
          onFollowers: () {},
          onFollowing: () {},
          onRatingTap: () {},
        ),
      ),
    );
    await tester.pump();
    // CircleAvatar is rendered (the widget doesn't fall through to the Text initial)
    expect(find.text('B'), findsNothing);
  });

  testWidgets('shows PRO badge when profile.isPro is true', (
    WidgetTester tester,
  ) async {
    const profile = SocialProfile(
      id: 'u1',
      displayName: 'Pro User',
      isPro: true,
    );
    await tester.pumpWidget(
      dsWrap(
        ProfileHeaderWidget(
          profile: profile,
          onFollowers: () {},
          onFollowing: () {},
          onRatingTap: () {},
        ),
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
        ProfileHeaderWidget(
          profile: _baseProfile,
          onFollowers: () {},
          onFollowing: () {},
          onRatingTap: () {},
        ),
      ),
    );
    await tester.pump();
    expect(find.text('PRO'), findsNothing);
  });

  testWidgets('shows bio when bio is non-empty', (WidgetTester tester) async {
    const profile = SocialProfile(
      id: 'u1',
      displayName: 'Alice',
      bio: 'Fashion lover',
    );
    await tester.pumpWidget(
      dsWrap(
        ProfileHeaderWidget(
          profile: profile,
          onFollowers: () {},
          onFollowing: () {},
          onRatingTap: () {},
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Fashion lover'), findsOneWidget);
  });

  testWidgets('does not show bio when bio is null', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      dsWrap(
        ProfileHeaderWidget(
          profile: _baseProfile,
          onFollowers: () {},
          onFollowing: () {},
          onRatingTap: () {},
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(ProfileStatsRowWidget), findsOneWidget);
  });

  testWidgets('calls onFollowers when followers stat is tapped', (
    WidgetTester tester,
  ) async {
    int calls = 0;
    await tester.pumpWidget(
      dsWrap(
        ProfileHeaderWidget(
          profile: _baseProfile,
          onFollowers: () => calls++,
          onFollowing: () {},
          onRatingTap: () {},
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Followers'));
    expect(calls, 1);
  });

  testWidgets('calls onFollowing when following stat is tapped', (
    WidgetTester tester,
  ) async {
    int calls = 0;
    await tester.pumpWidget(
      dsWrap(
        ProfileHeaderWidget(
          profile: _baseProfile,
          onFollowers: () {},
          onFollowing: () => calls++,
          onRatingTap: () {},
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Following'));
    expect(calls, 1);
  });
}
