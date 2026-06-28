import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/social/entity/profile_reel.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_reels_grid.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_tab_empty.dart';

import '../../../../support/ds_harness.dart';

// Suppress network errors from reel thumbnail loading.
bool _isNetworkError(FlutterErrorDetails d) {
  final msg = d.exception.toString();
  return msg.contains('HTTP request failed') ||
      msg.contains('NetworkImageLoadException') ||
      msg.contains('SocketException') ||
      msg.contains('Failed to load');
}

void main() {
  setUpAll(disableDsFonts);

  testWidgets('shows ProfileTabEmpty when reels list is empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      dsWrap(
        ProfileReelsGrid(reels: const [], onTap: (_) {}),
        wrapInScaffold: true,
      ),
    );
    await tester.pump();
    expect(find.byType(ProfileTabEmpty), findsOneWidget);
    expect(find.text('No reels yet'), findsOneWidget);
  });

  testWidgets('shows GridView items when reels are populated', (
    WidgetTester tester,
  ) async {
    final prev = FlutterError.onError;
    FlutterError.onError = (d) {
      if (_isNetworkError(d)) return;
      prev?.call(d);
    };
    addTearDown(() => FlutterError.onError = prev);

    const reels = <ProfileReel>[
      ProfileReel(
        id: 'r1',
        thumbnailUrl: 'https://example.com/r1.jpg',
        views: 100,
      ),
      ProfileReel(id: 'r2', views: 50),
    ];

    await tester.pumpWidget(
      dsWrap(
        ProfileReelsGrid(reels: reels, onTap: (_) {}),
        wrapInScaffold: true,
      ),
    );
    await tester.pump();

    expect(find.byType(ProfileTabEmpty), findsNothing);
    expect(find.byType(GridView), findsOneWidget);
    // view counts shown
    expect(find.text('100'), findsOneWidget);
    expect(find.text('50'), findsOneWidget);
  });

  testWidgets('reel with null thumbnailUrl renders neutral tile', (
    WidgetTester tester,
  ) async {
    const reels = <ProfileReel>[ProfileReel(id: 'r1', views: 0)];

    await tester.pumpWidget(
      dsWrap(
        ProfileReelsGrid(reels: reels, onTap: (_) {}),
        wrapInScaffold: true,
      ),
    );
    await tester.pump();
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('calls onTap with the tapped reel', (WidgetTester tester) async {
    final prev = FlutterError.onError;
    FlutterError.onError = (d) {
      if (_isNetworkError(d)) return;
      prev?.call(d);
    };
    addTearDown(() => FlutterError.onError = prev);

    ProfileReel? tappedReel;
    const reels = <ProfileReel>[ProfileReel(id: 'r1', views: 10)];

    await tester.pumpWidget(
      dsWrap(
        ProfileReelsGrid(reels: reels, onTap: (r) => tappedReel = r),
        wrapInScaffold: true,
      ),
    );
    await tester.pump();
    await tester.tap(find.text('10'));
    expect(tappedReel?.id, 'r1');
  });
}
