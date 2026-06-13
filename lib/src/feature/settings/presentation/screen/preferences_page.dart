import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_category_tree_picker.dart';
import 'package:klozy/src/design/components/ds_field_label.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_segmented_control.dart';
import 'package:klozy/src/design/components/ds_selectable_chip.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_brand.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_size_value.dart';
import 'package:klozy/src/domain/me/entity/preferences_input.dart';
import 'package:klozy/src/domain/me/me_repository.dart';

const List<String> _sizeSystems = <String>['EU', 'US', 'UK'];

/// Settings → feed preferences (size system, sizes, categories, brands).
@RoutePage()
class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  final MeRepository _me = locator<MeRepository>();
  final CatalogRepository _catalog = locator<CatalogRepository>();
  final TextEditingController _brandQuery = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String _sizeSystem = 'EU';
  Set<String> _sizes = <String>{};
  // Category id → human-readable breadcrumb label, populated by the shared
  // tree picker (or seeded from saved ids on load).
  Map<String, String> _categoryPicks = <String, String>{};
  Set<String> _brandIds = <String>{};
  List<CatalogCategory> _categories = const <CatalogCategory>[];
  List<CatalogSizeValue> _allSizes = const <CatalogSizeValue>[];
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
      final prefs = await _me.getPreferences();
      _sizeSystem = prefs.sizeSystem;
      _sizes = prefs.sizes.toSet();
      _categoryPicks = <String, String>{
        for (final String id in prefs.categoryIds) id: id,
      };
      _brandIds = prefs.brandIds.toSet();
    } catch (_) {}
    try {
      _categories = await _catalog.getRootCategories();
      // Upgrade any seeded ids that match a known root category to its label.
      for (final CatalogCategory c in _categories) {
        if (_categoryPicks.containsKey(c.id)) {
          _categoryPicks[c.id] = c.label;
        }
      }
    } catch (_) {}
    try {
      _allSizes = await _catalog.getSizes();
    } catch (_) {}
    try {
      _brands = await _catalog.searchBrands();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _openCategoryPicker() async {
    final PickedCategory? picked = await DSBottomSheet.show<PickedCategory>(
      context,
      title: context.l10N.categoryPickerTitle,
      child: DSCategoryTreePicker(
        repo: _catalog,
        showBreadcrumb: true,
        onLeafSelected: (PickedCategory p) => Navigator.of(context).pop(p),
      ),
    );
    if (picked != null) {
      setState(() => _categoryPicks[picked.id] = picked.path);
    }
  }

  Future<void> _searchBrands(String query) async {
    try {
      final brands = await _catalog.searchBrands(
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
          sizeSystem: _sizeSystem,
          sizes: _sizes.toList(),
          categoryIds: _categoryPicks.keys.toList(),
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

  void _toggle(Set<String> set, String value) {
    setState(() => set.contains(value) ? set.remove(value) : set.add(value));
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
        title: Text(l.settings_preferences),
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
                DSFieldLabel(l.onboarding_categories_title),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    ..._categoryPicks.entries.map(
                      (MapEntry<String, String> e) => DSSelectableChip(
                        label: e.value,
                        selected: true,
                        onTap: () =>
                            setState(() => _categoryPicks.remove(e.key)),
                      ),
                    ),
                    DSSelectableChip(
                      label: l.categoryPickerAddCategories,
                      selected: false,
                      onTap: _openCategoryPicker,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DSFieldLabel(l.onboarding_sizes_title),
                const SizedBox(height: 8),
                DSSegmentedControl(
                  labels: _sizeSystems,
                  selectedIndex: _sizeSystems.indexOf(_sizeSystem).clamp(0, 2),
                  onChanged: (int i) =>
                      setState(() => _sizeSystem = _sizeSystems[i]),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allSizes
                      .map(
                        (CatalogSizeValue s) => DSSelectableChip(
                          label: s.label,
                          selected: _sizes.contains(s.token),
                          onTap: () => _toggle(_sizes, s.token),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
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
                          onTap: () => _toggle(_brandIds, b.id),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
    );
  }
}
