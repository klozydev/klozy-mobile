import 'package:flutter/material.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

class ProfileTabEmpty extends StatelessWidget {
  final IconData icon;
  final String label;

  const ProfileTabEmpty({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 36, color: DSColor.onSurface35),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodyMedium,
              color: DSColor.onSurface45,
            ),
          ),
        ],
      ),
    );
  }
}
