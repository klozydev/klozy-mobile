import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/app/bloc/account/account_bloc.dart';
import 'package:klozy/src/app/bloc/account/account_event.dart';
import 'package:klozy/src/app/bloc/account/account_state.dart';
import 'package:klozy/src/core/account/incomplete_profile_placeholder_widget.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/domain/account/entity/account_status.dart';
import 'package:klozy/src/feature/chat/presentation/screen/chat_page.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockStackRouter extends Mock implements StackRouter {}

class _FakeAccountBloc extends Mock implements AccountBloc {}

/// Builds a state-stubbed [AccountBloc] mock. Faking the bloc (rather than
/// subclassing the real one) avoids the real constructor's EventBus
/// subscription, which otherwise keeps the test isolate alive and hangs.
_FakeAccountBloc _buildFakeAccountBloc(AccountState state) {
  final _FakeAccountBloc bloc = _FakeAccountBloc();
  when(() => bloc.state).thenReturn(state);
  when(() => bloc.stream).thenAnswer((_) => const Stream<AccountState>.empty());
  when(() => bloc.close()).thenAnswer((_) async {});
  return bloc;
}

Widget _wrap(AccountBloc bloc, StackRouter router) {
  return BlocProvider<AccountBloc>.value(
    value: bloc,
    child: MaterialApp(
      theme: dsTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StackRouterScope(
        controller: router,
        stateHash: 0,
        child: const ChatPage(),
      ),
    ),
  );
}

void main() {
  late _MockStackRouter router;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(const AccountBootstrapRequested());
    registerFallbackValue(const WelcomeRoute());
  });

  setUp(() {
    router = _MockStackRouter();
    when(() => router.stateHash).thenReturn(0);
    when(
      () => router.push<Object?>(any(), onFailure: any(named: 'onFailure')),
    ).thenAnswer((_) async => null);
  });

  testWidgets('AccountInitial shows DSLoader', (WidgetTester tester) async {
    final _FakeAccountBloc bloc = _buildFakeAccountBloc(const AccountInitial());
    await tester.pumpWidget(_wrap(bloc, router));
    await tester.pump();

    expect(find.byType(DSLoader), findsOneWidget);
    expect(find.byType(IncompleteProfilePlaceholderWidget), findsNothing);
    await bloc.close();
  });

  testWidgets('AccountResolving shows DSLoader', (WidgetTester tester) async {
    final _FakeAccountBloc bloc = _buildFakeAccountBloc(
      const AccountResolving(),
    );
    await tester.pumpWidget(_wrap(bloc, router));
    await tester.pump();

    expect(find.byType(DSLoader), findsOneWidget);
    await bloc.close();
  });

  testWidgets(
    'AccountResolved incompleteOnboarding shows IncompleteProfilePlaceholderWidget',
    (WidgetTester tester) async {
      final _FakeAccountBloc bloc = _buildFakeAccountBloc(
        const AccountResolved(AccountStatus.incompleteOnboarding),
      );
      await tester.pumpWidget(_wrap(bloc, router));
      await tester.pump();

      expect(find.byType(IncompleteProfilePlaceholderWidget), findsOneWidget);
      expect(find.byType(DSLoader), findsNothing);
      await bloc.close();
    },
  );
}
