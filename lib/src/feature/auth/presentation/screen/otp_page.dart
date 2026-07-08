import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/app/bloc/account/account_bloc.dart';
import 'package:klozy/src/app/bloc/account/account_event.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_code_input.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:klozy/src/feature/auth/presentation/bloc/auth_error_reason_l10n.dart';
import 'package:klozy/src/feature/auth/presentation/bloc/auth_event.dart';
import 'package:klozy/src/feature/auth/presentation/bloc/auth_state.dart';
import 'package:klozy/src/router/app_router.dart';

@RoutePage()
class OtpPage extends StatefulWidget implements AutoRouteWrapper {
  final String verificationId;
  final String destination;
  final bool isEmail;

  const OtpPage({
    super.key,
    required this.verificationId,
    required this.destination,
    this.isEmail = false,
  });

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => locator<AuthBloc>(),
      child: this,
    );
  }

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  late String _verificationId = widget.verificationId;
  String _code = '';
  int _seconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _seconds = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (_seconds <= 1) {
        t.cancel();
        setState(() => _seconds = 0);
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _verify() {
    if (_code.length != 6) return;
    context.read<AuthBloc>().add(
      AuthPhoneCodeSubmitted(verificationId: _verificationId, smsCode: _code),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: _listener,
      builder: (BuildContext context, AuthState state) {
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
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0x1AE0CE7D),
                            borderRadius: BorderRadius.circular(
                              DSBorderRadius.input,
                            ),
                            border: Border.all(
                              color: const Color(0x40E0CE7D),
                              width: 0.5,
                            ),
                          ),
                          child: Icon(
                            widget.isEmail
                                ? Icons.mail_outline_rounded
                                : Icons.phone_outlined,
                            size: 26,
                            color: DSColor.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          context.l10N.auth_enter_code_title,
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
                        Text.rich(
                          TextSpan(
                            text: context.l10N.auth_code_sent_to,
                            style: const TextStyle(
                              fontFamily: dsFontFamily,
                              fontSize: DSFontSize.bodyLarge,
                              height: 1.43,
                              color: DSColor.onSurface60,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: widget.destination,
                                style: const TextStyle(
                                  fontWeight: DSFontWeight.semiBold,
                                  color: DSColor.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        DSCodeInput(
                          onChanged: (String value) =>
                              setState(() => _code = value),
                          onCompleted: (_) => _verify(),
                        ),
                        const SizedBox(height: 22),
                        Center(
                          child: _seconds > 0
                              ? Text(
                                  context.l10N.auth_resend_code_in(
                                    '0:${_seconds.toString().padLeft(2, '0')}',
                                  ),
                                  style: const TextStyle(
                                    fontFamily: dsFontFamily,
                                    fontSize: DSFontSize.bodyMedium,
                                    color: DSColor.onSurface35,
                                  ),
                                )
                              : TextButton(
                                  onPressed: () => context.read<AuthBloc>().add(
                                    AuthPhoneStarted(widget.destination),
                                  ),
                                  child: Text(
                                    context.l10N.auth_resend_code,
                                    style: const TextStyle(
                                      fontFamily: dsFontFamily,
                                      fontSize: DSFontSize.bodyMedium,
                                      fontWeight: DSFontWeight.semiBold,
                                      color: DSColor.primary,
                                    ),
                                  ),
                                ),
                        ),
                        if (widget.isEmail)
                          Padding(
                            padding: const EdgeInsets.only(top: 18),
                            child: Text(
                              context.l10N.auth_code_spam_hint,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: dsFontFamily,
                                fontSize: DSFontSize.bodySmall,
                                height: 1.36,
                                color: DSColor.onSurface24,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                DSBottomBar(
                  child: DSButtonElevated(
                    text: context.l10N.auth_verify,
                    isLoading: state is AuthLoading,
                    isEnable: _code.length == 6,
                    onPressed: _verify,
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
      // Resolve the global account session straight from the auth result (the
      // singleton AccountBloc still holds the pre-auth guest status). We pass
      // the known onboarding flag rather than re-resolving: a fresh signup's
      // backend profile can momentarily 404, which the resolver maps to legacy
      // → silent sign-out → the guest "login / sign up" placeholder.
      context.read<AccountBloc>().add(
        AccountAuthenticated(onboardingComplete: state.onboardingComplete),
      );
      // Always land on home after a verified sign-in; profile completion is
      // on-demand now (no forced personalize/complete-profile step).
      context.router.replaceAll(<PageRouteInfo>[const ShellRoute()]);
    } else if (state is AuthCodeSent) {
      setState(() => _verificationId = state.verification.verificationId);
      _startCountdown();
      context.showSnackBar(context.l10N.auth_new_code_sent);
    } else if (state is AuthFailure) {
      context.showSnackBar(state.reason.message(context.l10N));
    }
  }
}
