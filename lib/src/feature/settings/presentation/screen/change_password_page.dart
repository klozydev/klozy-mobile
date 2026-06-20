import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_field_label.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/auth/auth_exception.dart';
import 'package:klozy/src/domain/auth/auth_repository.dart';

/// Settings › Security › Change password — an in-app form (new + confirm
/// password) that sets the password directly via Firebase, matching the design
/// (the previous flow only emailed a reset link).
@RoutePage()
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _saving = false;

  static const int _minLength = 8;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _longEnough => _password.text.length >= _minLength;
  bool get _matches => _confirm.text == _password.text;
  bool get _valid => _longEnough && _matches && _confirm.text.isNotEmpty;

  Future<void> _save() async {
    if (!_valid) return;
    setState(() => _saving = true);
    try {
      await locator<AuthRepository>().updatePassword(_password.text);
      if (mounted) {
        context.showSnackBar(context.l10N.settings_password_updated);
        context.router.maybePop();
      }
    } on AuthException catch (e) {
      if (mounted) context.showSnackBar(e.message);
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
        title: Text(l.settings_change_password),
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
          DSFieldLabel(l.settings_new_password),
          const SizedBox(height: 8),
          DSTextField(
            controller: _password,
            obscureText: true,
            prefixIcon: Icons.lock_outline_rounded,
            hintText: l.settings_new_password_hint,
            onChanged: (_) => setState(() {}),
            errorText: _password.text.isNotEmpty && !_longEnough
                ? l.settings_password_too_short
                : null,
          ),
          const SizedBox(height: 16),
          DSFieldLabel(l.settings_confirm_password),
          const SizedBox(height: 8),
          DSTextField(
            controller: _confirm,
            obscureText: true,
            prefixIcon: Icons.lock_outline_rounded,
            hintText: l.settings_confirm_password_hint,
            onChanged: (_) => setState(() {}),
            errorText: _confirm.text.isNotEmpty && !_matches
                ? l.settings_passwords_no_match
                : null,
          ),
        ],
      ),
    );
  }
}
