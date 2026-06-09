import 'package:flutter/material.dart';

import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

class DSButtonOutline extends StatelessWidget {
  static const double _height = 48;
  static const double _loaderSize = 24;

  final String _text;
  final bool _isLoading;
  final VoidCallback? _onPressed;

  const DSButtonOutline({
    super.key,
    required String text,
    bool isLoading = false,
    VoidCallback? onPressed,
  }) : _text = text,
       _isLoading = isLoading,
       _onPressed = onPressed;

  @override
  Widget build(BuildContext context) {
    final onPressed = _isLoading ? null : _onPressed;

    final child = _isLoading
        ? const SizedBox(
            width: _loaderSize,
            height: _loaderSize,
            child: CircularProgressIndicator(
              color: DSColor.onSurface,
              strokeWidth: 3,
            ),
          )
        : Text(
            _text,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: DSColor.onSurface),
          );

    return SizedBox(
      width: double.infinity,
      height: _height,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: DSColor.onSurface24, width: 0.5),
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.s,
            vertical: DSSpacing.xxs,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSBorderRadius.input),
          ),
        ),
        onPressed: onPressed,
        child: Center(child: child),
      ),
    );
  }
}
