import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// Idle composer: attach button, rounded text field, and a mic↔send button that
/// swaps on whether the field has text.
class ComposerBar extends StatefulWidget {
  const ComposerBar({
    super.key,
    required this.controller,
    required this.onAttach,
    required this.onSendText,
    required this.onStartRecording,
  });

  final TextEditingController controller;
  final VoidCallback onAttach;
  final ValueChanged<String> onSendText;
  final VoidCallback onStartRecording;

  @override
  State<ComposerBar> createState() => _ComposerBarState();
}

class _ComposerBarState extends State<ComposerBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onChanged);
  }

  void _onChanged() {
    final bool has = widget.controller.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  void _send() {
    final String text = widget.controller.text.trim();
    if (text.isEmpty) return;
    widget.onSendText(text);
    widget.controller.clear();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DSColor.surface,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            _CircleButton(
              icon: Icons.add,
              iconColor: DSColor.onSurface75,
              onTap: widget.onAttach,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 42,
                padding: const EdgeInsets.only(left: 15, right: 6),
                decoration: BoxDecoration(
                  color: DSColor.card,
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(color: DSColor.onSurface12, width: 0.5),
                ),
                child: Center(
                  child: TextField(
                    controller: widget.controller,
                    onSubmitted: (_) => _send(),
                    textInputAction: TextInputAction.send,
                    cursorColor: DSColor.primary,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyLarge,
                      fontWeight: DSFontWeight.medium,
                      color: DSColor.onSurface,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: context.l10N.chat_composer_hint,
                      hintStyle: const TextStyle(
                        fontFamily: dsFontFamily,
                        fontSize: DSFontSize.bodyLarge,
                        fontWeight: DSFontWeight.medium,
                        color: DSColor.onSurface35,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (_hasText)
              _CircleButton(
                icon: Icons.send,
                iconColor: DSColor.surface,
                background: DSColor.primary,
                onTap: _send,
              )
            else
              _CircleButton(
                icon: Icons.mic_none,
                iconColor: DSColor.onSurface75,
                onTap: widget.onStartRecording,
              ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.background,
  });

  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: background ?? DSColor.onSurface07,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 19),
      ),
    );
  }
}
