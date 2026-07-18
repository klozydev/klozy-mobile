import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/navigation/safe_navigation.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/feature/settings/presentation/widget/settings_row_widget.dart';
import 'package:klozy/src/feature/settings/presentation/widget/settings_section_widget.dart';
import 'package:klozy/src/router/app_router.dart';

/// Settings › Personal data grouping page: personal information, feed
/// preferences and blocked users (design: "Personal data").
@RoutePage()
class PersonalDataPage extends StatelessWidget {
  const PersonalDataPage({super.key});

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
        title: Text(l.settings_personal_data),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: <Widget>[
          SettingsSectionWidget(
            title: l.settings_section_profile,
            children: <Widget>[
              SettingsRowWidget(
                icon: Icons.person_outline,
                label: l.settings_personal_information,
                onTap: () => context.router.pushSafe(const EditProfileRoute()),
              ),
            ],
          ),
          SettingsSectionWidget(
            title: l.settings_group_preferences,
            children: <Widget>[
              SettingsRowWidget(
                icon: Icons.palette_outlined,
                label: l.settings_clothing_preference,
                onTap: () =>
                    context.router.pushSafe(const ClothingPreferenceRoute()),
              ),
              SettingsRowWidget(
                icon: Icons.straighten_rounded,
                label: l.settings_preferred_size,
                onTap: () =>
                    context.router.pushSafe(const PreferredSizeRoute()),
              ),
              SettingsRowWidget(
                icon: Icons.sell_outlined,
                label: l.settings_preferred_brands,
                onTap: () =>
                    context.router.pushSafe(const PreferredBrandsRoute()),
              ),
            ],
          ),
          SettingsSectionWidget(
            title: l.settings_section_privacy,
            children: <Widget>[
              SettingsRowWidget(
                icon: Icons.block_outlined,
                label: l.settings_blocked_users,
                onTap: () => context.router.pushSafe(const BlockedUsersRoute()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
