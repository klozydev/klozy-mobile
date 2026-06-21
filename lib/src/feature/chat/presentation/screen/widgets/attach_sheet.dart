import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/attach_choice.dart';

/// Grid of attachment options. Pops the chosen [AttachChoice].
class AttachSheet extends StatelessWidget {
  const AttachSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.92,
        children: <Widget>[
          _AttachOption(
            icon: Icons.photo_library_outlined,
            label: context.l10N.chat_attach_photo,
            onTap: () => Navigator.of(context).pop(AttachChoice.photo),
          ),
          _AttachOption(
            icon: Icons.photo_camera_outlined,
            label: context.l10N.chat_attach_camera,
            onTap: () => Navigator.of(context).pop(AttachChoice.camera),
          ),
          _AttachOption(
            icon: Icons.library_music_outlined,
            label: context.l10N.chat_attach_audio,
            onTap: () => Navigator.of(context).pop(AttachChoice.audio),
          ),
          _AttachOption(
            icon: Icons.insert_drive_file_outlined,
            label: context.l10N.chat_attach_document,
            onTap: () => Navigator.of(context).pop(AttachChoice.document),
          ),
        ],
      ),
    );
  }
}

class _AttachOption extends StatelessWidget {
  const _AttachOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: DSColor.brandGlow,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: DSColor.primary.withValues(alpha: 0.22),
                width: 0.5,
              ),
            ),
            child: Icon(icon, color: DSColor.primary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodySmall,
              fontWeight: DSFontWeight.medium,
              color: DSColor.onSurface75,
            ),
          ),
        ],
      ),
    );
  }
}
