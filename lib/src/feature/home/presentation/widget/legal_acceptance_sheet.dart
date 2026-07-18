import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/navigation/safe_navigation.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/config/entity/legal_doc.dart';
import 'package:klozy/src/domain/config/public_config_repository.dart';
import 'package:klozy/src/router/app_router.dart';

/// Shown when legal documents need (re-)acceptance. Pops after accepting.
class LegalAcceptanceSheet extends StatefulWidget {
  final List<LegalDoc> docs;

  const LegalAcceptanceSheet({super.key, required this.docs});

  @override
  State<LegalAcceptanceSheet> createState() => _LegalAcceptanceSheetState();
}

class _LegalAcceptanceSheetState extends State<LegalAcceptanceSheet> {
  bool _busy = false;

  Future<void> _acceptAll() async {
    setState(() => _busy = true);
    final repo = locator<PublicConfigRepository>();
    try {
      for (final LegalDoc doc in widget.docs) {
        await repo.acceptLegal(doc.key);
      }
      if (mounted) Navigator.of(context).maybePop();
    } catch (_) {
      if (mounted) {
        context.showSnackBar(context.l10N.settings_save_failed);
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.l10N.legal_pending_message,
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: DSFontSize.bodyMedium,
            height: 1.45,
            color: DSColor.onSurface60,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.docs.map(
          (LegalDoc doc) => InkWell(
            onTap: () =>
                context.router.pushSafe(LegalDocRoute(docKey: doc.key)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.description_outlined,
                    size: 18,
                    color: DSColor.onSurface60,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      doc.name,
                      style: const TextStyle(
                        fontFamily: dsFontFamily,
                        fontSize: DSFontSize.bodyLarge,
                        fontWeight: DSFontWeight.medium,
                        color: DSColor.onSurface,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: DSColor.onSurface35,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        DSButtonElevated(
          text: context.l10N.legal_accept_continue,
          isLoading: _busy,
          onPressed: _acceptAll,
        ),
      ],
    );
  }
}
