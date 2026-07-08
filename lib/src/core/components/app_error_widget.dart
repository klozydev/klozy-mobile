import 'package:flutter/material.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/components/app_error_type_l10n.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

/// Centered error state with a retry action. Rendered by feature pages when a
/// BLoC emits an error state carrying an [AppErrorType].
class AppErrorWidget extends StatelessWidget {
  final AppErrorType type;
  final VoidCallback onRetry;

  /// Overrides [AppErrorType.message] with a server-provided message (e.g. a
  /// 409 business error) when present.
  final String? message;

  const AppErrorWidget({
    super.key,
    required this.type,
    required this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              type.title(context.l10N),
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: DSSpacing.xxs),
            Text(
              message ?? type.message(context.l10N),
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: DSColor.onSurface60,
              ),
            ),
            const SizedBox(height: DSSpacing.l),
            DSButtonOutline(
              text: context.l10N.common_try_again,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
