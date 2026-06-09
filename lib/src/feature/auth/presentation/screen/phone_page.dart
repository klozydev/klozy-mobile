import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:klozy/src/feature/auth/presentation/bloc/auth_event.dart';
import 'package:klozy/src/feature/auth/presentation/bloc/auth_state.dart';
import 'package:klozy/src/router/app_router.dart';

@RoutePage()
class PhonePage extends StatefulWidget implements AutoRouteWrapper {
  const PhonePage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => locator<AuthBloc>(),
      child: this,
    );
  }

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  final TextEditingController _controller = TextEditingController();

  String get _digits => _controller.text.replaceAll(RegExp(r'\D'), '');
  bool get _valid => _digits.length >= 8;
  String get _e164 => '+971${_digits.replaceFirst(RegExp('^0+'), '')}';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                        Text(
                          context.l10N.auth_phone_title,
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
                          context.l10N.auth_phone_subtitle,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: DSFontSize.bodyLarge,
                            height: 1.43,
                            color: DSColor.onSurface60,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: <Widget>[
                            Container(
                              height: 52,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: DSColor.card,
                                borderRadius: BorderRadius.circular(
                                  DSBorderRadius.input,
                                ),
                                border: Border.all(color: DSColor.onSurface15),
                              ),
                              child: const Row(
                                children: <Widget>[
                                  Text('🇦🇪', style: TextStyle(fontSize: 18)),
                                  SizedBox(width: 8),
                                  Text(
                                    '+971',
                                    style: TextStyle(
                                      fontFamily: dsFontFamily,
                                      fontSize: DSFontSize.bodyLarge,
                                      fontWeight: DSFontWeight.semiBold,
                                      color: DSColor.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DSTextField(
                                controller: _controller,
                                hintText: context.l10N.auth_phone_number_hint,
                                autofocus: true,
                                keyboardType: TextInputType.phone,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[\d\s]'),
                                  ),
                                ],
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          context.l10N.auth_phone_disclaimer,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: DSFontSize.bodyMedium,
                            height: 1.38,
                            color: DSColor.onSurface45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DSBottomBar(
                  child: DSButtonElevated(
                    text: context.l10N.auth_send_code,
                    isLoading: state is AuthLoading,
                    isEnable: _valid,
                    onPressed: () =>
                        context.read<AuthBloc>().add(AuthPhoneStarted(_e164)),
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
    if (state is AuthCodeSent) {
      context.router.push(
        OtpRoute(
          verificationId: state.verification.verificationId,
          destination: state.destination,
          isEmail: false,
        ),
      );
    } else if (state is AuthFailure) {
      context.showSnackBar(state.message);
    }
  }
}
