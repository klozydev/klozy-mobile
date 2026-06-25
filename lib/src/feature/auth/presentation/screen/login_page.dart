import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/app/bloc/account/account_bloc.dart';
import 'package:klozy/src/app/bloc/account/account_event.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_google_glyph.dart';
import 'package:klozy/src/design/components/ds_or_divider.dart';
import 'package:klozy/src/design/components/ds_password_strength.dart';
import 'package:klozy/src/design/components/ds_segmented_control.dart';
import 'package:klozy/src/design/components/ds_social_button.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:klozy/src/feature/auth/presentation/bloc/auth_event.dart';
import 'package:klozy/src/feature/auth/presentation/bloc/auth_state.dart';
import 'package:klozy/src/router/app_router.dart';

final _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

@RoutePage()
class LoginPage extends StatefulWidget implements AutoRouteWrapper {
  final bool isSignUp;

  const LoginPage({super.key, this.isSignUp = true});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => locator<AuthBloc>(),
      child: this,
    );
  }

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late bool _isSignUp = widget.isSignUp;
  bool _obscure = true;

  String get _email => _emailController.text.trim();
  String get _password => _passwordController.text;
  bool get _emailValid => _emailRegExp.hasMatch(_email);
  bool get _canSubmit => _emailValid && _password.length >= (_isSignUp ? 8 : 1);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_canSubmit) return;
    context.read<AuthBloc>().add(
      AuthEmailSubmitted(
        email: _email,
        password: _password,
        isSignUp: _isSignUp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: _listener,
      builder: (BuildContext context, AuthState state) {
        final bool loading = state is AuthLoading;
        return Scaffold(
          backgroundColor: DSColor.surface,
          appBar: AppBar(
            leadingWidth: 56,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 22),
              onPressed: () => context.router.maybePop(),
            ),
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _isSignUp
                              ? context.l10N.auth_create_account_title
                              : context.l10N.auth_welcome_back_title,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: 26,
                            height: 1.23,
                            fontWeight: DSFontWeight.bold,
                            letterSpacing: -0.52,
                            color: DSColor.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isSignUp
                              ? context.l10N.auth_create_account_subtitle
                              : context.l10N.auth_welcome_back_subtitle,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: DSFontSize.bodyLarge,
                            height: 1.43,
                            color: DSColor.onSurface60,
                          ),
                        ),
                        const SizedBox(height: 24),
                        DSSegmentedControl(
                          labels: <String>[
                            context.l10N.auth_sign_up,
                            context.l10N.auth_log_in,
                          ],
                          selectedIndex: _isSignUp ? 0 : 1,
                          onChanged: (int i) =>
                              setState(() => _isSignUp = i == 0),
                        ),
                        const SizedBox(height: 16),
                        DSTextField(
                          controller: _emailController,
                          hintText: context.l10N.auth_email_hint,
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => setState(() {}),
                          errorText: _email.isNotEmpty && !_emailValid
                              ? context.l10N.auth_email_invalid
                              : null,
                        ),
                        const SizedBox(height: 12),
                        DSTextField(
                          controller: _passwordController,
                          hintText: context.l10N.auth_password_hint,
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscure,
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _submit(),
                          trailing: GestureDetector(
                            onTap: () => setState(() => _obscure = !_obscure),
                            child: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                              color: DSColor.onSurface45,
                            ),
                          ),
                        ),
                        if (_isSignUp) DSPasswordStrength(_password),
                        if (!_isSignUp)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _email.isEmpty
                                  ? null
                                  : () => context.read<AuthBloc>().add(
                                      AuthPasswordResetRequested(_email),
                                    ),
                              child: Text(
                                context.l10N.auth_forgot_password,
                                style: const TextStyle(
                                  fontFamily: dsFontFamily,
                                  fontSize: DSFontSize.bodyMedium,
                                  fontWeight: DSFontWeight.medium,
                                  color: DSColor.primary,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        DSOrDivider(label: context.l10N.auth_or_continue_with),
                        const SizedBox(height: 16),
                        DSSocialButton(
                          icon: const Icon(
                            Icons.apple,
                            size: 21,
                            color: DSColor.onSurface,
                          ),
                          label: context.l10N.auth_continue_apple,
                          onPressed: () => context.read<AuthBloc>().add(
                            const AuthApplePressed(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        DSSocialButton(
                          icon: const DSGoogleGlyph(),
                          label: context.l10N.auth_continue_google,
                          onPressed: () => context.read<AuthBloc>().add(
                            const AuthGooglePressed(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        DSSocialButton(
                          icon: const Icon(
                            Icons.phone_outlined,
                            size: 18,
                            color: DSColor.onSurface,
                          ),
                          label: context.l10N.auth_continue_phone,
                          onPressed: () =>
                              context.router.push(const PhoneRoute()),
                        ),
                      ],
                    ),
                  ),
                ),
                DSBottomBar(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text.rich(
                          TextSpan(
                            text: context.l10N.auth_terms_prefix,
                            children: <TextSpan>[
                              TextSpan(
                                text: context.l10N.auth_terms,
                                style: const TextStyle(
                                  color: DSColor.onSurface60,
                                ),
                              ),
                              TextSpan(text: context.l10N.auth_terms_and),
                              TextSpan(
                                text: context.l10N.auth_privacy_policy,
                                style: const TextStyle(
                                  color: DSColor.onSurface60,
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                            style: const TextStyle(
                              fontFamily: dsFontFamily,
                              fontSize: DSFontSize.bodySmall,
                              height: 1.45,
                              color: DSColor.onSurface35,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      DSButtonElevated(
                        text: _isSignUp
                            ? context.l10N.auth_create_account_button
                            : context.l10N.auth_log_in,
                        isLoading: loading,
                        isEnable: _canSubmit,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _listener(BuildContext context, AuthState state) {
    if (state is AuthSuccess) {
      // Re-resolve the global account session now that we're signed in — the
      // singleton AccountBloc still holds the pre-auth (guest) status, so the
      // shell's Chat / Profile tabs would otherwise render the guest/login
      // placeholder until a hot restart. Bootstrapping first makes them resolve
      // to incompleteOnboarding/valid.
      context.read<AccountBloc>().add(const AccountBootstrapRequested());
      // Go straight home after auth — profile completion is no longer forced
      // up front; it's requested on-demand by the actions that need it
      // (e.g. the seller address gate).
      context.router.replaceAll(<PageRouteInfo>[const ShellRoute()]);
    } else if (state is AuthFailure) {
      context.showSnackBar(state.message);
    } else if (state is AuthPasswordResetSent) {
      context.showSnackBar(context.l10N.auth_password_reset_sent);
    }
  }
}
