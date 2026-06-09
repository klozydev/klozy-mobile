import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/router/app_router.dart';

/// "You're all set" — the celebratory end of onboarding. Enters the app shell.
@RoutePage()
class SuccessPage extends StatelessWidget {
  final String? firstName;

  const SuccessPage({super.key, this.firstName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.35),
            radius: 0.85,
            colors: <Color>[Color(0x42E0CE7D), DSColor.surface],
            stops: <double>[0.0, 0.62],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: 92,
                          height: 92,
                          decoration: const BoxDecoration(
                            color: DSColor.primary,
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Color(0x66E0CE7D),
                                blurRadius: 50,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 46,
                            color: DSColor.surface,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          firstName == null
                              ? context.l10N.onboarding_all_set
                              : context.l10N.onboarding_all_set_named(
                                  firstName!,
                                ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: 28,
                            fontWeight: DSFontWeight.bold,
                            letterSpacing: -0.56,
                            color: DSColor.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.l10N.onboarding_feed_ready_subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: DSFontSize.bodyLarge,
                            height: 1.57,
                            color: DSColor.onSurface60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              DSBottomBar(
                child: DSButtonElevated(
                  text: context.l10N.onboarding_start_exploring,
                  onPressed: () => context.router.replaceAll(
                    const <PageRouteInfo>[ShellRoute()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
