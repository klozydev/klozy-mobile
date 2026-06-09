import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';

/// Four-bar password strength meter with a label. Score: +1 length ≥ 8, +1
/// mixed case, +1 digit, +1 symbol. Hidden when [password] is empty. Mirrors
/// the prototype `PasswordStrength`.
class DSPasswordStrength extends StatelessWidget {
  final String password;

  const DSPasswordStrength(this.password, {super.key});

  static const Color _fair = Color(0xFFE0A24D);
  static const Color _good = Color(0xFFC9D07D);

  int get _score {
    if (password.isEmpty) return 0;
    var score = 0;
    if (password.length >= 8) score++;
    if (RegExp('[a-z]').hasMatch(password) &&
        RegExp('[A-Z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp('[^A-Za-z0-9]').hasMatch(password)) score++;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    final int score = _score;
    if (score == 0) return const SizedBox.shrink();

    final labels = <String>[
      '',
      context.l10N.ds_password_strength_weak,
      context.l10N.ds_password_strength_fair,
      context.l10N.ds_password_strength_good,
      context.l10N.ds_password_strength_strong,
    ];
    const colors = <Color>[
      DSColor.onSurface10,
      DSColor.danger,
      _fair,
      _good,
      DSColor.primary,
    ];
    final Color color = colors[score];

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < 4; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == 3 ? 0 : 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 3,
                  decoration: BoxDecoration(
                    color: i < score ? color : DSColor.onSurface10,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 10),
          SizedBox(
            width: 38,
            child: Text(
              labels[score],
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodySmall,
                fontWeight: DSFontWeight.semiBold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
