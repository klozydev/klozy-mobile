import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_klozy_mark.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/router/app_router.dart';

/// Full-tab placeholder shown in private tabs (Chat, Profile) when the
/// signed-in user hasn't finished setting up their profile. Prompts them to
/// complete it instead of rendering the tab in a broken/empty state.
class IncompleteProfilePlaceholderWidget extends StatelessWidget {
  const IncompleteProfilePlaceholderWidget({super.key});

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
              const DSKlozyMark(size: 48),
              const SizedBox(height: DSSpacing.xl),
              Text(
                context.l10N.chat_incomplete_profile_title,
                textAlign: TextAlign.center,
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: DSSpacing.xxs),
              Text(
                context.l10N.chat_incomplete_profile_subtitle,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: DSColor.onSurface60,
                ),
              ),
              const SizedBox(height: DSSpacing.xl),
              DSButtonElevated(
                text: context.l10N.chat_incomplete_profile_cta,
                onPressed: () => context.router.push(const EditProfileRoute()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
