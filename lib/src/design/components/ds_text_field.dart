import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klozy/src/design/components/ds_error_text.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// Klozy text field — 52px, dark card fill, hairline border that turns gold on
/// focus (red on error), optional leading icon + trailing slot, inline error.
/// Matches the prototype `KTextField`. For multiline, set [maxLines] > 1.
class DSTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? trailing;
  final bool obscureText;
  final bool autofocus;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const DSTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.errorText,
    this.prefixIcon,
    this.trailing,
    this.obscureText = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<DSTextField> createState() => _DSTextFieldState();
}

class _DSTextFieldState extends State<DSTextField> {
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null;
    final Color borderColor = hasError
        ? DSColor.danger
        : _focused
        ? DSColor.primary
        : DSColor.onSurface15;
    final bool multiline = widget.maxLines > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: BoxConstraints(minHeight: multiline ? 0 : 52),
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: multiline ? 12 : 0,
          ),
          decoration: BoxDecoration(
            color: DSColor.card,
            borderRadius: BorderRadius.circular(DSBorderRadius.input),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: multiline
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: <Widget>[
              if (widget.prefixIcon != null) ...<Widget>[
                Icon(
                  widget.prefixIcon,
                  size: 18,
                  color: _focused ? DSColor.primary : DSColor.onSurface45,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  obscureText: widget.obscureText,
                  maxLines: widget.maxLines,
                  maxLength: widget.maxLength,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  inputFormatters: widget.inputFormatters,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  cursorColor: DSColor.primary,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodyLarge,
                    fontWeight: DSFontWeight.medium,
                    color: DSColor.onSurface,
                    letterSpacing: -0.14,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    counterText: '',
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyLarge,
                      fontWeight: DSFontWeight.medium,
                      color: DSColor.onSurface45,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: multiline ? 0 : 16,
                    ),
                  ),
                ),
              ),
              if (widget.trailing != null) ...<Widget>[
                const SizedBox(width: 8),
                widget.trailing!,
              ],
            ],
          ),
        ),
        if (hasError) DSErrorText(widget.errorText!),
      ],
    );
  }
}
