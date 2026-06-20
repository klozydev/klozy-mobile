import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/feature/settings/presentation/widget/settings_row_widget.dart';
import 'package:klozy/src/feature/settings/presentation/widget/settings_section_widget.dart';
import 'package:klozy/src/router/app_router.dart';

/// Settings › Security grouping page: change email, change password and phone
/// number (design: "Security").
@RoutePage()
class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10N;
    return Scaffold(
      backgroundColor: DSColor.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(l.settings_security),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: <Widget>[
          SettingsSectionWidget(
            title: l.settings_security,
            children: <Widget>[
              SettingsRowWidget(
                icon: Icons.mail_outline_rounded,
                label: l.settings_change_email,
                onTap: () => context.router.push(const ChangeEmailRoute()),
              ),
              SettingsRowWidget(
                icon: Icons.lock_outline_rounded,
                label: l.settings_change_password,
                onTap: () => context.router.push(const ChangePasswordRoute()),
              ),
              SettingsRowWidget(
                icon: Icons.phone_outlined,
                label: l.settings_phone_number,
                onTap: () => context.router.push(const ChangePhoneRoute()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
