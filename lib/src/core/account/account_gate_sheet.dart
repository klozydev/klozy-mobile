import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/navigation/safe_navigation.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/domain/account/entity/account_status.dart';
import 'package:klozy/src/router/app_router.dart';

/// Login / sign-up CTA presented by [AccountGate] when a guest (or legacy
/// session) attempts a gated action. Built on [DSBottomSheet] with DS components.
///
/// Copy/CTAs branch on [status]:
/// - [AccountStatus.guest] or [AccountStatus.legacy] — "Create an account /
///   Log in to continue", both CTAs navigate to [WelcomeRoute].
/// - [AccountStatus.incompleteOnboarding] — "Finish setting up your profile",
///   CTA navigates straight to [ProfileCompletionRoute] (skips the personalize
///   step) to finish the profile the gated action requires.
class AccountGateSheet extends StatelessWidget {
  final AccountStatus status;

  const AccountGateSheet({super.key, required this.status});

  /// Presents the sheet. Resolves once dismissed/actioned.
  static Future<void> show(
    BuildContext context, {
    required AccountStatus status,
  }) {
    return DSBottomSheet.show<void>(
      context,
      child: AccountGateSheet(status: status),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncompleteOnboarding = status == AccountStatus.incompleteOnboarding;
    return isIncompleteOnboarding
        ? _IncompleteOnboardingContent(status: status)
        : _GuestOrLegacyContent(status: status);
  }
}

class _GuestOrLegacyContent extends StatelessWidget {
  final AccountStatus status;

  const _GuestOrLegacyContent({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10N;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: DSSpacing.xs),
        Text(
          l10n.account_gate_guest_title,
          style: context.textTheme.titleLarge?.copyWith(
            color: DSColor.onSurface,
            fontWeight: DSFontWeight.bold,
          ),
        ),
        const SizedBox(height: DSSpacing.xxs),
        Text(
          l10n.account_gate_guest_subtitle,
          style: context.textTheme.bodyMedium?.copyWith(
            color: DSColor.onSurface60,
          ),
        ),
        const SizedBox(height: DSSpacing.l),
        DSButtonElevated(
          text: l10n.account_gate_create_account,
          onPressed: () {
            final router = context.router;
            Navigator.of(context).maybePop();
            router.pushSafe(const WelcomeRoute());
          },
        ),
        const SizedBox(height: DSSpacing.xs),
        DSButtonOutline(
          text: l10n.account_gate_log_in,
          onPressed: () {
            final router = context.router;
            Navigator.of(context).maybePop();
            router.pushSafe(const WelcomeRoute());
          },
        ),
        const SizedBox(height: DSSpacing.xxs),
      ],
    );
  }
}

class _IncompleteOnboardingContent extends StatelessWidget {
  final AccountStatus status;

  const _IncompleteOnboardingContent({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10N;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: DSSpacing.xs),
        Text(
          l10n.account_gate_incomplete_title,
          style: context.textTheme.titleLarge?.copyWith(
            color: DSColor.onSurface,
            fontWeight: DSFontWeight.bold,
          ),
        ),
        const SizedBox(height: DSSpacing.xxs),
        Text(
          l10n.account_gate_incomplete_subtitle,
          style: context.textTheme.bodyMedium?.copyWith(
            color: DSColor.onSurface60,
          ),
        ),
        const SizedBox(height: DSSpacing.l),
        DSButtonElevated(
          text: l10n.account_gate_finish_setup,
          onPressed: () {
            // Capture router before popping the sheet: the widget's context
            // becomes stale once maybePop() removes it from the tree.
            final router = context.router;
            Navigator.of(context).maybePop();
            // Skip the "personalize your feed" step — go straight to the
            // profile-completion form when an action needs a complete profile.
            router.pushSafe(const ProfileCompletionRoute());
          },
        ),
        const SizedBox(height: DSSpacing.xxs),
      ],
    );
  }
}
