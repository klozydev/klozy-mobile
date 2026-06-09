import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_address_field.dart';
import 'package:klozy/src/design/components/ds_address_suggestion.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_field_label.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/entity/address_input.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/profile_completion_bloc.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/profile_completion_event.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/profile_completion_state.dart';
import 'package:klozy/src/feature/onboarding/presentation/widget/avatar_upload_widget.dart';
import 'package:klozy/src/router/app_router.dart';

const _allSuggestions = <DSAddressSuggestion>[
  DSAddressSuggestion(main: 'Dubai Marina', sub: 'Dubai, United Arab Emirates'),
  DSAddressSuggestion(
    main: 'Jumeirah Beach Residence',
    sub: 'Dubai, United Arab Emirates',
  ),
  DSAddressSuggestion(
    main: 'Downtown Dubai',
    sub: 'Dubai, United Arab Emirates',
  ),
  DSAddressSuggestion(
    main: 'Al Reem Island',
    sub: 'Abu Dhabi, United Arab Emirates',
  ),
  DSAddressSuggestion(main: 'Al Nahda', sub: 'Sharjah, United Arab Emirates'),
];

@RoutePage()
class ProfileCompletionPage extends StatefulWidget implements AutoRouteWrapper {
  const ProfileCompletionPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<ProfileCompletionBloc>(
      create: (_) => locator<ProfileCompletionBloc>(),
      child: this,
    );
  }

  @override
  State<ProfileCompletionPage> createState() => _ProfileCompletionPageState();
}

class _ProfileCompletionPageState extends State<ProfileCompletionPage> {
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _bio = TextEditingController();
  DSAddressSuggestion? _picked;

  bool get _valid =>
      _firstName.text.trim().isNotEmpty &&
      _lastName.text.trim().isNotEmpty &&
      _picked != null;

  List<DSAddressSuggestion> get _suggestions {
    final q = _address.text.trim().toLowerCase();
    if (_picked != null && _address.text == _picked!.main) {
      return const <DSAddressSuggestion>[];
    }
    if (q.isEmpty) return _allSuggestions;
    return _allSuggestions
        .where(
          (s) =>
              s.main.toLowerCase().contains(q) ||
              s.sub.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _address.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _submit() {
    final picked = _picked;
    if (!_valid || picked == null) return;
    final city = picked.sub.split(',').first.trim();
    context.read<ProfileCompletionBloc>().add(
      ProfileCompletionSubmitted(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
        address: AddressInput(line1: picked.main, city: city, emirate: city),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCompletionBloc, ProfileCompletionState>(
      listener: (BuildContext context, ProfileCompletionState state) {
        if (state is ProfileCompletionDone) {
          context.router.push(SuccessRoute());
        } else if (state is ProfileCompletionFailure) {
          context.showSnackBar(state.message);
        }
      },
      builder: (BuildContext context, ProfileCompletionState state) {
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
                          context.l10N.onboarding_complete_profile_title,
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
                          context.l10N.onboarding_complete_profile_subtitle,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: DSFontSize.bodyLarge,
                            height: 1.57,
                            color: DSColor.onSurface60,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Center(child: AvatarUploadWidget()),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  DSFieldLabel(
                                    context.l10N.onboarding_first_name_label,
                                    required: true,
                                  ),
                                  DSTextField(
                                    controller: _firstName,
                                    hintText:
                                        context.l10N.onboarding_first_name_hint,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  DSFieldLabel(
                                    context.l10N.onboarding_last_name_label,
                                    required: true,
                                  ),
                                  DSTextField(
                                    controller: _lastName,
                                    hintText:
                                        context.l10N.onboarding_last_name_hint,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DSFieldLabel(
                          context.l10N.onboarding_address_label,
                          required: true,
                        ),
                        DSAddressField(
                          controller: _address,
                          suggestions: _suggestions,
                          selected: _picked != null,
                          onChanged: (_) => setState(() => _picked = null),
                          onPicked: (DSAddressSuggestion s) {
                            setState(() {
                              _picked = s;
                              _address.text = s.main;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        DSFieldLabel(
                          context.l10N.onboarding_bio_label,
                          suffix: Text(
                            context.l10N.onboarding_bio_char_count(
                              _bio.text.characters.length,
                              150,
                            ),
                            style: const TextStyle(
                              fontFamily: dsFontFamily,
                              fontSize: DSFontSize.bodySmall,
                              color: DSColor.onSurface35,
                            ),
                          ),
                        ),
                        DSTextField(
                          controller: _bio,
                          hintText: context.l10N.onboarding_bio_hint,
                          maxLines: 3,
                          maxLength: 150,
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ),
                DSBottomBar(
                  child: DSButtonElevated(
                    text: context.l10N.onboarding_continue,
                    isEnable: _valid,
                    isLoading: state is ProfileCompletionSubmitting,
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
}
