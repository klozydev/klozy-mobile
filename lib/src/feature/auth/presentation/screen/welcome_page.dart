import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/navigation/safe_navigation.dart';
import 'package:klozy/src/design/components/ds_app_logo.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/feature/auth/presentation/screen/widgets/welcome_hero.dart';
import 'package:klozy/src/router/app_router.dart';

/// Entry screen — full-bleed editorial hero + brand block + "Get started" /
/// "Log in", matching the onboarding prototype's `ScreenWelcome`.
@RoutePage()
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: WelcomeHero()),
          // Brand block, centered above the fold (≈32% from the top).
          Align(
            alignment: const Alignment(0, -0.36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const DSAppLogo(size: 44),
                const SizedBox(height: 18),
                Text(
                  context.l10N.auth_country_uae,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: 10,
                    fontWeight: DSFontWeight.semiBold,
                    letterSpacing: 3.2,
                    color: DSColor.onSurface45,
                  ),
                ),
              ],
            ),
          ),
          // Tagline + CTAs, anchored to the bottom.
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  DSSpacing.l,
                  0,
                  DSSpacing.l,
                  DSSpacing.xxl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      context.l10N.auth_welcome_title,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontFamily: dsFontFamily,
                        fontSize: 30,
                        height: 1.2,
                        fontWeight: DSFontWeight.bold,
                        letterSpacing: -0.75,
                        color: DSColor.onSurface,
                      ),
                    ),
                    const SizedBox(height: 22),
                    DSButtonElevated(
                      text: context.l10N.auth_get_started,
                      onPressed: () =>
                          context.router.pushSafe(LoginRoute(isSignUp: true)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () =>
                          context.router.pushSafe(LoginRoute(isSignUp: false)),
                      child: Text.rich(
                        TextSpan(
                          text: context.l10N.auth_already_have_account,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: DSFontSize.bodyLarge,
                            fontWeight: DSFontWeight.medium,
                            color: DSColor.onSurface75,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: context.l10N.auth_log_in,
                              style: const TextStyle(
                                fontWeight: DSFontWeight.semiBold,
                                color: DSColor.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
