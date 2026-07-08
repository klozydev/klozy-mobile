import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
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

final _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// Change-email subpage (Settings › Security). Sends a Firebase confirmation
/// link to the new address; the change applies only once the user clicks it.
@RoutePage()
class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final AuthRepository _auth = locator<AuthRepository>();
  final TextEditingController _email = TextEditingController();
  bool _saving = false;

  String get _value => _email.text.trim();
  bool get _valid => _emailRegExp.hasMatch(_value);

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_valid) return;
    setState(() => _saving = true);
    try {
      await _auth.sendEmailUpdateVerification(_value);
      if (mounted) {
        context.showSnackBar(context.l10N.settings_email_link_sent);
        context.router.maybePop();
      }
    } on AuthException catch (e) {
      if (mounted) context.showSnackBar(e.reason.message(context.l10N));
    } catch (_) {
      if (mounted) context.showSnackBar(context.l10N.settings_save_failed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? current = _auth.currentUser?.email;
    return Scaffold(
      backgroundColor: DSColor.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(context.l10N.settings_change_email),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(DSSpacing.s),
                children: <Widget>[
                  if (current != null && current.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(DSSpacing.xs),
                      decoration: BoxDecoration(
                        color: DSColor.card,
                        borderRadius: BorderRadius.circular(
                          DSBorderRadius.cardSmall,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            context.l10N.settings_current_email,
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
                  DSFieldLabel(context.l10N.settings_new_email, required: true),
                  DSTextField(
                    controller: _email,
                    hintText: context.l10N.settings_new_email_hint,
                    prefixIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => setState(() {}),
                    errorText: _value.isNotEmpty && !_valid
                        ? context.l10N.auth_email_invalid
                        : null,
                  ),
                  const SizedBox(height: DSSpacing.s),
                  Text(
                    context.l10N.settings_change_email_note,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodySmall,
                      height: 1.4,
                      color: DSColor.onSurface35,
                    ),
                  ),
                ],
              ),
            ),
            DSBottomBar(
              child: DSButtonElevated(
                text: context.l10N.settings_save,
                isEnable: _valid,
                isLoading: _saving,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
