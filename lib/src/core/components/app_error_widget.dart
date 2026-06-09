import 'package:flutter/material.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

/// Centered error state with a retry action. Rendered by feature pages when a
/// BLoC emits an error state carrying an [AppErrorType].
class AppErrorWidget extends StatelessWidget {
  final AppErrorType type;
  final VoidCallback onRetry;

  const AppErrorWidget({super.key, required this.type, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              type.title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: DSSpacing.xxs),
            Text(
              type.message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: DSColor.onSurface60,
              ),
            ),
            const SizedBox(height: DSSpacing.l),
            DSButtonOutline(text: 'Try again', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
