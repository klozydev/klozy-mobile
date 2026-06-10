import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/util/iban_validator.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_field_label.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/me_repository.dart';

@RoutePage()
class PayoutPage extends StatefulWidget {
  const PayoutPage({super.key});

  @override
  State<PayoutPage> createState() => _PayoutPageState();
}

class _PayoutPageState extends State<PayoutPage> {
  final MeRepository _repo = locator<MeRepository>();
  final TextEditingController _iban = TextEditingController();
  bool _saving = false;
  String? _currentMasked;

  @override
  void initState() {
    super.initState();
    _repo.getMe().then((me) {
      if (mounted) setState(() => _currentMasked = me.payoutIbanMasked);
    }).ignore();
  }

  @override
  void dispose() {
    _iban.dispose();
    super.dispose();
  }

  bool get _valid => isValidUaeIban(_iban.text);

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _repo.setPayoutIban(normalizeIban(_iban.text));
      if (mounted) {
        context.showSnackBar(context.l10N.settings_saved);
        context.router.maybePop();
      }
    } catch (_) {
      if (mounted) context.showSnackBar(context.l10N.settings_save_failed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10N;
    return Scaffold(
      backgroundColor: DSColor.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(l.settings_payout_iban),
      ),
      bottomNavigationBar: DSBottomBar(
        child: DSButtonElevated(
          text: l.settings_save,
          isEnable: _valid,
          isLoading: _saving,
          onPressed: _save,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: <Widget>[
          if (_currentMasked != null) ...<Widget>[
            Text(
              l.settings_iban_current(_currentMasked!),
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyMedium,
                color: DSColor.onSurface60,
              ),
            ),
            const SizedBox(height: 12),
          ],
          DSFieldLabel(l.settings_iban_label, required: true),
          DSTextField(
            controller: _iban,
            hintText: 'AE07 0331 2345 6789 0123 456',
            onChanged: (_) => setState(() {}),
            errorText: _iban.text.isNotEmpty && !_valid
                ? l.settings_iban_invalid
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            l.settings_iban_note,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodySmall,
              height: 1.4,
              color: DSColor.onSurface45,
            ),
          ),
        ],
      ),
    );
  }
}
