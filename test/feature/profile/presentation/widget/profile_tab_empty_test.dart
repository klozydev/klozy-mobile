import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_tab_empty.dart';

import '../../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  testWidgets('renders the provided icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      dsWrap(
        const ProfileTabEmpty(
          icon: Icons.movie_outlined,
          label: 'No reels yet',
        ),
      ),
    );
    await tester.pump();
    expect(find.byIcon(Icons.movie_outlined), findsOneWidget);
  });

  testWidgets('renders the provided label', (WidgetTester tester) async {
    await tester.pumpWidget(
      dsWrap(
        const ProfileTabEmpty(
          icon: Icons.star_outline_rounded,
          label: 'No reviews yet',
        ),
      ),
    );
    await tester.pump();
    expect(find.text('No reviews yet'), findsOneWidget);
  });
}
