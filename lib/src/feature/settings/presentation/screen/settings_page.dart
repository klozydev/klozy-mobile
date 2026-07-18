import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/navigation/safe_navigation.dart';
import 'package:klozy/src/core/util/app_share.dart';
import 'package:klozy/src/core/util/instagram_link.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/feature/settings/presentation/bloc/settings_bloc.dart';
import 'package:klozy/src/feature/settings/presentation/bloc/settings_event.dart';
import 'package:klozy/src/feature/settings/presentation/bloc/settings_state.dart';
import 'package:klozy/src/feature/settings/presentation/widget/settings_row_widget.dart';
import 'package:klozy/src/feature/settings/presentation/widget/settings_section_widget.dart';
import 'package:klozy/src/router/app_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class SettingsPage extends StatelessWidget implements AutoRouteWrapper {
  const SettingsPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<SettingsBloc>(
      create: (_) => locator<SettingsBloc>()..add(const SettingsStarted()),
      child: this,
    );
  }

  Future<bool> _confirm(
    BuildContext context,
    String message,
    String confirm,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext c) => AlertDialog(
        backgroundColor: DSColor.card,
        content: Text(
          message,
          style: const TextStyle(color: DSColor.onSurface),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: Text(context.l10N.settings_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: Text(confirm),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _launch(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        context.showSnackBar(context.l10N.settings_link_failed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (BuildContext context, SettingsState state) {
        if (state is SettingsSignedOutState) {
          context.router.replaceAllSafe(const <PageRouteInfo>[WelcomeRoute()]);
        }
      },
      builder: (BuildContext context, SettingsState state) {
        return Scaffold(
          backgroundColor: DSColor.surface,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 22),
              onPressed: () => context.router.maybePop(),
            ),
            title: Text(context.l10N.settings_title),
            actions: <Widget>[
              if (state is SettingsLoadedState) _overflowMenu(context, state),
            ],
          ),
          body: switch (state) {
            SettingsLoadingState() => const DSLoader(),
            SettingsSignedOutState() => const DSLoader(),
            SettingsErrorState(:final type) => AppErrorWidget(
              type: type,
              onRetry: () =>
                  context.read<SettingsBloc>().add(const SettingsStarted()),
            ),
            SettingsLoadedState() => _menu(context, state),
          },
        );
      },
    );
  }

  Widget _menu(BuildContext context, SettingsLoadedState state) {
    final l = context.l10N;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: <Widget>[
        SettingsSectionWidget(
          title: l.settings_group_account,
          children: <Widget>[
            SettingsRowWidget(
              icon: Icons.person_outline,
              label: l.settings_personal_data,
              subtitle: l.settings_personal_data_sub,
              onTap: () => context.router.pushSafe(const PersonalDataRoute()),
            ),
            SettingsRowWidget(
              icon: Icons.shield_outlined,
              label: l.settings_security,
              subtitle: l.settings_security_sub,
              onTap: () => context.router.pushSafe(const SecurityRoute()),
            ),
            SettingsRowWidget(
              icon: Icons.account_balance_outlined,
              label: l.settings_payouts,
              subtitle: l.settings_payouts_sub,
              onTap: () => context.router.pushSafe(const PayoutRoute()),
            ),
          ],
        ),
        SettingsSectionWidget(
          title: l.settings_group_notifications,
          children: <Widget>[
            // Email notifications are intentionally omitted for now — only push
            // is exposed. The Switch uses a shrink-wrapped tap target so the row
            // height matches the other (subtitle-less) settings rows.
            SettingsRowWidget(
              icon: Icons.notifications_none_rounded,
              label: l.settings_push_notifications,
              trailing: Switch(
                value: state.settings.push,
                activeColor: DSColor.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (bool v) => context.read<SettingsBloc>().add(
                  SettingsToggleNotification(push: v),
                ),
              ),
            ),
          ],
        ),
        SettingsSectionWidget(
          title: l.settings_group_other,
          children: <Widget>[
            SettingsRowWidget(
              icon: Icons.help_outline_rounded,
              label: l.settings_support,
              onTap: () => _support(context, state),
            ),
            SettingsRowWidget(
              icon: Icons.ios_share_rounded,
              label: l.settings_share_app,
              onTap: () => AppShare.text(l.settings_share_message),
            ),
          ],
        ),
        SettingsSectionWidget(
          title: l.settings_group_links,
          children: <Widget>[
            SettingsRowWidget(
              icon: Icons.privacy_tip_outlined,
              label: l.settings_privacy,
              onTap: () =>
                  context.router.pushSafe(LegalDocRoute(docKey: 'privacy')),
            ),
            SettingsRowWidget(
              icon: Icons.description_outlined,
              label: l.settings_terms,
              onTap: () =>
                  context.router.pushSafe(LegalDocRoute(docKey: 'cgvu')),
            ),
            SettingsRowWidget(
              icon: Icons.gavel_rounded,
              label: l.settings_legal_notices,
              onTap: () =>
                  context.router.pushSafe(LegalDocRoute(docKey: 'legal')),
            ),
            SettingsRowWidget(
              icon: Icons.info_outline_rounded,
              label: l.settings_about,
              onTap: () =>
                  context.router.pushSafe(LegalDocRoute(docKey: 'about')),
            ),
          ],
        ),
        // Instagram lives in the social section — only render it when the
        // admin has configured a handle. Otherwise the row "works" but the tap
        // fell through to the support fallback and surfaced a misleading
        // "Support is unavailable" snackbar.
        if (state.contact.instagram != null &&
            state.contact.instagram!.trim().isNotEmpty)
          SettingsSectionWidget(
            title: l.settings_group_social,
            children: <Widget>[
              SettingsRowWidget(
                icon: Icons.camera_alt_outlined,
                label: l.settings_instagram,
                value: instagramHandleDisplay(state.contact.instagram!),
                onTap: () =>
                    _launch(context, instagramUrl(state.contact.instagram!)),
              ),
            ],
          ),
        const SizedBox(height: 16),
        const _VersionRow(),
      ],
    );
  }

  /// App-bar ⋯ menu holding the destructive account actions (design: Log out /
  /// Delete account behind the overflow, each guarded by a confirm dialog).
  Widget _overflowMenu(BuildContext context, SettingsLoadedState state) {
    final l = context.l10N;
    if (state.isBusy) {
      // Center a correctly-sized spinner in the app-bar action slot (the old
      // raw 18px box rendered off-centre and cramped).
      return const SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: DSColor.onSurface60,
            ),
          ),
        ),
      );
    }
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz_rounded, color: DSColor.onSurface),
      color: DSColor.card,
      onSelected: (String value) async {
        if (value == 'logout') {
          if (await _confirm(
                context,
                l.settings_logout_confirm,
                l.settings_logout,
              ) &&
              context.mounted) {
            context.read<SettingsBloc>().add(const SettingsLoggedOut());
          }
        } else if (value == 'delete') {
          if (await _confirm(
                context,
                l.settings_delete_confirm,
                l.settings_delete_account,
              ) &&
              context.mounted) {
            context.read<SettingsBloc>().add(const SettingsAccountDeleted());
          }
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.logout_rounded,
                size: 18,
                color: DSColor.onSurface60,
              ),
              const SizedBox(width: 12),
              Text(
                l.settings_logout,
                style: const TextStyle(color: DSColor.onSurface),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: DSColor.danger,
              ),
              const SizedBox(width: 12),
              Text(
                l.settings_delete_account,
                style: const TextStyle(color: DSColor.danger),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _support(BuildContext context, SettingsLoadedState state) {
    final email = state.contact.supportEmail;
    if (email != null && email.isNotEmpty) {
      _launch(context, 'mailto:$email');
    } else {
      context.showSnackBar(context.l10N.settings_support_unavailable);
    }
  }
}

class _VersionRow extends StatelessWidget {
  const _VersionRow();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
        final info = snapshot.data;
        return SettingsRowWidget(
          icon: Icons.info_outline_rounded,
          label: context.l10N.settings_version,
          value: info == null ? '' : '${info.version} (${info.buildNumber})',
        );
      },
    );
  }
}
