import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';

/// Shared widget-test harness for Klozy presentation-layer tests.
///
/// Call [disableDsFonts] once in `setUpAll` to stop GoogleFonts from making
/// network calls during tests. Wrap the widget under test with [dsWrap] (or
/// [dsWrapRouted] when the widget navigates via an injected [StackRouter]).
///
/// These helpers mirror the inline harness used in the original widget tests
/// (theme via [dsTheme], full [AppLocalizations] delegates) so behaviour and
/// rendered copy match the running app.

/// Disable runtime font fetching. Put this in `setUpAll`.
void disableDsFonts() {
  GoogleFonts.config.allowRuntimeFetching = false;
}

/// Wrap [child] in a themed, localized [MaterialApp] for pumping.
///
/// Set [wrapInScaffold] when [child] is not itself a [Scaffold]/page and needs
/// a Material surface (e.g. a bare widget that uses `Material` ancestors).
Widget dsWrap(Widget child, {bool wrapInScaffold = false}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: dsTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: wrapInScaffold ? Scaffold(body: child) : child,
  );
}

/// Wrap [child] like [dsWrap] but expose an injected [StackRouter] so widgets
/// that call `context.router.push(...)` can be driven against a mock router.
Widget dsWrapRouted(Widget child, {required StackRouter router}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: dsTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: StackRouterScope(controller: router, stateHash: 0, child: child),
  );
}
