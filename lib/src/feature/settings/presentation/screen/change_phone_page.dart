import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_code_input.dart';
import 'package:klozy/src/design/components/ds_field_label.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/auth/auth_exception.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';
import 'package:klozy/src/feature/auth/presentation/bloc/auth_error_reason_l10n.dart';

/// Change-phone subpage (Settings › Security). Two steps: enter the new number
/// → Firebase SMS verification → enter the 6-digit code → `updatePhoneNumber`.
@RoutePage()
class ChangePhonePage extends StatefulWidget {
  const ChangePhonePage({super.key});

  @override
  State<ChangePhonePage> createState() => _ChangePhonePageState();
}

class _ChangePhonePageState extends State<ChangePhonePage> {
  final AuthRepository _auth = locator<AuthRepository>();
  final TextEditingController _number = TextEditingController();

  bool _busy = false;
  String? _verificationId;
  String _fullNumber = '';
  String _code = '';

  bool get _numberValid => _number.text.trim().length >= 6;

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_numberValid) return;
    final String full =
        '+971${_number.text.trim().replaceAll(RegExp(r'\s+'), '')}';
    setState(() => _busy = true);
    try {
      final verification = await _auth.startPhoneVerification(full);
      if (mounted) {
        setState(() {
          _verificationId = verification.verificationId;
          _fullNumber = full;
        });
      }
    } on AuthException catch (e) {
      if (mounted) context.showSnackBar(e.reason.message(context.l10N));
    } catch (_) {
      if (mounted) context.showSnackBar(context.l10N.settings_save_failed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    if (_code.length != 6 || _verificationId == null) return;
    setState(() => _busy = true);
    try {
      await _auth.updatePhoneNumber(
        verificationId: _verificationId!,
        smsCode: _code,
      );
      if (mounted) {
        context.showSnackBar(context.l10N.settings_phone_updated);
        context.router.maybePop();
      }
    } on AuthException catch (e) {
      if (mounted) context.showSnackBar(e.reason.message(context.l10N));
    } catch (_) {
      if (mounted) context.showSnackBar(context.l10N.settings_save_failed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool codeStep = _verificationId != null;
    return Scaffold(
      backgroundColor: DSColor.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () {
            if (codeStep) {
              setState(() {
                _verificationId = null;
                _code = '';
              });
            } else {
              context.router.maybePop();
            }
          },
        ),
        title: Text(context.l10N.settings_phone_number),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(DSSpacing.s),
                children: codeStep ? _codeStep(context) : _numberStep(context),
              ),
            ),
            DSBottomBar(
              child: DSButtonElevated(
                text: codeStep
                    ? context.l10N.auth_verify
                    : context.l10N.auth_send_code,
                isEnable: codeStep ? _code.length == 6 : _numberValid,
                isLoading: _busy,
                onPressed: codeStep ? _verify : _sendCode,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _numberStep(BuildContext context) {
    final String? current = _auth.currentUser?.phoneNumber;
    return <Widget>[
      if (current != null && current.isNotEmpty)
        Container(
          padding: const EdgeInsets.all(DSSpacing.xs),
          decoration: BoxDecoration(
            color: DSColor.card,
            borderRadius: BorderRadius.circular(DSBorderRadius.cardSmall),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                context.l10N.settings_current_number,
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodySmall,
                  color: DSColor.onSurface45,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                current,
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodyLarge,
                  fontWeight: DSFontWeight.semiBold,
                  color: DSColor.onSurface,
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: DSSpacing.s),
      DSFieldLabel(context.l10N.settings_new_number, required: true),
      Row(
        children: <Widget>[
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xs),
            decoration: BoxDecoration(
              color: DSColor.card,
              borderRadius: BorderRadius.circular(DSBorderRadius.input),
              border: Border.all(color: DSColor.onSurface15, width: 0.5),
            ),
            alignment: Alignment.center,
            child: const Text(
              '+971',
              style: TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyLarge,
                fontWeight: DSFontWeight.semiBold,
                color: DSColor.onSurface,
              ),
            ),
          ),
          const SizedBox(width: DSSpacing.xs),
          Expanded(
            child: DSTextField(
              controller: _number,
              hintText: context.l10N.settings_new_number_hint,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
      const SizedBox(height: DSSpacing.s),
      Text(
        context.l10N.settings_phone_note,
        style: const TextStyle(
          fontFamily: dsFontFamily,
          fontSize: DSFontSize.bodySmall,
          height: 1.4,
          color: DSColor.onSurface35,
        ),
      ),
    ];
  }

  List<Widget> _codeStep(BuildContext context) {
    return <Widget>[
      Text(
        context.l10N.settings_enter_code_for(_fullNumber),
        style: const TextStyle(
          fontFamily: dsFontFamily,
          fontSize: DSFontSize.bodyLarge,
          color: DSColor.onSurface60,
        ),
      ),
      const SizedBox(height: DSSpacing.l),
      DSCodeInput(
        onChanged: (String value) => setState(() => _code = value),
        onCompleted: (_) => _verify(),
      ),
    ];
  }
}
