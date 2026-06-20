import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_field_label.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_selectable_chip.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_brand.dart';
import 'package:klozy/src/domain/me/entity/preferences_input.dart';
import 'package:klozy/src/domain/me/me_repository.dart';

/// Settings › Personal data › Preferences › Preferred brands — the brand slice
/// of the feed preferences.
@RoutePage()
class PreferredBrandsPage extends StatefulWidget {
  const PreferredBrandsPage({super.key});

  @override
  State<PreferredBrandsPage> createState() => _PreferredBrandsPageState();
}

class _PreferredBrandsPageState extends State<PreferredBrandsPage> {
  final MeRepository _me = locator<MeRepository>();
  final CatalogRepository _catalog = locator<CatalogRepository>();
  final TextEditingController _brandQuery = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  PreferencesInput _prefs = const PreferencesInput();
  Set<String> _brandIds = <String>{};
  List<CatalogBrand> _brands = const <CatalogBrand>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _brandQuery.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      _prefs = await _me.getPreferences();
      _brandIds = _prefs.brandIds.toSet();
    } catch (_) {}
    try {
      _brands = await _catalog.searchBrands();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _searchBrands(String query) async {
    try {
      final List<CatalogBrand> brands = await _catalog.searchBrands(
        query: query.trim().isEmpty ? null : query.trim(),
      );
      if (mounted) setState(() => _brands = brands);
    } catch (_) {}
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _me.updatePreferences(
        PreferencesInput(
          sizeSystem: _prefs.sizeSystem,
          sizes: _prefs.sizes,
          categoryIds: _prefs.categoryIds,
          brandIds: _brandIds.toList(),
        ),
      );
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

  void _toggle(String value) {
    setState(
      () => _brandIds.contains(value)
          ? _brandIds.remove(value)
          : _brandIds.add(value),
    );
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
        title: Text(l.settings_preferred_brands),
      ),
      bottomNavigationBar: _loading
          ? null
          : DSBottomBar(
              child: DSButtonElevated(
                text: l.settings_save,
                isLoading: _saving,
                onPressed: _save,
              ),
            ),
      body: _loading
          ? const DSLoader()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: <Widget>[
                DSFieldLabel(l.onboarding_brands_title),
                const SizedBox(height: 8),
                DSTextField(
                  controller: _brandQuery,
                  hintText: l.onboarding_brands_search_hint,
                  prefixIcon: Icons.search_rounded,
                  onChanged: _searchBrands,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _brands
                      .map(
                        (CatalogBrand b) => DSSelectableChip(
                          label: b.name,
                          selected: _brandIds.contains(b.id),
                          onTap: () => _toggle(b.id),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
    );
  }
}
