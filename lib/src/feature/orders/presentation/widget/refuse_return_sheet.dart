import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

/// Seller's mandatory reason for refusing a return, modeled on
/// `ReportProblemSheet`. The reason is required: Confirm stays disabled and a
/// validation hint is shown while the field is empty, so the sheet never
/// pops with an empty reason.
class RefuseReturnSheet extends StatefulWidget {
  const RefuseReturnSheet({super.key});

  @override
  State<RefuseReturnSheet> createState() => _RefuseReturnSheetState();
}

class _RefuseReturnSheetState extends State<RefuseReturnSheet> {
  final TextEditingController _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = _reason.text.trim().isEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DSTextField(
          controller: _reason,
          autofocus: true,
          hintText: context.l10N.orders_refuse_return_hint,
          maxLines: 4,
          maxLength: 500,
          onChanged: (_) => setState(() {}),
        ),
        if (isEmpty) ...<Widget>[
          const SizedBox(height: DSSpacing.xxxs),
          Text(
            context.l10N.orders_refuse_return_error,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodySmall,
              color: DSColor.danger,
            ),
          ),
        ],
        const SizedBox(height: DSSpacing.s),
        DSButtonElevated(
          text: context.l10N.orders_dialog_confirm,
          isEnable: !isEmpty,
          onPressed: () => Navigator.of(context).pop(_reason.text.trim()),
        ),
      ],
    );
  }
}
