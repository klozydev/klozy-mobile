import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_details_panel_widget.dart';
import 'package:klozy/src/feature/product/presentation/widget/product_owner_stats_widget.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockStackRouter extends Mock implements StackRouter {}

Widget _wrap(Widget child, {required StackRouter router}) {
  return MaterialApp(
    theme: dsTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: StackRouterScope(controller: router, stateHash: 0, child: child),
    ),
  );
}

const _kSeller = ProductSeller(id: 's1', displayName: 'Jane Doe');

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(UserProfileRoute(userId: ''));
  });

  group('ProductDetailsPanelWidget', () {
    late _MockStackRouter router;

    setUp(() {
      router = _MockStackRouter();
      when(
        () => router.push<Object?>(any(), onFailure: any(named: 'onFailure')),
      ).thenAnswer((_) async => null);
    });

    testWidgets('shows seller display name', (WidgetTester tester) async {
      const detail = ProductDetail(
        id: 'p1',
        title: 'Coat',
        price: 180,
        seller: _kSeller,
      );
      await tester.pumpWidget(
        _wrap(
          ProductDetailsPanelWidget(
            detail: detail,
            isOwner: false,
            onReport: () {},
          ),
          router: router,
        ),
      );
      await tester.pump();

      expect(find.text('Jane Doe'), findsOneWidget);
    });

    testWidgets('shows description when not empty', (
      WidgetTester tester,
    ) async {
      const detail = ProductDetail(
        id: 'p1',
        title: 'Coat',
        price: 180,
        seller: _kSeller,
        description: 'Great condition, barely worn.',
      );
      await tester.pumpWidget(
        _wrap(
          ProductDetailsPanelWidget(
            detail: detail,
            isOwner: false,
            onReport: () {},
          ),
          router: router,
        ),
      );
      await tester.pump();

      expect(find.text('Great condition, barely worn.'), findsOneWidget);
    });

    testWidgets('shows Report this listing for non-owner', (
      WidgetTester tester,
    ) async {
      const detail = ProductDetail(
        id: 'p1',
        title: 'Coat',
        price: 180,
        seller: _kSeller,
      );
      await tester.pumpWidget(
        _wrap(
          ProductDetailsPanelWidget(
            detail: detail,
            isOwner: false,
            onReport: () {},
          ),
          router: router,
        ),
      );
      await tester.pump();

      expect(find.text('Report this listing'), findsOneWidget);
    });

    testWidgets('hides Report this listing for owner', (
      WidgetTester tester,
    ) async {
      const detail = ProductDetail(
        id: 'p1',
        title: 'Coat',
        price: 180,
        seller: _kSeller,
      );
      await tester.pumpWidget(
        _wrap(
          ProductDetailsPanelWidget(
            detail: detail,
            isOwner: true,
            onReport: () {},
          ),
          router: router,
        ),
      );
      await tester.pump();

      expect(find.text('Report this listing'), findsNothing);
    });

    testWidgets('shows ProductOwnerStatsWidget for owner', (
      WidgetTester tester,
    ) async {
      const detail = ProductDetail(
        id: 'p1',
        title: 'Coat',
        price: 180,
        seller: _kSeller,
        views: 10,
        likes: 3,
      );
      await tester.pumpWidget(
        _wrap(
          ProductDetailsPanelWidget(
            detail: detail,
            isOwner: true,
            onReport: () {},
          ),
          router: router,
        ),
      );
      await tester.pump();

      expect(find.byType(ProductOwnerStatsWidget), findsOneWidget);
    });

    testWidgets('hides ProductOwnerStatsWidget for non-owner', (
      WidgetTester tester,
    ) async {
      const detail = ProductDetail(
        id: 'p1',
        title: 'Coat',
        price: 180,
        seller: _kSeller,
      );
      await tester.pumpWidget(
        _wrap(
          ProductDetailsPanelWidget(
            detail: detail,
            isOwner: false,
            onReport: () {},
          ),
          router: router,
        ),
      );
      await tester.pump();

      expect(find.byType(ProductOwnerStatsWidget), findsNothing);
    });
  });
}
