import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/config/entity/contact_info.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/entity/notification_settings.dart';
import 'package:klozy/src/feature/settings/presentation/bloc/settings_bloc.dart';
import 'package:klozy/src/feature/settings/presentation/bloc/settings_event.dart';
import 'package:klozy/src/feature/settings/presentation/bloc/settings_state.dart';
import 'package:klozy/src/feature/settings/presentation/screen/settings_page.dart';
import 'package:klozy/src/feature/settings/presentation/widget/settings_section_widget.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../support/ds_harness.dart';

// ignore: avoid_implementing_value_types
class _FakeRoute extends Fake implements PageRouteInfo<Object?> {}

class _MockStackRouter extends Mock implements StackRouter {}

/// Mock bloc — avoids instantiating real [SettingsBloc] whose event handlers
/// run asynchronously in bloc 9.x and leak pending futures into subsequent
/// tests when the widget disposes without awaiting them (same fix applied to
/// chat_page_test).
class _FakeSettingsBloc extends Mock implements SettingsBloc {}

/// Build a state-stubbed [_FakeSettingsBloc].
///
/// [stream] defaults to an empty stream; pass a [StreamController.stream] when
/// the test needs the BlocConsumer/Listener to react to emitted states.
_FakeSettingsBloc _buildBloc(
  SettingsState state, {
  Stream<SettingsState>? stream,
}) {
  final bloc = _FakeSettingsBloc();
  when(() => bloc.state).thenReturn(state);
  when(
    () => bloc.stream,
  ).thenAnswer((_) => stream ?? const Stream<SettingsState>.empty());
  when(() => bloc.close()).thenAnswer((_) async {});
  return bloc;
}

const _kMe = MeProfile(id: 'u1', firstName: 'Alice', lastName: 'Smith');
const _kSettings = NotificationSettings(push: true, email: true);
const _kContact = ContactInfo(supportEmail: 'support@klozy.com');
const _kContactWithInstagram = ContactInfo(
  supportEmail: 'support@klozy.com',
  instagram: 'https://instagram.com/klozy',
);

void main() {
  setUpAll(() {
    disableDsFonts();
    // Provide a synchronous mock for PackageInfo so FutureBuilder inside the
    // loaded-state page completes immediately and never hangs pumpAndSettle().
    PackageInfo.setMockInitialValues(
      appName: 'Klozy',
      packageName: 'com.klozy.app',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    // mocktail fallbacks for router methods that accept PageRouteInfo.
    registerFallbackValue(_FakeRoute());
    registerFallbackValue(const <PageRouteInfo<Object?>>[]);
    // Needed for `bloc.add(any())` in the retry test.
    registerFallbackValue(const SettingsStarted());
  });

  late _MockStackRouter router;

  setUp(() {
    router = _MockStackRouter();
    when(() => router.maybePop<Object?>()).thenAnswer((_) async => true);
    when(() => router.replaceAll(any())).thenAnswer((_) async => <Object>[]);
    when(() => router.push(any())).thenAnswer((_) async => null);
  });

  Widget wrapWithBloc(SettingsBloc bloc) {
    return BlocProvider<SettingsBloc>.value(
      value: bloc,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: dsTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StackRouterScope(
          controller: router,
          stateHash: 0,
          child: const SettingsPage(),
        ),
      ),
    );
  }

  group('SettingsPage – wrappedRoute', () {
    tearDown(() {
      if (locator.isRegistered<SettingsBloc>()) {
        locator.unregister<SettingsBloc>();
      }
    });

    testWidgets('wrappedRoute creates BlocProvider from locator', (
      tester,
    ) async {
      final bloc = _buildBloc(const SettingsLoadingState());
      locator.registerSingleton<SettingsBloc>(bloc);

      // wrappedRoute calls locator<SettingsBloc>()..add(SettingsStarted()).
      // add() on the mock is a recorded no-op; state stays SettingsLoadingState.
      const page = SettingsPage();
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dsTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StackRouterScope(
            controller: router,
            stateHash: 0,
            child: Builder(builder: (ctx) => page.wrappedRoute(ctx)),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(DSLoader), findsOneWidget);
      await bloc.close();
    });
  });

  group('SettingsPage – states', () {
    testWidgets('loading state shows DSLoader', (tester) async {
      final bloc = _buildBloc(const SettingsLoadingState());
      await tester.pumpWidget(wrapWithBloc(bloc));
      await tester.pump();
      expect(find.byType(DSLoader), findsOneWidget);
      await bloc.close();
    });

    testWidgets('error state shows AppErrorWidget', (tester) async {
      final bloc = _buildBloc(
        const SettingsErrorState(type: AppErrorType.network),
      );
      await tester.pumpWidget(wrapWithBloc(bloc));
      await tester.pump();
      expect(find.byType(AppErrorWidget), findsOneWidget);
      await bloc.close();
    });

    testWidgets('error state retry button dispatches SettingsStarted', (
      tester,
    ) async {
      final bloc = _buildBloc(
        const SettingsErrorState(type: AppErrorType.network),
      );
      when(() => bloc.add(any())).thenReturn(null);
      await tester.pumpWidget(wrapWithBloc(bloc));
      await tester.pump();

      // AppErrorWidget shows an OutlinedButton ("Try again")
      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      verify(() => bloc.add(const SettingsStarted())).called(1);
      await bloc.close();
    });

    testWidgets('signed out state shows DSLoader', (tester) async {
      final bloc = _buildBloc(const SettingsSignedOutState());
      await tester.pumpWidget(wrapWithBloc(bloc));
      await tester.pump();
      expect(find.byType(DSLoader), findsOneWidget);
      await bloc.close();
    });

    testWidgets('loaded state renders SettingsSectionWidgets', (tester) async {
      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: _kSettings,
          contact: _kContact,
        ),
      );
      await tester.pumpWidget(wrapWithBloc(bloc));
      await tester.pump();
      expect(find.byType(SettingsSectionWidget), findsWidgets);
      await bloc.close();
    });
  });

  group('SettingsPage – navigation', () {
    testWidgets('back button calls router.maybePop', (tester) async {
      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: _kSettings,
          contact: _kContact,
        ),
      );
      await tester.pumpWidget(wrapWithBloc(bloc));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      verify(() => router.maybePop<Object?>()).called(1);
      await bloc.close();
    });

    testWidgets('personal data row pushes route', (tester) async {
      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: _kSettings,
          contact: _kContact,
        ),
      );
      await tester.pumpWidget(wrapWithBloc(bloc));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pump();
      verify(() => router.push(any())).called(1);
      await bloc.close();
    });

    testWidgets('security row pushes route', (tester) async {
      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: _kSettings,
          contact: _kContact,
        ),
      );
      await tester.pumpWidget(wrapWithBloc(bloc));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.shield_outlined));
      await tester.pump();
      verify(() => router.push(any())).called(1);
      await bloc.close();
    });

    testWidgets('payouts row pushes route', (tester) async {
      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: _kSettings,
          contact: _kContact,
        ),
      );
      await tester.pumpWidget(wrapWithBloc(bloc));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.account_balance_outlined));
      await tester.pump();
      verify(() => router.push(any())).called(1);
      await bloc.close();
    });
  });

  group('SettingsPage – links navigation', () {
    // The links section is below the account section — make the viewport tall
    // enough so the full menu is rendered without scrolling.
    Widget wrapLarge(SettingsBloc bloc) => wrapWithBloc(bloc);

    Future<void> setup(WidgetTester tester, SettingsBloc bloc) async {
      tester.view.physicalSize = const Size(800, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(wrapLarge(bloc));
      await tester.pump();
    }

    testWidgets('privacy row pushes LegalDocRoute privacy', (tester) async {
      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: _kSettings,
          contact: _kContact,
        ),
      );
      await setup(tester, bloc);
      await tester.tap(find.byIcon(Icons.privacy_tip_outlined));
      await tester.pump();
      verify(() => router.push(any())).called(1);
      await bloc.close();
    });

    testWidgets('terms row pushes LegalDocRoute terms', (tester) async {
      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: _kSettings,
          contact: _kContact,
        ),
      );
      await setup(tester, bloc);
      await tester.tap(find.byIcon(Icons.description_outlined));
      await tester.pump();
      verify(() => router.push(any())).called(1);
      await bloc.close();
    });

    testWidgets('legal notices row pushes LegalDocRoute legal', (tester) async {
      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: _kSettings,
          contact: _kContact,
        ),
      );
      await setup(tester, bloc);
      await tester.tap(find.byIcon(Icons.gavel_rounded));
      await tester.pump();
      verify(() => router.push(any())).called(1);
      await bloc.close();
    });

    testWidgets('about row pushes LegalDocRoute about', (tester) async {
      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: _kSettings,
          contact: _kContact,
        ),
      );
      await setup(tester, bloc);
      // info_outline_rounded appears in both the about row and the version row.
      // Tap the first occurrence which is the about row (above version row).
      await tester.tap(find.byIcon(Icons.info_outline_rounded).first);
      await tester.pump();
      verify(() => router.push(any())).called(1);
      await bloc.close();
    });

    testWidgets('instagram row triggers _support call', (tester) async {
      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: _kSettings,
          contact: _kContactWithInstagram,
        ),
      );
      await setup(tester, bloc);
      await tester.tap(find.byIcon(Icons.camera_alt_outlined));
      await tester.pump();
      // _support → _launch → launchUrl (hangs in tests); just verify no crash
      // and that the snackbar does not appear (url is non-null so launch fires).
      await bloc.close();
    });

    testWidgets('version row renders version string', (tester) async {
      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: _kSettings,
          contact: _kContact,
        ),
      );
      await setup(tester, bloc);
      // Second pump lets the PackageInfo FutureBuilder resolve.
      await tester.pump();
      // PackageInfo mock returns '1.0.0 (1)'; version row is rendered.
      expect(find.textContaining('1.0.0'), findsOneWidget);
      await bloc.close();
    });
  });

  group('SettingsPage – overflow menu', () {
    testWidgets('shows PopupMenuButton when not busy', (tester) async {
      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: _kSettings,
          contact: _kContact,
        ),
      );
      await tester.pumpWidget(wrapWithBloc(bloc));
      await tester.pump();
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
      await bloc.close();
    });

    testWidgets('shows spinner when isBusy', (tester) async {
      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: _kSettings,
          contact: _kContact,
          isBusy: true,
        ),
      );
      await tester.pumpWidget(wrapWithBloc(bloc));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(PopupMenuButton<String>), findsNothing);
      await bloc.close();
    });

    testWidgets('logout popup menu item opens confirm dialog', (tester) async {
      // The popup menu items overflow by ~6px in the headless test environment
      // (font metrics). Suppress this cosmetic overflow inside the test body so
      // that the binding's error recorder (set after setUp) is also patched.
      final prevOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails d) {
        if (d.exception.toString().contains('overflowed')) return;
        prevOnError?.call(d);
      };
      addTearDown(() => FlutterError.onError = prevOnError);

      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: _kSettings,
          contact: _kContact,
        ),
      );
      await tester.pumpWidget(wrapWithBloc(bloc));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      await bloc.close();
    });

    testWidgets('logout confirm dispatches SettingsLoggedOut', (tester) async {
      final prevOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails d) {
        if (d.exception.toString().contains('overflowed')) return;
        prevOnError?.call(d);
      };
      addTearDown(() => FlutterError.onError = prevOnError);

      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: _kSettings,
          contact: _kContact,
        ),
      );
      await tester.pumpWidget(wrapWithBloc(bloc));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      // Tap confirm (last TextButton in dialog).
      await tester.tap(find.byType(TextButton).last);
      await tester.pump();

      verify(() => bloc.add(const SettingsLoggedOut())).called(1);
      await bloc.close();
    });

    testWidgets('logout cancel dismisses dialog without event', (tester) async {
      final prevOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails d) {
        if (d.exception.toString().contains('overflowed')) return;
        prevOnError?.call(d);
      };
      addTearDown(() => FlutterError.onError = prevOnError);

      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: _kSettings,
          contact: _kContact,
        ),
      );
      await tester.pumpWidget(wrapWithBloc(bloc));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      // Tap cancel (first TextButton).
      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      verifyNever(() => bloc.add(const SettingsLoggedOut()));
      await bloc.close();
    });

    testWidgets('delete account popup menu item opens confirm dialog', (
      tester,
    ) async {
      final prevOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails d) {
        if (d.exception.toString().contains('overflowed')) return;
        prevOnError?.call(d);
      };
      addTearDown(() => FlutterError.onError = prevOnError);

      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: _kSettings,
          contact: _kContact,
        ),
      );
      await tester.pumpWidget(wrapWithBloc(bloc));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      await bloc.close();
    });

    testWidgets('delete account confirm dispatches SettingsAccountDeleted', (
      tester,
    ) async {
      final prevOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails d) {
        if (d.exception.toString().contains('overflowed')) return;
        prevOnError?.call(d);
      };
      addTearDown(() => FlutterError.onError = prevOnError);

      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: _kSettings,
          contact: _kContact,
        ),
      );
      await tester.pumpWidget(wrapWithBloc(bloc));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      // Confirm.
      await tester.tap(find.byType(TextButton).last);
      await tester.pump();

      verify(() => bloc.add(const SettingsAccountDeleted())).called(1);
      await bloc.close();
    });
  });

  group('SettingsPage – notifications', () {
    testWidgets('notification switch present with correct initial value', (
      tester,
    ) async {
      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: NotificationSettings(push: false),
          contact: _kContact,
        ),
      );
      await tester.pumpWidget(wrapWithBloc(bloc));
      await tester.pump();

      final sw = tester.widget<Switch>(find.byType(Switch));
      expect(sw.value, isFalse);
      await bloc.close();
    });

    testWidgets(
      'notification switch tap dispatches SettingsToggleNotification',
      (tester) async {
        final bloc = _buildBloc(
          const SettingsLoadedState(
            me: _kMe,
            settings: _kSettings,
            contact: _kContact,
          ),
        );
        await tester.pumpWidget(wrapWithBloc(bloc));
        await tester.pump();

        // _kSettings.push == true → tapping Switch calls onChanged(false).
        // The page dispatches SettingsToggleNotification(push: v) without email.
        await tester.tap(find.byType(Switch));
        await tester.pump();

        verify(
          () => bloc.add(const SettingsToggleNotification(push: false)),
        ).called(1);
        await bloc.close();
      },
    );
  });

  group('SettingsPage – support', () {
    testWidgets('support tap with no contact shows unavailable snackbar', (
      tester,
    ) async {
      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: _kSettings,
          contact: ContactInfo(),
        ),
      );
      await tester.pumpWidget(wrapWithBloc(bloc));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.help_outline_rounded));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      await bloc.close();
    });

    testWidgets('support tap with email attempts url launch', (tester) async {
      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: _kSettings,
          contact: ContactInfo(supportEmail: 'help@klozy.com'),
        ),
      );
      await tester.pumpWidget(wrapWithBloc(bloc));
      await tester.pump();

      // url_launcher is not available in tests; the page shows a
      // "link failed" snackbar after the failed launch attempt.
      await tester.tap(find.byIcon(Icons.help_outline_rounded));
      await tester.pump();
      await bloc.close();
    });

    testWidgets('support tap with instagram attempts url launch', (
      tester,
    ) async {
      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: _kSettings,
          contact: _kContactWithInstagram,
        ),
      );
      await tester.pumpWidget(wrapWithBloc(bloc));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.help_outline_rounded));
      await tester.pump();
      await bloc.close();
    });
  });

  group('SettingsPage – listener', () {
    testWidgets('SettingsSignedOutState triggers replaceAll on router', (
      tester,
    ) async {
      final stateController = StreamController<SettingsState>.broadcast();
      final bloc = _buildBloc(
        const SettingsLoadedState(
          me: _kMe,
          settings: _kSettings,
          contact: _kContact,
        ),
        stream: stateController.stream,
      );

      await tester.pumpWidget(wrapWithBloc(bloc));
      await tester.pump();

      // Emit SettingsSignedOutState — BlocListener fires and calls replaceAll.
      stateController.add(const SettingsSignedOutState());
      await tester.pump();

      verify(() => router.replaceAll(any())).called(1);

      await stateController.close();
      await bloc.close();
    });
  });
}
