import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_klozy_mark.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/router/app_router.dart';

/// Entry screen — brand hero + "Get started" / "Log in". (Hero photo asset
/// pending; rendered over a dark gradient with the brand gold glow for now.)
@RoutePage()
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.35),
            radius: 0.9,
            colors: <Color>[Color(0x33E0CE7D), DSColor.surface],
            stops: <double>[0.0, 0.7],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(
              children: <Widget>[
                const Spacer(flex: 4),
                const DSKlozyMark(size: 42),
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
                const Spacer(flex: 5),
                Text(
                  context.l10N.auth_welcome_title,
                  textAlign: TextAlign.center,
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
                      context.router.push(LoginRoute(isSignUp: true)),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      context.router.push(LoginRoute(isSignUp: false)),
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
    );
  }
}
