import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_category_tree_picker.dart';
import 'package:klozy/src/design/components/ds_field_label.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_selectable_chip.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/me/entity/preferences_input.dart';
import 'package:klozy/src/domain/me/me_repository.dart';

/// Settings › Personal data › Preferences › Clothing preference — the category
/// slice of the feed preferences (design splits preferences into three pages).
@RoutePage()
class ClothingPreferencePage extends StatefulWidget {
  const ClothingPreferencePage({super.key});

  @override
  State<ClothingPreferencePage> createState() => _ClothingPreferencePageState();
}

class _ClothingPreferencePageState extends State<ClothingPreferencePage> {
  final MeRepository _me = locator<MeRepository>();
  final CatalogRepository _catalog = locator<CatalogRepository>();

  bool _loading = true;
  bool _saving = false;
  PreferencesInput _prefs = const PreferencesInput();
  // Category id → human-readable breadcrumb label.
  Map<String, String> _categoryPicks = <String, String>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _prefs = await _me.getPreferences();
      _categoryPicks = <String, String>{
        for (final String id in _prefs.categoryIds) id: id,
      };
    } catch (_) {}
    try {
      final List<CatalogCategory> roots = await _catalog.getRootCategories();
      for (final CatalogCategory c in roots) {
        if (_categoryPicks.containsKey(c.id)) _categoryPicks[c.id] = c.label;
      }
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

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _me.updatePreferences(
        PreferencesInput(
          sizeSystem: _prefs.sizeSystem,
          sizes: _prefs.sizes,
          categoryIds: _categoryPicks.keys.toList(),
          brandIds: _prefs.brandIds,
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
        title: Text(l.settings_clothing_preference),
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
              ],
            ),
    );
  }
}
