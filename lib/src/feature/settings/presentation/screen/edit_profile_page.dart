import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/components/avatar_upload_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_address_field.dart';
import 'package:klozy/src/design/components/ds_address_suggestion.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_field_label.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/entity/address.dart';
import 'package:klozy/src/domain/me/entity/address_input.dart';
import 'package:klozy/src/domain/me/entity/me_profile.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/domain/places/entity/place_details.dart';
import 'package:klozy/src/domain/places/entity/place_suggestion.dart';
import 'package:klozy/src/domain/places/places_repository.dart';

/// Maximum bio length, matching the onboarding profile form and the prototype.
const int _kBioMaxLength = 150;

@RoutePage()
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final MeRepository _repo = locator<MeRepository>();
  final PlacesRepository _places = locator<PlacesRepository>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _bio = TextEditingController();
  final TextEditingController _address = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _avatarUrl;

  // Initial values, captured after load, to detect unsaved edits.
  String _initialFirst = '';
  String _initialLast = '';
  String _initialBio = '';
  String _initialAddress = '';

  // Address autocomplete state (Places dropdown).
  List<DSAddressSuggestion> _suggestions = const <DSAddressSuggestion>[];
  List<String> _placeIds = const <String>[];
  AddressInput? _resolvedAddress;

  bool get _addressResolved => _resolvedAddress != null;

  // Same gating as the onboarding Complete-profile form: name + address required.
  bool get _valid =>
      _firstName.text.trim().isNotEmpty &&
      _lastName.text.trim().isNotEmpty &&
      _address.text.trim().isNotEmpty;

  bool get _isDirty =>
      _firstName.text != _initialFirst ||
      _lastName.text != _initialLast ||
      _bio.text != _initialBio ||
      _address.text != _initialAddress;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _bio.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final MeProfile me = await _repo.getMe();
      _firstName.text = me.firstName ?? '';
      _lastName.text = me.lastName ?? '';
      _bio.text = me.bio ?? '';
      _avatarUrl = me.avatarUrl;
      if (me.hasAddress) {
        final List<Address> addresses = await _repo.getAddresses();
        if (addresses.isNotEmpty) _address.text = addresses.first.summary;
      }
    } catch (_) {}
    _initialFirst = _firstName.text;
    _initialLast = _lastName.text;
    _initialBio = _bio.text;
    _initialAddress = _address.text;
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _onAddressChanged(String query) async {
    setState(() {
      _resolvedAddress = null;
      _suggestions = const <DSAddressSuggestion>[];
      _placeIds = const <String>[];
    });
    if (query.trim().isEmpty) return;
    try {
      final List<PlaceSuggestion> results = await _places.autocomplete(query);
      if (!mounted) return;
      setState(() {
        _suggestions = results
            .map(
              (PlaceSuggestion s) =>
                  DSAddressSuggestion(main: s.description, sub: s.description),
            )
            .toList();
        _placeIds = results.map((PlaceSuggestion s) => s.placeId).toList();
      });
    } catch (_) {
      // Graceful degradation: typed text is still submitted on save.
    }
  }

  Future<void> _onSuggestionPicked(DSAddressSuggestion suggestion) async {
    final int index = _suggestions.indexOf(suggestion);
    if (index < 0 || index >= _placeIds.length) return;
    final String placeId = _placeIds[index];
    _address.text = suggestion.main;
    setState(() {
      _suggestions = const <DSAddressSuggestion>[];
      _placeIds = const <String>[];
    });
    try {
      final PlaceDetails details = await _places.details(placeId);
      if (!mounted) return;
      setState(() => _resolvedAddress = _detailsToAddressInput(details));
    } catch (_) {}
  }

  AddressInput _detailsToAddressInput(PlaceDetails details) {
    final String line1 = details.line1 ?? details.formattedAddress;
    final String city = details.city ?? details.formattedAddress;
    return AddressInput(
      line1: line1,
      city: city,
      emirate: city,
      country: details.country ?? 'United Arab Emirates',
    );
  }

  AddressInput _manualAddress() {
    final String text = _address.text.trim();
    return AddressInput(
      line1: text,
      city: text,
      emirate: text,
      country: 'United Arab Emirates',
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _repo.updateProfile(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        bio: _bio.text.trim(),
      );
      if (_address.text.trim().isNotEmpty && _address.text != _initialAddress) {
        await _repo.setAddress(_resolvedAddress ?? _manualAddress());
      }
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

  Future<bool> _confirmDiscard() async {
    final bool? discard = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: DSColor.popupBackground,
        title: Text(context.l10N.edit_profile_discard_title),
        content: Text(context.l10N.edit_profile_discard_body),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10N.edit_profile_keep_editing),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              context.l10N.edit_profile_discard_confirm,
              style: const TextStyle(color: DSColor.danger),
            ),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> _onBack() async {
    if (_isDirty && !await _confirmDiscard()) return;
    if (mounted) context.router.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10N;
    // Mirrors the onboarding Complete-profile form exactly (same fields, layout,
    // required markers, validation, address autocomplete) — only the headline
    // title and the submit button label differ, and all fields are prefilled.
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        if (await _confirmDiscard() && mounted) context.router.maybePop();
      },
      child: Scaffold(
        backgroundColor: DSColor.surface,
        appBar: AppBar(
          leadingWidth: 56,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 22),
            onPressed: _onBack,
          ),
        ),
        body: _loading
            ? const DSLoader()
            : SafeArea(
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
                              l.settings_edit_profile,
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
                              l.onboarding_complete_profile_subtitle,
                              style: const TextStyle(
                                fontFamily: dsFontFamily,
                                fontSize: DSFontSize.bodyLarge,
                                height: 1.57,
                                color: DSColor.onSurface60,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: AvatarUploadWidget(initialUrl: _avatarUrl),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      DSFieldLabel(
                                        l.onboarding_first_name_label,
                                        required: true,
                                      ),
                                      DSTextField(
                                        controller: _firstName,
                                        hintText: l.onboarding_first_name_hint,
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      DSFieldLabel(
                                        l.onboarding_last_name_label,
                                        required: true,
                                      ),
                                      DSTextField(
                                        controller: _lastName,
                                        hintText: l.onboarding_last_name_hint,
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            DSFieldLabel(
                              l.onboarding_address_label,
                              required: true,
                            ),
                            DSAddressField(
                              controller: _address,
                              hintText: l.onboarding_address_search_hint,
                              suggestions: _suggestions,
                              selected: _addressResolved,
                              onChanged: _onAddressChanged,
                              onPicked: _onSuggestionPicked,
                            ),
                            const SizedBox(height: 12),
                            DSFieldLabel(
                              l.onboarding_bio_label,
                              suffix: Text(
                                l.onboarding_bio_char_count(
                                  _bio.text.characters.length,
                                  _kBioMaxLength,
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
                              hintText: l.onboarding_bio_hint,
                              maxLines: 3,
                              maxLength: _kBioMaxLength,
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DSBottomBar(
                      child: DSButtonElevated(
                        text: l.settings_save,
                        isEnable: _valid,
                        isLoading: _saving,
                        onPressed: _save,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
