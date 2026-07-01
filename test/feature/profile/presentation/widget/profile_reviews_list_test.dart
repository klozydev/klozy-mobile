import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/social/entity/social_profile.dart';
import 'package:klozy/src/domain/social/entity/user_review.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_reviews_list.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_tab_empty.dart';
import 'package:klozy/src/feature/profile/presentation/widget/review_card_widget.dart';

import '../../../../support/ds_harness.dart';

void main() {
  setUpAll(disableDsFonts);

  const profileNoReviews = SocialProfile(
    id: 'u1',
    displayName: 'Alice',
    reviewCount: 0,
  );

  const profileWithReviews = SocialProfile(
    id: 'u1',
    displayName: 'Alice',
    rating: 4.5,
    reviewCount: 3,
  );

  testWidgets(
    'shows ProfileTabEmpty when reviews are empty and reviewCount=0',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        dsWrap(
          const ProfileReviewsList(profile: profileNoReviews, reviews: []),
          wrapInScaffold: true,
        ),
      );
      await tester.pump();
      expect(find.byType(ProfileTabEmpty), findsOneWidget);
      expect(find.text('No reviews yet'), findsOneWidget);
    },
  );

  testWidgets('shows review cards when reviews are non-empty', (
    WidgetTester tester,
  ) async {
    const reviews = <UserReview>[
      UserReview(id: 'r1', authorName: 'Bob', rating: 5.0, body: 'Great!'),
      UserReview(id: 'r2', authorName: 'Carol', rating: 4.0, body: ''),
    ];
    await tester.pumpWidget(
      dsWrap(
        const ProfileReviewsList(profile: profileWithReviews, reviews: reviews),
        wrapInScaffold: true,
      ),
    );
    await tester.pump();
    expect(find.byType(ProfileTabEmpty), findsNothing);
    expect(find.byType(ReviewCardWidget), findsNWidgets(2));
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Carol'), findsOneWidget);
  });

  testWidgets('shows overall rating header when reviews are present', (
    WidgetTester tester,
  ) async {
    const reviews = <UserReview>[
      UserReview(id: 'r1', authorName: 'Dave', rating: 4.5, body: ''),
    ];
    await tester.pumpWidget(
      dsWrap(
        const ProfileReviewsList(profile: profileWithReviews, reviews: reviews),
        wrapInScaffold: true,
      ),
    );
    await tester.pump();
    // Rating header shows the profile rating
    expect(find.text('4.5'), findsOneWidget);
  });

  testWidgets('shows non-empty list without empty state when reviewCount > 0', (
    WidgetTester tester,
  ) async {
    // reviews list is empty but reviewCount > 0: should NOT show ProfileTabEmpty
    const profileWithCount = SocialProfile(
      id: 'u1',
      displayName: 'Alice',
      rating: 4.0,
      reviewCount: 5,
    );
    await tester.pumpWidget(
      dsWrap(
        const ProfileReviewsList(profile: profileWithCount, reviews: []),
        wrapInScaffold: true,
      ),
    );
    await tester.pump();
    expect(find.byType(ProfileTabEmpty), findsNothing);
  });
}
