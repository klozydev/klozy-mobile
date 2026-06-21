import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';

/// Centered "purchase confirmed" pill rendered inline in the thread.
///
/// Sage-tinted background with the product name emphasised in bold white and
/// the paid amount appended in Dhs.
class PurchasePill extends StatelessWidget {
  const PurchasePill({super.key, required this.message});

  final ChatMessage message;

  String _formatAmount(num n) =>
      n == n.roundToDouble() ? n.toInt().toString() : n.toString();

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width * 0.9;
    final String productName = message.purchase?.productName ?? '';
    final String amount = _formatAmount(message.purchase?.amount ?? 0);

    final TextStyle baseStyle = TextStyle(
      fontFamily: dsFontFamily,
      fontSize: 13,
      fontWeight: DSFontWeight.medium,
      height: 17 / 13,
      color: Colors.white.withValues(alpha: 0.75),
    );

    return Center(
      child: Container(
        width: width,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: DSColor.chatPositiveBg,
          border: Border.all(color: DSColor.chatPositiveBorder, width: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text.rich(
          TextSpan(
            style: baseStyle,
            children: <InlineSpan>[
              TextSpan(text: '✓ ${context.l10N.chat_purchase_confirmed} · '),
              TextSpan(
                text: productName,
                style: baseStyle.copyWith(
                  fontWeight: DSFontWeight.semiBold,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text:
                    ' ${context.l10N.chat_purchase_for} $amount ${context.l10N.chat_currency}',
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
