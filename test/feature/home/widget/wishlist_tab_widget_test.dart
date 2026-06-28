import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/core/account/account_gate.dart';
import 'package:klozy/src/core/pagination/paginated_list.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/domain/wishlist/wishlist_repository.dart';
import 'package:klozy/src/feature/home/presentation/widget/wishlist_tab_widget.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/ds_harness.dart';

class _MockWishlistRepository extends Mock implements WishlistRepository {}

class _MockAccountGate extends Mock implements AccountGate {}

Widget _buildTab({
  required WishlistRepository wishlistRepository,
  required EventBus eventBus,
  required WishlistCubit wishlistCubit,
  bool active = true,
}) {
  return dsWrap(
    BlocProvider<WishlistCubit>.value(
      value: wishlistCubit,
      child: WishlistTabWidget(active: active),
    ),
  );
}

void main() {
  setUpAll(() {
    disableDsFonts();
  });

  late _MockWishlistRepository mockWishlistRepo;
  late _MockAccountGate mockAccountGate;
  late EventBus eventBus;

  setUp(() {
    mockWishlistRepo = _MockWishlistRepository();
    mockAccountGate = _MockAccountGate();
    eventBus = EventBus();

    if (locator.isRegistered<WishlistRepository>()) {
      locator.unregister<WishlistRepository>();
    }
    locator.registerSingleton<WishlistRepository>(mockWishlistRepo);

    if (locator.isRegistered<EventBus>()) {
      locator.unregister<EventBus>();
    }
    locator.registerSingleton<EventBus>(eventBus);

    if (locator.isRegistered<AccountGate>()) {
      locator.unregister<AccountGate>();
    }
    locator.registerSingleton<AccountGate>(mockAccountGate);
  });

  tearDown(() {
    if (locator.isRegistered<WishlistRepository>()) {
      locator.unregister<WishlistRepository>();
    }
    if (locator.isRegistered<EventBus>()) {
      locator.unregister<EventBus>();
    }
    if (locator.isRegistered<AccountGate>()) {
      locator.unregister<AccountGate>();
    }
  });

  group('WishlistTabWidget', () {
    testWidgets('shows loader while future is pending', (
      WidgetTester tester,
    ) async {
      // A Completer's future never resolves and never creates a timer —
      // the widget stays in loading state without leaving pending timers.
      final completer = Completer<PaginatedList<Product>>();
      when(
        () => mockWishlistRepo.getWishlistProducts(),
      ).thenAnswer((_) => completer.future);
      when(
        () => mockWishlistRepo.getWishlistProductIds(),
      ).thenAnswer((_) async => <String>{});

      final wishlistCubit = WishlistCubit(mockWishlistRepo, eventBus);

      await tester.pumpWidget(
        _buildTab(
          wishlistRepository: mockWishlistRepo,
          eventBus: eventBus,
          wishlistCubit: wishlistCubit,
        ),
      );
      // One frame — FutureBuilder hasn't resolved yet.
      await tester.pump();

      expect(find.byType(DSLoader), findsOneWidget);

      wishlistCubit.close();
    });

    testWidgets('shows empty state when wishlist has no items', (
      WidgetTester tester,
    ) async {
      when(
        () => mockWishlistRepo.getWishlistProducts(),
      ).thenAnswer((_) async => const PaginatedList<Product>(data: []));
      when(
        () => mockWishlistRepo.getWishlistProductIds(),
      ).thenAnswer((_) async => <String>{});

      final wishlistCubit = WishlistCubit(mockWishlistRepo, eventBus);

      await tester.pumpWidget(
        _buildTab(
          wishlistRepository: mockWishlistRepo,
          eventBus: eventBus,
          wishlistCubit: wishlistCubit,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your wishlist is empty'), findsOneWidget);

      wishlistCubit.close();
    });

    testWidgets('shows hint text when wishlist is empty', (
      WidgetTester tester,
    ) async {
      when(
        () => mockWishlistRepo.getWishlistProducts(),
      ).thenAnswer((_) async => const PaginatedList<Product>(data: []));
      when(
        () => mockWishlistRepo.getWishlistProductIds(),
      ).thenAnswer((_) async => <String>{});

      final wishlistCubit = WishlistCubit(mockWishlistRepo, eventBus);

      await tester.pumpWidget(
        _buildTab(
          wishlistRepository: mockWishlistRepo,
          eventBus: eventBus,
          wishlistCubit: wishlistCubit,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Tap the heart on any item to save it here.'),
        findsOneWidget,
      );

      wishlistCubit.close();
    });

    testWidgets('shows product cards for wishlisted items', (
      WidgetTester tester,
    ) async {
      const products = [
        Product(id: 'p1', title: 'Sneakers', price: 100),
        Product(id: 'p2', title: 'Jacket', price: 200),
      ];

      when(
        () => mockWishlistRepo.getWishlistProducts(),
      ).thenAnswer((_) async => const PaginatedList<Product>(data: products));
      when(
        () => mockWishlistRepo.getWishlistProductIds(),
      ).thenAnswer((_) async => {'p1', 'p2'});

      // WishlistCubit holds the wished ids — products are filtered against this.
      final wishlistCubit = WishlistCubit(mockWishlistRepo, eventBus)
        ..emit({'p1', 'p2'});

      await tester.pumpWidget(
        _buildTab(
          wishlistRepository: mockWishlistRepo,
          eventBus: eventBus,
          wishlistCubit: wishlistCubit,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sneakers'), findsOneWidget);
      expect(find.text('Jacket'), findsOneWidget);

      wishlistCubit.close();
    });

    testWidgets('shows saved count when items exist', (
      WidgetTester tester,
    ) async {
      const products = [Product(id: 'p1', title: 'Sneakers', price: 100)];

      when(
        () => mockWishlistRepo.getWishlistProducts(),
      ).thenAnswer((_) async => const PaginatedList<Product>(data: products));
      when(
        () => mockWishlistRepo.getWishlistProductIds(),
      ).thenAnswer((_) async => {'p1'});

      final wishlistCubit = WishlistCubit(mockWishlistRepo, eventBus)
        ..emit({'p1'});

      await tester.pumpWidget(
        _buildTab(
          wishlistRepository: mockWishlistRepo,
          eventBus: eventBus,
          wishlistCubit: wishlistCubit,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 saved item'), findsOneWidget);

      wishlistCubit.close();
    });
  });
}
