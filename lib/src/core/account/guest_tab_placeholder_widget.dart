import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_app_logo.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/router/app_router.dart';

/// Full-tab guest placeholder shown in place of private content (Chat, Profile)
/// when the current session is a guest.
///
/// Tapping the primary CTA pushes [WelcomeRoute]; secondary taps the log-in
/// variant of [WelcomeRoute] (same route — the welcome screen handles the
/// branch).
class GuestTabPlaceholderWidget extends StatelessWidget {
  const GuestTabPlaceholderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSSpacing.l),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const DSAppLogo(size: 64),
              const SizedBox(height: DSSpacing.xl),
              Text(
                context.l10N.guest_tab_title,
                textAlign: TextAlign.center,
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: DSSpacing.xxs),
              Text(
                context.l10N.guest_tab_subtitle,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: DSColor.onSurface60,
                ),
              ),
              const SizedBox(height: DSSpacing.xl),
              DSButtonElevated(
                text: context.l10N.guest_tab_cta,
                onPressed: () => context.router.push(const WelcomeRoute()),
              ),
              const SizedBox(height: DSSpacing.xxs),
              DSButtonOutline(
                text: context.l10N.guest_tab_log_in,
                onPressed: () => context.router.push(const WelcomeRoute()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
