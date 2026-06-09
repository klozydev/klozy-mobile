import 'package:flutter/material.dart';
import 'package:klozy/src/design/components/ds_address_suggestion.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// Address field with an inline autocomplete dropdown. The parent supplies the
/// (already-filtered) [suggestions] and handles selection via [onPicked].
/// Mirrors the prototype `AddressField`.
class DSAddressField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final List<DSAddressSuggestion> suggestions;
  final bool selected;
  final ValueChanged<String> onChanged;
  final ValueChanged<DSAddressSuggestion> onPicked;

  const DSAddressField({
    super.key,
    required this.controller,
    required this.suggestions,
    required this.onChanged,
    required this.onPicked,
    this.selected = false,
    this.hintText = 'Search your address',
  });

  @override
  State<DSAddressField> createState() => _DSAddressFieldState();
}

class _DSAddressFieldState extends State<DSAddressField> {
  final FocusNode _focusNode = FocusNode();
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _open = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showDropdown = _open && widget.suggestions.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DSTextField(
          controller: widget.controller,
          focusNode: _focusNode,
          hintText: widget.hintText,
          prefixIcon: Icons.location_on_outlined,
          onChanged: widget.onChanged,
          trailing: widget.selected
              ? const Icon(Icons.check, size: 17, color: DSColor.primary)
              : null,
        ),
        if (showDropdown)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: DSColor.popupBackground,
              borderRadius: BorderRadius.circular(DSBorderRadius.input),
              border: Border.all(color: DSColor.onSurface10, width: 0.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (int i = 0; i < widget.suggestions.length; i++)
                  _suggestionRow(widget.suggestions[i], first: i == 0),
              ],
            ),
          ),
      ],
    );
  }

  Widget _suggestionRow(DSAddressSuggestion s, {required bool first}) {
    return InkWell(
      onTap: () {
        widget.onPicked(s);
        _focusNode.unfocus();
      },
      child: Container(
        decoration: BoxDecoration(
          border: first
              ? null
              : const Border(
                  top: BorderSide(color: DSColor.onSurface07, width: 0.5),
                ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: DSColor.onSurface45,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    s.main,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyLarge,
                      fontWeight: DSFontWeight.medium,
                      color: DSColor.onSurface,
                    ),
                  ),
                  Text(
                    s.sub,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodySmall,
                      color: DSColor.onSurface45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
