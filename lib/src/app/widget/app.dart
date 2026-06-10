import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/app/bloc/app_bloc.dart';
import 'package:klozy/src/app/bloc/app_event.dart';
import 'package:klozy/src/app/bloc/app_state.dart';
import 'package:klozy/src/app/cart/cart_cubit.dart';
import 'package:klozy/src/app/notifications/notifications_cubit.dart';
import 'package:klozy/src/app/theme/app_config_change_notifier.dart';
import 'package:klozy/src/app/wishlist/wishlist_cubit.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_theme.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() {
    return _AppState();
  }
}

class _AppState extends State<App> {
  final _appRouter = locator<AppRouter>();
  final _themeChangeNotifier = locator<AppConfigChangeNotifier>();
  late final AppBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = locator<AppBloc>();
    _bloc.add(AppInitEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      bloc: _bloc,
      builder: _builder,
      buildWhen: _buildWhen,
    );
  }

  bool _buildWhen(AppState previous, AppState current) {
    return current is AppIdleState;
  }

  Widget _builder(BuildContext _, AppState state) {
    if (state is AppIdleState) {
      // ProviderScope backs the chat island (Riverpod/hooks). Harmless to the
      // existing BLoC/Cubit tree.
      return ProviderScope(
        child: ChangeNotifierProvider(
          create: (_) => _themeChangeNotifier,
          child: Consumer<AppConfigChangeNotifier>(
            builder:
                (
                  BuildContext context,
                  AppConfigChangeNotifier _,
                  Widget? child,
                ) {
                  return MultiBlocProvider(
                    providers: <BlocProvider<dynamic>>[
                      BlocProvider<WishlistCubit>.value(
                        value: locator<WishlistCubit>(),
                      ),
                      BlocProvider<CartCubit>.value(
                        value: locator<CartCubit>(),
                      ),
                      BlocProvider<NotificationsCubit>.value(
                        value: locator<NotificationsCubit>(),
                      ),
                    ],
                    child: MaterialApp.router(
                      routerConfig: _appRouter.config(),
                      debugShowCheckedModeBanner: false,
                      onGenerateTitle: (BuildContext context) =>
                          context.l10N.app_name,
                      // easy_localization (chat `.tr()`) + gen-l10n (`context.l10N`)
                      // delegates coexist; locale/supportedLocales come from
                      // EasyLocalization (root, in main.dart).
                      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
                        ...context.localizationDelegates,
                        ...AppLocalizations.localizationsDelegates,
                      ],
                      supportedLocales: context.supportedLocales,
                      locale: context.locale,
                      theme: dsTheme(),
                      builder: (context, child) {
                        final clamped = MediaQuery.textScalerOf(
                          context,
                        ).clamp(minScaleFactor: 1, maxScaleFactor: 1.2);
                        return MediaQuery(
                          data: MediaQuery.of(
                            context,
                          ).copyWith(textScaler: clamped),
                          child: child ?? const SizedBox.shrink(),
                        );
                      },
                    ),
                  );
                },
          ),
        ),
      );
    }
    return const SizedBox();
  }

  @override
  void dispose() {
    _bloc.close();
    _themeChangeNotifier.dispose();
    _appRouter.dispose();
    super.dispose();
  }
}
