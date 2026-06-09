import 'package:flutter/material.dart';
import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/design/app_theme.dart';

extension ContextExt on BuildContext {
  AppLocalizations get l10N => AppLocalizations.of(this)!;

  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  AppTheme get appTheme =>
      Theme.of(this).extension<AppTheme>() ?? const AppTheme.dark();

  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
