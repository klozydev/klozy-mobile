import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// Six-cell OTP input with auto-advance and backspace-to-previous. Each filled
/// cell shows a gold border. Mirrors the prototype `CodeInput`.
class DSCodeInput extends StatefulWidget {
  final int length;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  const DSCodeInput({
    super.key,
    this.length = 6,
    this.autofocus = true,
    this.onChanged,
    this.onCompleted,
  });

  @override
  State<DSCodeInput> createState() => _DSCodeInputState();
}

class _DSCodeInputState extends State<DSCodeInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List<TextEditingController>.generate(
      widget.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List<FocusNode>.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _emit() {
    final code = _code;
    widget.onChanged?.call(code);
    if (code.length == widget.length) widget.onCompleted?.call(code);
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(_emit);
  }

  void _onKey(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(_emit);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < widget.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == widget.length - 1 ? 0 : 9),
              child: SizedBox(
                height: 58,
                child: KeyboardListener(
                  focusNode: FocusNode(skipTraversal: true),
                  onKeyEvent: (event) => _onKey(i, event),
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    autofocus: widget.autofocus && i == 0,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    cursorColor: DSColor.primary,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) => _onChanged(i, value),
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: 22,
                      fontWeight: DSFontWeight.bold,
                      color: DSColor.onSurface,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: DSColor.card,
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: _border(_controllers[i].text.isNotEmpty),
                      focusedBorder: _border(true),
                      border: _border(_controllers[i].text.isNotEmpty),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  OutlineInputBorder _border(bool active) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(DSBorderRadius.input),
    borderSide: BorderSide(
      color: active ? DSColor.primary : DSColor.onSurface15,
    ),
  );
}
