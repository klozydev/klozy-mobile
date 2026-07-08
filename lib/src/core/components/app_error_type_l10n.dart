import 'package:klozy/l10n/app_localizations.dart';
import 'package:klozy/src/core/components/app_error_type.dart';

/// Localizes an [AppErrorType] into a title / message pair rendered by
/// [AppErrorWidget]. Kept as a single exhaustive mapper so the compiler
/// enforces coverage of every [AppErrorType] case.
extension AppErrorTypeL10n on AppErrorType {
  String title(AppLocalizations l10n) => switch (this) {
    AppErrorType.network => l10n.error_type_network_title,
    AppErrorType.timeout => l10n.error_type_timeout_title,
    AppErrorType.unauthorized => l10n.error_type_unauthorized_title,
    AppErrorType.notFound => l10n.error_type_not_found_title,
    AppErrorType.server => l10n.error_type_server_title,
    AppErrorType.unknown => l10n.error_type_unknown_title,
  };

  String message(AppLocalizations l10n) => switch (this) {
    AppErrorType.network => l10n.error_type_network_message,
    AppErrorType.timeout => l10n.error_type_timeout_message,
    AppErrorType.unauthorized => l10n.error_type_unauthorized_message,
    AppErrorType.notFound => l10n.error_type_not_found_message,
    AppErrorType.server => l10n.error_type_server_message,
    AppErrorType.unknown => l10n.error_type_unknown_message,
  };
}
