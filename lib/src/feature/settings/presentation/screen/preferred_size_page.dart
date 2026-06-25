import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_field_label.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_segmented_control.dart';
import 'package:klozy/src/design/components/ds_selectable_chip.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_size_value.dart';
import 'package:klozy/src/domain/me/entity/preferences_input.dart';
import 'package:klozy/src/domain/me/me_repository.dart';

const List<String> _sizeSystems = <String>['EU', 'US', 'UK'];

/// Settings › Personal data › Preferences › Preferred size — the size-system +
/// sizes slice of the feed preferences.
@RoutePage()
class PreferredSizePage extends StatefulWidget {
  const PreferredSizePage({super.key});

  @override
  State<PreferredSizePage> createState() => _PreferredSizePageState();
}

class _PreferredSizePageState extends State<PreferredSizePage> {
  final MeRepository _me = locator<MeRepository>();
  final CatalogRepository _catalog = locator<CatalogRepository>();

  bool _loading = true;
  bool _saving = false;
  PreferencesInput _prefs = const PreferencesInput();
  String _sizeSystem = 'EU';
  Set<String> _sizes = <String>{};
  List<CatalogSizeValue> _allSizes = const <CatalogSizeValue>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _prefs = await _me.getPreferences();
      _sizeSystem = _prefs.sizeSystem;
      _sizes = _prefs.sizes.toSet();
    } catch (_) {}
    try {
      _allSizes = await _catalog.getSizes();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _me.updatePreferences(
        PreferencesInput(
          sizeSystem: _sizeSystem,
          sizes: _sizes.toList(),
          categoryIds: _prefs.categoryIds,
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

  void _toggle(String value) {
    setState(
      () => _sizes.contains(value) ? _sizes.remove(value) : _sizes.add(value),
    );
  }

  /// Sizes to show for the selected size system. Shoe sizes are region-scoped
  /// tokens (e.g. `EU 42`, `US 10`, `UK 8`), so only the rows for the active
  /// system are shown — that's what makes the EU/US/UK selector actually swap
  /// the displayed representation. Region-agnostic sizes (clothing: S/M/L…)
  /// carry no system prefix and are always shown.
  List<CatalogSizeValue> get _visibleSizes =>
      _allSizes.where((CatalogSizeValue s) {
        final bool isRegional = _sizeSystems.any(
          (String system) => s.token.startsWith('$system '),
        );
        return !isRegional || s.token.startsWith('$_sizeSystem ');
      }).toList();

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
        title: Text(l.settings_preferred_size),
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
                  children: _visibleSizes
                      .map(
                        (CatalogSizeValue s) => DSSelectableChip(
                          label: s.label,
                          selected: _sizes.contains(s.token),
                          onTap: () => _toggle(s.token),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
    );
  }
}
