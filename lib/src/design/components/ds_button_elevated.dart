import 'package:flutter/material.dart';

import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

class DSButtonElevated extends StatelessWidget {
  static const double _height = 48;
  static const double _loaderSize = 24;

  final String _text;
  final bool _isLoading;
  final bool _isEnable;
  final VoidCallback? _onPressed;
  final Color _backgroundColor;
  final IconData? _icon;

  const DSButtonElevated({
    super.key,
    required String text,
    bool isLoading = false,
    bool isEnable = true,
    VoidCallback? onPressed,
    Color backgroundColor = DSColor.primary,
    IconData? icon,
  }) : _text = text,
       _isLoading = isLoading,
       _isEnable = isEnable,
       _onPressed = onPressed,
       _backgroundColor = backgroundColor,
       _icon = icon;

  @override
  Widget build(BuildContext context) {
    final disabled = _isLoading || !_isEnable;
    final onPressed = disabled ? null : _onPressed;

    final child = _isLoading
        ? const SizedBox(
            width: _loaderSize,
            height: _loaderSize,
            child: CircularProgressIndicator(
              color: DSColor.surface,
              strokeWidth: 3,
            ),
          )
        : _icon == null
        ? Text(
            _text,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: DSColor.surface),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(_icon, size: 17, color: DSColor.surface),
              const SizedBox(width: DSSpacing.xxs),
              Flexible(
                child: Text(
                  _text,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: DSColor.surface),
                ),
              ),
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: _height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _backgroundColor,
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
