import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';

class ReportProblemSheet extends StatefulWidget {
  const ReportProblemSheet({super.key});

  @override
  State<ReportProblemSheet> createState() => _ReportProblemSheetState();
}

class _ReportProblemSheetState extends State<ReportProblemSheet> {
  final TextEditingController _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DSTextField(
          controller: _reason,
          autofocus: true,
          hintText: context.l10N.orders_report_problem_hint,
          maxLines: 4,
          maxLength: 500,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        DSButtonElevated(
          text: context.l10N.orders_submit_report,
          isEnable: _reason.text.trim().isNotEmpty,
          onPressed: () => Navigator.of(context).pop(_reason.text.trim()),
        ),
      ],
    );
  }
}
