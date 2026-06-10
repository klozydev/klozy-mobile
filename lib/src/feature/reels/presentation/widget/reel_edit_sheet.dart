import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';

/// Edit a reel's caption. Pops with the new caption, or null when cancelled.
class ReelEditSheet extends StatefulWidget {
  final String? caption;

  const ReelEditSheet({super.key, this.caption});

  @override
  State<ReelEditSheet> createState() => _ReelEditSheetState();
}

class _ReelEditSheetState extends State<ReelEditSheet> {
  late final TextEditingController _caption = TextEditingController(
    text: widget.caption ?? '',
  );

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DSTextField(
          controller: _caption,
          autofocus: true,
          hintText: context.l10N.reels_caption_hint,
          maxLines: 3,
          maxLength: 300,
        ),
        const SizedBox(height: 16),
        DSButtonElevated(
          text: context.l10N.settings_save,
          onPressed: () => Navigator.of(context).pop(_caption.text.trim()),
        ),
      ],
    );
  }
}
