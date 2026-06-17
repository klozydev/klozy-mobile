import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/app/theme/app_config_change_notifier.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/l10n/app_language.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';
import 'package:klozy/src/feature/settings/presentation/bloc/settings_bloc.dart';
import 'package:klozy/src/feature/settings/presentation/bloc/settings_event.dart';
import 'package:klozy/src/feature/settings/presentation/bloc/settings_state.dart';
import 'package:klozy/src/feature/settings/presentation/widget/language_picker_sheet.dart';
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

  String _currentLanguageName() {
    final String code = locator<AppConfigChangeNotifier>().locale;
    return kAppLanguages
        .firstWhere(
          (AppLanguage l) => l.code == code,
          orElse: () => kAppLanguages.first,
        )
        .name;
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
          context.router.replaceAll(const <PageRouteInfo>[WelcomeRoute()]);
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
          title: l.settings_section_profile,
          children: <Widget>[
            SettingsRowWidget(
              icon: Icons.person_outline,
              label: l.settings_edit_profile,
              onTap: () => context.router.push(const EditProfileRoute()),
            ),
            SettingsRowWidget(
              icon: Icons.location_on_outlined,
              label: l.settings_delivery_address,
              onTap: () => context.router.push(const AddressBookRoute()),
            ),
            SettingsRowWidget(
              icon: Icons.tune_rounded,
              label: l.settings_preferences,
              onTap: () => context.router.push(const PreferencesRoute()),
            ),
            SettingsRowWidget(
              icon: Icons.language_rounded,
              label: l.settings_language,
              value: _currentLanguageName(),
              onTap: () => LanguagePickerSheet.show(
                context,
                l.settings_language,
                locator<AppConfigChangeNotifier>().locale,
              ),
            ),
          ],
        ),
        SettingsSectionWidget(
          title: l.settings_section_seller,
          children: <Widget>[
            SettingsRowWidget(
              icon: Icons.account_balance_outlined,
              label: l.settings_payout_iban,
              onTap: () => context.router.push(const PayoutRoute()),
            ),
            SettingsRowWidget(
              icon: Icons.payments_outlined,
              label: l.settings_payouts,
              onTap: () => context.router.push(const PayoutsRoute()),
            ),
            SettingsRowWidget(
              icon: Icons.insights_outlined,
              label: l.settings_seller_stats,
              onTap: () => context.router.push(const SellerStatsRoute()),
            ),
            SettingsRowWidget(
              icon: Icons.verified_outlined,
              label: l.connect_title,
              onTap: () => context.router.push(const SellerVerificationRoute()),
            ),
          ],
        ),
        SettingsSectionWidget(
          title: l.settings_section_notifications,
          children: <Widget>[
            SettingsRowWidget(
              icon: Icons.notifications_none_rounded,
              label: l.settings_push_notifications,
              trailing: Switch(
                value: state.settings.push,
                activeColor: DSColor.primary,
                onChanged: (bool v) => context.read<SettingsBloc>().add(
                  SettingsToggleNotification(push: v),
                ),
              ),
            ),
            SettingsRowWidget(
              icon: Icons.mail_outline_rounded,
              label: l.settings_email_notifications,
              trailing: Switch(
                value: state.settings.email,
                activeColor: DSColor.primary,
                onChanged: (bool v) => context.read<SettingsBloc>().add(
                  SettingsToggleNotification(email: v),
                ),
              ),
            ),
          ],
        ),
        SettingsSectionWidget(
          title: l.settings_section_privacy,
          children: <Widget>[
            SettingsRowWidget(
              icon: Icons.block_outlined,
              label: l.settings_blocked_users,
              onTap: () => context.router.push(const BlockedUsersRoute()),
            ),
            SettingsRowWidget(
              icon: Icons.lock_outline_rounded,
              label: l.settings_change_password,
              onTap: () => _changePassword(context, state),
            ),
          ],
        ),
        SettingsSectionWidget(
          title: l.settings_section_legal,
          children: <Widget>[
            SettingsRowWidget(
              icon: Icons.description_outlined,
              label: l.settings_terms,
              onTap: () => context.router.push(LegalDocRoute(docKey: 'terms')),
            ),
            SettingsRowWidget(
              icon: Icons.privacy_tip_outlined,
              label: l.settings_privacy,
              onTap: () =>
                  context.router.push(LegalDocRoute(docKey: 'privacy')),
            ),
            SettingsRowWidget(
              icon: Icons.help_outline_rounded,
              label: l.settings_support,
              onTap: () => _support(context, state),
            ),
            const _VersionRow(),
          ],
        ),
        const SizedBox(height: 8),
        SettingsSectionWidget(
          title: l.settings_section_account,
          children: <Widget>[
            SettingsRowWidget(
              icon: Icons.logout_rounded,
              label: l.settings_logout,
              danger: true,
              trailing: state.isBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: DSColor.danger,
                      ),
                    )
                  : null,
              onTap: state.isBusy
                  ? null
                  : () async {
                      if (await _confirm(
                        context,
                        l.settings_logout_confirm,
                        l.settings_logout,
                      )) {
                        if (context.mounted) {
                          context.read<SettingsBloc>().add(
                            const SettingsLoggedOut(),
                          );
                        }
                      }
                    },
            ),
            SettingsRowWidget(
              icon: Icons.delete_outline_rounded,
              label: l.settings_delete_account,
              danger: true,
              onTap: () async {
                if (await _confirm(
                  context,
                  l.settings_delete_confirm,
                  l.settings_delete_account,
                )) {
                  if (context.mounted) {
                    context.read<SettingsBloc>().add(
                      const SettingsAccountDeleted(),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _changePassword(
    BuildContext context,
    SettingsLoadedState state,
  ) async {
    final email = state.me.email;
    if (email == null || email.isEmpty) {
      context.showSnackBar(context.l10N.settings_change_password_no_email);
      return;
    }
    try {
      await locator<AuthRepository>().sendPasswordReset(email);
      if (context.mounted) {
        context.showSnackBar(context.l10N.settings_password_reset_sent);
      }
    } catch (_) {
      if (context.mounted) {
        context.showSnackBar(context.l10N.settings_link_failed);
      }
    }
  }

  void _support(BuildContext context, SettingsLoadedState state) {
    final email = state.contact.supportEmail;
    final instagram = state.contact.instagram;
    if (instagram != null && instagram.isNotEmpty) {
      _launch(context, instagram);
    } else if (email != null && email.isNotEmpty) {
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
