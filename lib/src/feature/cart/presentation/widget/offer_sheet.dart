import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// "Make an offer" body — one offer for the whole seller bucket. Returns the
/// amount (num) via `Navigator.pop`.
class OfferSheet extends StatefulWidget {
  final num subtotal;
  final int itemCount;

  const OfferSheet({
    super.key,
    required this.subtotal,
    required this.itemCount,
  });

  @override
  State<OfferSheet> createState() => _OfferSheetState();
}

class _OfferSheetState extends State<OfferSheet> {
  final TextEditingController _amount = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  num? get _value => num.tryParse(_amount.text.trim());
  bool get _valid => _value != null && _value! > 0 && _value! < widget.subtotal;

  void _preset(double pct) {
    setState(() => _amount.text = (widget.subtotal * pct).round().toString());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DSTextField(
          controller: _amount,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          hintText: widget.itemCount > 1
              ? context.l10N.cart_offer_hint_multi(widget.itemCount)
              : context.l10N.cart_offer_hint_single,
          onChanged: (_) => setState(() {}),
          trailing: Text(
            context.l10N.cart_currency_dhs,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodyLarge,
              fontWeight: DSFontWeight.semiBold,
              color: DSColor.onSurface45,
            ),
          ),
          errorText: _amount.text.isNotEmpty && !_valid
              ? context.l10N.cart_offer_error_below_total
              : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            _presetChip('70%', 0.7),
            const SizedBox(width: 8),
            _presetChip('80%', 0.8),
            const SizedBox(width: 8),
            _presetChip('90%', 0.9),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          context.l10N.cart_offer_chat_note,
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: DSFontSize.bodySmall,
            height: 1.45,
            color: DSColor.onSurface35,
          ),
        ),
        const SizedBox(height: 16),
        DSButtonElevated(
          text: context.l10N.cart_offer_send,
          isEnable: _valid,
          onPressed: () => Navigator.of(context).pop(_value),
        ),
      ],
    );
  }

  Widget _presetChip(String label, double pct) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _preset(pct),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: DSColor.onSurface07,
            borderRadius: BorderRadius.circular(DSBorderRadius.chip),
            border: Border.all(color: DSColor.onSurface15, width: 0.5),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodyMedium,
              fontWeight: DSFontWeight.medium,
              color: DSColor.onSurface75,
            ),
          ),
        ),
      ),
    );
  }
}
