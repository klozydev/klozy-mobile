import 'package:flutter/material.dart';
import 'package:klozy/src/app/theme/app_config_change_notifier.dart';
import 'package:klozy/src/core/l10n/app_language.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/di/injection.dart';

/// Bottom-sheet list of the app's supported languages. Tapping one persists the
/// choice via [AppConfigChangeNotifier.setLocale], which rebuilds the app at the
/// new locale, and closes the sheet.
class LanguagePickerSheet extends StatelessWidget {
  const LanguagePickerSheet({required this.currentCode, super.key});

  final String currentCode;

  static Future<void> show(BuildContext context, String title, String current) {
    return DSBottomSheet.show<void>(
      context,
      title: title,
      child: LanguagePickerSheet(currentCode: current),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppConfigChangeNotifier config = locator<AppConfigChangeNotifier>();
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: DSSpacing.l),
      itemCount: kAppLanguages.length,
      itemBuilder: (BuildContext context, int index) {
        final AppLanguage language = kAppLanguages[index];
        final bool selected = language.code == currentCode;
        return ListTile(
          title: Text(
            language.name,
            style: TextStyle(
              color: selected ? DSColor.primary : DSColor.onSurface,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          trailing: selected
              ? const Icon(Icons.check_rounded, color: DSColor.primary)
              : null,
          onTap: () async {
            await config.setLocale(language.code);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        );
      },
    );
  }
}
