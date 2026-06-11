import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/core/components/avatar_upload_widget.dart';
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
import 'package:klozy/src/domain/places/entity/place_details.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/profile_completion_bloc.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/profile_completion_event.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/profile_completion_state.dart';
import 'package:klozy/src/router/app_router.dart';

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

  /// Parallel lists: suggestions shown in the dropdown and their placeIds.
  List<DSAddressSuggestion> _suggestions = const [];
  List<String> _placeIds = const [];

  /// Set when the user selects a suggestion and full details are resolved.
  /// Cleared whenever the user edits the address field again.
  AddressInput? _resolvedAddress;

  /// Whether the address field shows the resolved-checkmark state.
  bool get _addressResolved => _resolvedAddress != null;

  bool get _valid =>
      _firstName.text.trim().isNotEmpty &&
      _lastName.text.trim().isNotEmpty &&
      _addressResolved;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _address.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _submit() {
    final address = _resolvedAddress;
    if (!_valid || address == null) return;
    context.read<ProfileCompletionBloc>().add(
      ProfileCompletionSubmitted(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
        address: address,
      ),
    );
  }

  void _onAddressChanged(String query) {
    // Clear any previously resolved address when the user edits the field.
    if (_resolvedAddress != null) {
      setState(() {
        _resolvedAddress = null;
        _suggestions = const [];
        _placeIds = const [];
      });
    }
    context.read<ProfileCompletionBloc>().add(
      ProfileCompletionAddressQueryChanged(query),
    );
  }

  void _onSuggestionPicked(DSAddressSuggestion suggestion) {
    final index = _suggestions.indexOf(suggestion);
    if (index < 0 || index >= _placeIds.length) return;
    final placeId = _placeIds[index];
    _address.text = suggestion.main;
    // Clear the dropdown while we resolve full details.
    setState(() {
      _suggestions = const [];
      _placeIds = const [];
    });
    context.read<ProfileCompletionBloc>().add(
      ProfileCompletionAddressSelected(
        placeId: placeId,
        displayText: suggestion.main,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCompletionBloc, ProfileCompletionState>(
      listenWhen: _listenWhen,
      listener: _listener,
      buildWhen: _buildWhen,
      builder: _builder,
    );
  }

  bool _listenWhen(
    ProfileCompletionState previous,
    ProfileCompletionState current,
  ) =>
      current is ProfileCompletionDone ||
      current is ProfileCompletionFailure ||
      current is ProfileCompletionSuggestionsLoaded ||
      current is ProfileCompletionSuggestionsCleared ||
      current is ProfileCompletionAddressResolved ||
      current is ProfileCompletionAddressError;

  void _listener(BuildContext context, ProfileCompletionState state) {
    if (state is ProfileCompletionDone) {
      context.router.replaceAll(const <PageRouteInfo>[ShellRoute()]);
    } else if (state is ProfileCompletionFailure) {
      context.showSnackBar(state.message);
    } else if (state is ProfileCompletionSuggestionsLoaded) {
      setState(() {
        _suggestions = state.suggestions;
        _placeIds = state.placeIds;
      });
    } else if (state is ProfileCompletionSuggestionsCleared) {
      setState(() {
        _suggestions = const [];
        _placeIds = const [];
      });
    } else if (state is ProfileCompletionAddressResolved) {
      setState(() => _resolvedAddress = _detailsToAddressInput(state.details));
    } else if (state is ProfileCompletionAddressError) {
      // Graceful degradation: clear suggestions but do not crash.
      setState(() {
        _suggestions = const [];
        _placeIds = const [];
      });
    }
  }

  bool _buildWhen(
    ProfileCompletionState previous,
    ProfileCompletionState current,
  ) =>
      // The terminal states of the resolving/submitting spinners MUST rebuild,
      // otherwise the builder's cached state stays AddressResolving/Submitting
      // and the Continue button is stuck in its loading state forever.
      current is ProfileCompletionIdle ||
      current is ProfileCompletionSubmitting ||
      current is ProfileCompletionAddressResolving ||
      current is ProfileCompletionAddressResolved ||
      current is ProfileCompletionAddressError ||
      current is ProfileCompletionFailure;

  Widget _builder(BuildContext context, ProfileCompletionState state) {
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
                      hintText: context.l10N.onboarding_address_search_hint,
                      controller: _address,
                      suggestions: _suggestions,
                      selected: _addressResolved,
                      onChanged: _onAddressChanged,
                      onPicked: _onSuggestionPicked,
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
                isLoading:
                    state is ProfileCompletionSubmitting ||
                    state is ProfileCompletionAddressResolving,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Maps resolved [PlaceDetails] to the [AddressInput] shape the backend
  /// expects. Falls back to [formattedAddress] when individual fields are null
  /// (Places coverage varies by locale).
  AddressInput _detailsToAddressInput(PlaceDetails details) {
    final line1 = details.line1 ?? details.formattedAddress;
    final city = details.city ?? details.formattedAddress;
    return AddressInput(
      line1: line1,
      city: city,
      // Use city as emirate fallback — backend accepts it and the onboarding
      // UX does not ask the user to disambiguate.
      emirate: city,
      country: details.country ?? 'United Arab Emirates',
    );
  }
}
