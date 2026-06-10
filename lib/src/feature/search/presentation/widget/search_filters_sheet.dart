import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_selectable_chip.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_brand.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_condition.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_size_value.dart';
import 'package:klozy/src/feature/search/presentation/bloc/search_filters.dart';

/// Filters sheet body — category drill-down + conditions + sizes. Returns the
/// chosen [SearchFilters] via `Navigator.pop`.
class SearchFiltersSheet extends StatefulWidget {
  final SearchFilters initial;

  const SearchFiltersSheet({super.key, required this.initial});

  @override
  State<SearchFiltersSheet> createState() => _SearchFiltersSheetState();
}

class _SearchFiltersSheetState extends State<SearchFiltersSheet> {
  final CatalogRepository _catalog = locator<CatalogRepository>();
  final TextEditingController _brandQuery = TextEditingController();
  late final TextEditingController _minPrice = TextEditingController(
    text: widget.initial.minPrice?.toInt().toString() ?? '',
  );
  late final TextEditingController _maxPrice = TextEditingController(
    text: widget.initial.maxPrice?.toInt().toString() ?? '',
  );

  bool _loading = true;
  List<CatalogCondition> _allConditions = const <CatalogCondition>[];
  List<CatalogSizeValue> _allSizes = const <CatalogSizeValue>[];
  List<CatalogBrand> _brands = const <CatalogBrand>[];

  final List<CatalogCategory> _path = <CatalogCategory>[];
  List<CatalogCategory> _children = const <CatalogCategory>[];

  late Set<String> _conditions = <String>{...widget.initial.conditions};
  late Set<String> _sizes = <String>{...widget.initial.sizes};
  late Set<String> _brandIds = <String>{...widget.initial.brandIds};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _brandQuery.dispose();
    _minPrice.dispose();
    _maxPrice.dispose();
    super.dispose();
  }

  Future<void> _searchBrands(String query) async {
    try {
      final brands = await _catalog.searchBrands(
        query: query.trim().isEmpty ? null : query.trim(),
      );
      if (mounted) setState(() => _brands = brands);
    } catch (_) {}
  }

  Future<void> _load() async {
    final children = await _catalog.getCategories();
    try {
      _allConditions = await _catalog.getConditions();
    } catch (_) {}
    try {
      _allSizes = await _catalog.getSizes();
    } catch (_) {}
    try {
      _brands = await _catalog.searchBrands();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _children = children;
      _loading = false;
    });
  }

  Future<void> _drill(CatalogCategory category) async {
    final children = await _catalog.getCategories(parentId: category.id);
    if (!mounted) return;
    setState(() {
      _path.add(category);
      _children = children;
    });
  }

  Future<void> _back() async {
    if (_path.isEmpty) return;
    _path.removeLast();
    final parent = _path.isEmpty ? null : _path.last.id;
    final children = await _catalog.getCategories(parentId: parent);
    if (!mounted) return;
    setState(() => _children = children);
  }

  void _reset() {
    setState(() {
      _path.clear();
      _conditions = <String>{};
      _sizes = <String>{};
      _brandIds = <String>{};
      _minPrice.clear();
      _maxPrice.clear();
    });
    _load();
  }

  void _apply() {
    Navigator.of(context).pop(
      SearchFilters(
        categoryId: _path.isEmpty ? null : _path.last.id,
        categoryPath: _path.isEmpty
            ? null
            : _path.map((CatalogCategory c) => c.label).join(' › '),
        conditions: _conditions,
        sizes: _sizes,
        brandIds: _brandIds,
        minPrice: num.tryParse(_minPrice.text.trim()),
        maxPrice: num.tryParse(_maxPrice.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox(height: 160, child: DSLoader());
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _label(context.l10N.search_filter_category),
                _breadcrumb(),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _children
                      .map(
                        (CatalogCategory c) => DSSelectableChip(
                          label: c.label,
                          selected: false,
                          onTap: () => _drill(c),
                        ),
                      )
                      .toList(),
                ),
                if (_allConditions.isNotEmpty) ...<Widget>[
                  _label(context.l10N.search_filter_condition),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allConditions
                        .map(
                          (CatalogCondition c) => DSSelectableChip(
                            label: c.label,
                            selected: _conditions.contains(c.slug),
                            onTap: () => setState(
                              () => _conditions.contains(c.slug)
                                  ? _conditions.remove(c.slug)
                                  : _conditions.add(c.slug),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (_allSizes.isNotEmpty) ...<Widget>[
                  _label(context.l10N.search_filter_size),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allSizes
                        .map(
                          (CatalogSizeValue s) => DSSelectableChip(
                            label: s.label,
                            selected: _sizes.contains(s.token),
                            onTap: () => setState(
                              () => _sizes.contains(s.token)
                                  ? _sizes.remove(s.token)
                                  : _sizes.add(s.token),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                _label(context.l10N.search_filter_brand),
                DSTextField(
                  controller: _brandQuery,
                  hintText: context.l10N.onboarding_brands_search_hint,
                  prefixIcon: Icons.search_rounded,
                  onChanged: _searchBrands,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _brands
                      .map(
                        (CatalogBrand b) => DSSelectableChip(
                          label: b.name,
                          selected: _brandIds.contains(b.id),
                          onTap: () => setState(
                            () => _brandIds.contains(b.id)
                                ? _brandIds.remove(b.id)
                                : _brandIds.add(b.id),
                          ),
                        ),
                      )
                      .toList(),
                ),
                _label(context.l10N.search_filter_price),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DSTextField(
                        controller: _minPrice,
                        hintText: context.l10N.search_price_min,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DSTextField(
                        controller: _maxPrice,
                        hintText: context.l10N.search_price_max,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: DSButtonOutline(
                text: context.l10N.search_filter_reset,
                onPressed: _reset,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DSButtonElevated(
                text: context.l10N.search_filter_show_results,
                onPressed: _apply,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: dsFontFamily,
          fontSize: DSFontSize.titleLarge,
          fontWeight: DSFontWeight.semiBold,
          color: DSColor.onSurface,
        ),
      ),
    );
  }

  Widget _breadcrumb() {
    if (_path.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: _back,
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 14,
              color: DSColor.onSurface60,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _path.map((CatalogCategory c) => c.label).join(' › '),
              style: const TextStyle(
                fontFamily: dsFontFamily,
                fontSize: DSFontSize.bodyMedium,
                fontWeight: DSFontWeight.medium,
                color: DSColor.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
