import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/util/iban_validator.dart';
import 'package:klozy/src/core/utils/upper_case_text_formatter.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_field_label.dart';
import 'package:klozy/src/design/components/ds_option_card.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/sell/usecase/check_sell_prerequisite_usecase.dart';
import 'package:klozy/src/domain/sell/usecase/sell_prerequisite.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/seller_role_bloc.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/seller_role_event.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/seller_role_state.dart';
import 'package:klozy/src/router/app_router.dart';

@RoutePage()
class SellerRolePage extends StatefulWidget implements AutoRouteWrapper {
  const SellerRolePage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<SellerRoleBloc>(
      create: (_) => locator<SellerRoleBloc>(),
      child: this,
    );
  }

  @override
  State<SellerRolePage> createState() => _SellerRolePageState();
}

class _SellerRolePageState extends State<SellerRolePage> {
  final TextEditingController _iban = TextEditingController();
  SellerRole? _role;

  String get _cleanIban => normalizeIban(_iban.text);
  bool get _valid =>
      _role == SellerRole.vendor ||
      (_role == SellerRole.particular && isValidUaeIban(_iban.text));

  @override
  void dispose() {
    _iban.dispose();
    super.dispose();
  }

  void _submit() {
    final role = _role;
    if (role == null || !_valid) return;
    context.read<SellerRoleBloc>().add(
      SellerRoleSubmitted(
        role: role,
        iban: role == SellerRole.particular ? _cleanIban : null,
      ),
    );
  }

  /// After the seller role is saved, resolve what's still required and replace
  /// this screen with that step directly (verification for vendors, payout for
  /// particulars, etc.) instead of popping back with an alert.
  Future<void> _continueAfterRole(BuildContext context) async {
    final SellPrerequisite next =
        await locator<CheckSellPrerequisiteUseCase>()();
    if (!context.mounted) return;
    switch (next) {
      case SellPrerequisite.needsAddress:
        context.router.replace(AddressFormRoute(requirePhone: true));
      case SellPrerequisite.needsIban:
        context.router.replace(const PayoutRoute());
      case SellPrerequisite.needsKyb:
        context.router.replace(const SellerVerificationRoute());
      case SellPrerequisite.ready:
        context.router.replace(const SellRoute());
      case SellPrerequisite.needsRole:
        context.router.maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SellerRoleBloc, SellerRoleState>(
      listener: (BuildContext context, SellerRoleState state) {
        if (state is SellerRoleDone) {
          // Don't bounce back with a "account set up" alert — take the seller
          // straight to the next required step (verification / payout / etc).
          _continueAfterRole(context);
        } else if (state is SellerRoleFailure) {
          context.showSnackBar(state.message);
        }
      },
      builder: (BuildContext context, SellerRoleState state) {
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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          context.l10N.onboarding_seller_role_title,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: DSFontSize.headlineLarge,
                            fontWeight: DSFontWeight.bold,
                            letterSpacing: -0.4,
                            color: DSColor.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10N.onboarding_seller_role_subtitle,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: DSFontSize.bodyLarge,
                            height: 1.57,
                            color: DSColor.onSurface60,
                          ),
                        ),
                        const SizedBox(height: 24),
                        DSOptionCard(
                          icon: Icons.person_outline_rounded,
                          title: context.l10N.onboarding_private_seller_title,
                          badge: context.l10N.onboarding_private_seller_badge,
                          description: context
                              .l10N
                              .onboarding_private_seller_description,
                          selected: _role == SellerRole.particular,
                          onTap: () =>
                              setState(() => _role = SellerRole.particular),
                        ),
                        if (_role == SellerRole.particular)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                DSFieldLabel(
                                  context.l10N.onboarding_payout_iban_label,
                                  required: true,
                                ),
                                DSTextField(
                                  controller: _iban,
                                  hintText: 'AE00 0000 0000 0000 0000',
                                  prefixIcon: Icons.credit_card_outlined,
                                  inputFormatters: const <TextInputFormatter>[
                                    UpperCaseTextFormatter(),
                                  ],
                                  onChanged: (_) => setState(() {}),
                                ),
                                const SizedBox(height: 8),
                                _shieldNote(
                                  context.l10N.onboarding_iban_shield_note,
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        DSOptionCard(
                          icon: Icons.storefront_outlined,
                          title: context.l10N.onboarding_pro_vendor_title,
                          badge: context.l10N.onboarding_pro_vendor_badge,
                          description:
                              context.l10N.onboarding_pro_vendor_description,
                          selected: _role == SellerRole.vendor,
                          onTap: () =>
                              setState(() => _role = SellerRole.vendor),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: DSColor.onSurface05,
                            borderRadius: BorderRadius.circular(
                              DSBorderRadius.cardSmall,
                            ),
                            border: Border.all(
                              color: DSColor.onSurface07,
                              width: 0.5,
                            ),
                          ),
                          child: _shieldNote(
                            context.l10N.onboarding_buyer_protection_note,
                            size: DSFontSize.bodyMedium,
                            color: DSColor.onSurface60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DSBottomBar(
                  child: DSButtonElevated(
                    text: context.l10N.onboarding_continue,
                    isEnable: _valid,
                    isLoading: state is SellerRoleSubmitting,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _shieldNote(
    String text, {
    double size = DSFontSize.bodySmall,
    Color color = DSColor.onSurface45,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(Icons.shield_outlined, size: 16, color: DSColor.primary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: dsFontFamily,
              fontSize: size,
              height: 1.4,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
