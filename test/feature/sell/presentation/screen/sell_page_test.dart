import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_brand.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_condition.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_size_value.dart';
import 'package:klozy/src/domain/sell/entity/sell_draft.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_bloc.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_event.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_state.dart';
import 'package:klozy/src/feature/sell/presentation/screen/sell_page.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_photos_widget.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_recap_widget.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_success_widget.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_transition_widget.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/ds_harness.dart';

// ---- Mocks ----------------------------------------------------------------

class _MockSellBloc extends Mock implements SellBloc {}

class _MockStackRouter extends Mock implements StackRouter {}

class _MockCatalogRepository extends Mock implements CatalogRepository {}

class _FakeRoute extends Fake implements PageRouteInfo<Object?> {}

// ---- Helpers --------------------------------------------------------------

bool _isImageError(FlutterErrorDetails d) {
  final msg = d.exception.toString();
  return msg.contains('FileSystemException') ||
      msg.contains('PathNotFoundException') ||
      msg.contains('NetworkImageLoadException') ||
      msg.contains('HTTP request failed');
}

_MockSellBloc _buildBloc(SellState state, {Stream<SellState>? stream}) {
  final bloc = _MockSellBloc();
  when(() => bloc.state).thenReturn(state);
  when(
    () => bloc.stream,
  ).thenAnswer((_) => stream ?? const Stream<SellState>.empty());
  when(() => bloc.add(any())).thenReturn(null);
  when(() => bloc.close()).thenAnswer((_) async {});
  return bloc;
}

Widget _wrapWithBloc(_MockSellBloc bloc, {StackRouter? router}) {
  const page = SellPage();
  Widget child = BlocProvider<SellBloc>.value(value: bloc, child: page);
  if (router != null) {
    return dsWrapRouted(child, router: router);
  }
  return dsWrap(child);
}

const _kRecapState = SellRecapState(
  draft: SellDraft(title: 'Shirt', price: 30, description: 'Nice'),
  rootCategories: <CatalogCategory>[],
  conditions: <CatalogCondition>[],
  imageUrls: <String>['https://cdn.klozy.com/a.jpg'],
);

void main() {
  late _MockStackRouter router;
  late _MockCatalogRepository mockCatalog;
  void Function(FlutterErrorDetails)? originalError;

  setUpAll(() {
    disableDsFonts();
    registerFallbackValue(_FakeRoute());
    registerFallbackValue(const SellStarted());
    registerFallbackValue(const SellEditPhotosRequested());
  });

  setUp(() {
    router = _MockStackRouter();
    when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);
    when(() => router.push(any())).thenAnswer((_) async => null);
    when(() => router.replace(any())).thenAnswer((_) async {});

    mockCatalog = _MockCatalogRepository();
    when(
      () => mockCatalog.getSizeConfig(any()),
    ).thenAnswer((_) async => const <CatalogSizeValue>[]);
    when(
      () => mockCatalog.searchBrands(query: any(named: 'query')),
    ).thenAnswer((_) async => const <CatalogBrand>[]);
    when(
      () => mockCatalog.getCategories(parentId: any(named: 'parentId')),
    ).thenAnswer((_) async => const <CatalogCategory>[]);
    when(
      () => mockCatalog.getRootCategories(),
    ).thenAnswer((_) async => const <CatalogCategory>[]);
    when(
      () => mockCatalog.getConditions(),
    ).thenAnswer((_) async => const <CatalogCondition>[]);
    when(
      () => mockCatalog.getSizes(),
    ).thenAnswer((_) async => const <CatalogSizeValue>[]);

    if (!locator.isRegistered<CatalogRepository>()) {
      locator.registerSingleton<CatalogRepository>(mockCatalog);
    }

    originalError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails d) {
      if (_isImageError(d)) return;
      originalError?.call(d);
    };
  });

  tearDown(() {
    FlutterError.onError = originalError;
    if (locator.isRegistered<CatalogRepository>()) {
      locator.unregister<CatalogRepository>();
    }
  });

  // ---- State routing ------------------------------------------------------

  group('SellPhotosState', () {
    testWidgets('renders SellPhotosWidget', (tester) async {
      final bloc = _buildBloc(const SellPhotosState(<String>[]));
      await tester.pumpWidget(_wrapWithBloc(bloc));
      await tester.pump();

      expect(find.byType(SellPhotosWidget), findsOneWidget);
      await bloc.close();
    });

    testWidgets('renders close button', (tester) async {
      final bloc = _buildBloc(const SellPhotosState(<String>[]));
      await tester.pumpWidget(_wrapWithBloc(bloc, router: router));
      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);
      await bloc.close();
    });

    testWidgets('close button calls router.maybePop', (tester) async {
      final bloc = _buildBloc(const SellPhotosState(<String>[]));
      await tester.pumpWidget(_wrapWithBloc(bloc, router: router));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      verify(() => router.maybePop<Object?>()).called(1);
      await bloc.close();
    });
  });

  group('SellAnalyzingState', () {
    testWidgets('renders SellTransitionWidget', (tester) async {
      final bloc = _buildBloc(const SellAnalyzingState());
      await tester.pumpWidget(_wrapWithBloc(bloc));
      await tester.pump();

      expect(find.byType(SellTransitionWidget), findsOneWidget);
      await bloc.close();
    });

    testWidgets('passes coverPath to SellTransitionWidget', (tester) async {
      final bloc = _buildBloc(
        const SellAnalyzingState(coverPath: '/tmp/cover.jpg'),
      );
      await tester.pumpWidget(_wrapWithBloc(bloc));
      await tester.pump();

      final widget = tester.widget<SellTransitionWidget>(
        find.byType(SellTransitionWidget),
      );
      expect(widget.coverPath, '/tmp/cover.jpg');
      await bloc.close();
    });

    testWidgets('passes null coverPath when not provided', (tester) async {
      final bloc = _buildBloc(const SellAnalyzingState());
      await tester.pumpWidget(_wrapWithBloc(bloc));
      await tester.pump();

      final widget = tester.widget<SellTransitionWidget>(
        find.byType(SellTransitionWidget),
      );
      expect(widget.coverPath, isNull);
      await bloc.close();
    });
  });

  group('SellRecapState', () {
    testWidgets('renders SellRecapWidget', (tester) async {
      final bloc = _buildBloc(_kRecapState);
      await tester.pumpWidget(_wrapWithBloc(bloc));
      await tester.pump();

      expect(find.byType(SellRecapWidget), findsOneWidget);
      await bloc.close();
    });

    testWidgets('renders close button', (tester) async {
      final bloc = _buildBloc(_kRecapState);
      await tester.pumpWidget(_wrapWithBloc(bloc, router: router));
      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);
      await bloc.close();
    });
  });

  group('SellDoneState', () {
    testWidgets('renders SellSuccessWidget', (tester) async {
      final bloc = _buildBloc(const SellDoneState('prod-1'));
      await tester.pumpWidget(_wrapWithBloc(bloc, router: router));
      await tester.pump();

      expect(find.byType(SellSuccessWidget), findsOneWidget);
      await bloc.close();
    });

    testWidgets('passes productId to SellSuccessWidget', (tester) async {
      final bloc = _buildBloc(const SellDoneState('prod-xyz'));
      await tester.pumpWidget(_wrapWithBloc(bloc, router: router));
      await tester.pump();

      final widget = tester.widget<SellSuccessWidget>(
        find.byType(SellSuccessWidget),
      );
      expect(widget.productId, 'prod-xyz');
      await bloc.close();
    });
  });

  group('SellErrorState', () {
    testWidgets('renders AppErrorWidget', (tester) async {
      final bloc = _buildBloc(const SellErrorState(type: AppErrorType.unknown));
      await tester.pumpWidget(_wrapWithBloc(bloc));
      await tester.pump();

      expect(find.byType(AppErrorWidget), findsOneWidget);
      await bloc.close();
    });

    testWidgets('retry button dispatches SellStarted', (tester) async {
      final bloc = _buildBloc(const SellErrorState(type: AppErrorType.unknown));
      await tester.pumpWidget(_wrapWithBloc(bloc));
      await tester.pump();

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      verify(() => bloc.add(const SellStarted())).called(1);
      await bloc.close();
    });

    testWidgets('renders close button on error state', (tester) async {
      final bloc = _buildBloc(const SellErrorState(type: AppErrorType.unknown));
      await tester.pumpWidget(_wrapWithBloc(bloc, router: router));
      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);
      await bloc.close();
    });
  });

  // ---- BlocListener -------------------------------------------------------

  group('Listener — submitError snackbar', () {
    testWidgets('shows SnackBar when submitError is emitted', (tester) async {
      final streamCtrl = StreamController<SellState>.broadcast();
      final bloc = _buildBloc(_kRecapState, stream: streamCtrl.stream);
      await tester.pumpWidget(_wrapWithBloc(bloc, router: router));
      await tester.pump();

      streamCtrl.add(
        _kRecapState.copyWith(
          submitError: "Couldn't publish your listing. Please try again.",
        ),
      );
      // First pump delivers the stream event (listener fires + enqueues the
      // SnackBar); second builds the SnackBar into the tree.
      await tester.pump();
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);

      streamCtrl.close();
      await bloc.close();
    });

    testWidgets('does NOT show snackbar for state without submitError', (
      tester,
    ) async {
      final streamCtrl = StreamController<SellState>.broadcast();
      final bloc = _buildBloc(_kRecapState, stream: streamCtrl.stream);
      await tester.pumpWidget(_wrapWithBloc(bloc, router: router));
      await tester.pump();

      // Emit state without submitError — should not trigger SnackBar.
      streamCtrl.add(_kRecapState.copyWith());
      await tester.pump();

      expect(find.byType(SnackBar), findsNothing);

      streamCtrl.close();
      await bloc.close();
    });
  });

  // ---- wrappedRoute -------------------------------------------------------

  group('wrappedRoute', () {
    tearDown(() {
      if (locator.isRegistered<SellBloc>()) {
        locator.unregister<SellBloc>();
      }
    });

    testWidgets('wrappedRoute creates BlocProvider from locator', (
      tester,
    ) async {
      final bloc = _buildBloc(const SellPhotosState(<String>[]));
      locator.registerSingleton<SellBloc>(bloc);

      const page = SellPage();
      await tester.pumpWidget(
        dsWrapRouted(
          Builder(builder: (ctx) => page.wrappedRoute(ctx)),
          router: router,
        ),
      );
      await tester.pump();

      expect(find.byType(SellPhotosWidget), findsOneWidget);
      await bloc.close();
    });
  });
}
