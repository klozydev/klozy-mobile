import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_button_outline.dart';
import 'package:klozy/src/design/components/ds_category_tree_picker.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_selectable_chip.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_brand.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_condition.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_size_value.dart';
import 'package:klozy/src/feature/search/presentation/bloc/search_filters.dart';
import 'package:klozy/src/feature/search/presentation/widget/filter_section_label_widget.dart';
import 'package:klozy/src/feature/search/presentation/widget/selected_category_chip_widget.dart';

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

  // Seeded from the active filters: reopening the sheet must show (and
  // re-apply) the current category, otherwise tapping "Show results" to merely
  // add a price filter silently wipes it.
  late PickedCategory? _selectedCategory = widget.initial.categoryId == null
      ? null
      : PickedCategory(
          id: widget.initial.categoryId!,
          path: widget.initial.categoryPath ?? '',
        );

  // Root-category scope picked from the browse cards — carried over unless the
  // user explicitly picks (or clears) a category here.
  late String? _rootCategoryId = widget.initial.rootCategoryId;

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
      _loading = false;
    });
  }

  void _reset() {
    setState(() {
      _selectedCategory = null;
      _rootCategoryId = null;
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
        rootCategoryId: _rootCategoryId,
        categoryId: _selectedCategory?.id,
        categoryPath: _selectedCategory?.path,
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
                FilterSectionLabelWidget(
                  text: context.l10N.search_filter_category,
                ),
                if (_selectedCategory != null)
                  SelectedCategoryChipWidget(
                    path: _selectedCategory!.path,
                    onClear: () => setState(() => _selectedCategory = null),
                  )
                else
                  DSCategoryTreePicker(
                    repo: _catalog,
                    showBreadcrumb: true,
                    onLeafSelected: (PickedCategory picked) {
                      setState(() {
                        _selectedCategory = picked;
                        // An explicit pick replaces the browse-card scope.
                        _rootCategoryId = null;
                      });
                    },
                  ),
                if (_allConditions.isNotEmpty) ...<Widget>[
                  FilterSectionLabelWidget(
                    text: context.l10N.search_filter_condition,
                  ),
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
                  FilterSectionLabelWidget(
                    text: context.l10N.search_filter_size,
                  ),
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
                FilterSectionLabelWidget(
                  text: context.l10N.search_filter_brand,
                ),
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
                FilterSectionLabelWidget(
                  text: context.l10N.search_filter_price,
                ),
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
}
