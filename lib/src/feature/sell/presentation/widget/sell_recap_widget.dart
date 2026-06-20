import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_category_tree_picker.dart';
import 'package:klozy/src/design/components/ds_field_label.dart';
import 'package:klozy/src/design/components/ds_selectable_chip.dart';
import 'package:klozy/src/design/components/ds_sparkle.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_condition.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_size_value.dart';
import 'package:klozy/src/domain/product/entity/create_product_input.dart';
import 'package:klozy/src/feature/sell/domain/entity/sell_draft_field.dart';
import 'package:klozy/src/feature/sell/domain/entity/size_system.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_bloc.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_event.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_state.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_brand_picker.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_field_ai_badge_widget.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_photo_strip_widget.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_size_toggle_widget.dart';
import 'package:klozy/src/router/app_router.dart';

class SellRecapWidget extends StatefulWidget {
  final SellRecapState state;

  const SellRecapWidget({super.key, required this.state});

  @override
  State<SellRecapWidget> createState() => _SellRecapWidgetState();
}

class _SellRecapWidgetState extends State<SellRecapWidget> {
  late final TextEditingController _title = TextEditingController(
    text: widget.state.draft.title ?? '',
  );
  late final TextEditingController _price = TextEditingController(
    text: widget.state.draft.price?.toString() ?? '',
  );
  late final TextEditingController _desc = TextEditingController(
    text: widget.state.draft.description ?? '',
  );

  bool _titleEdited = false;
  bool _priceEdited = false;
  bool _descEdited = false;

  /// Selected root (Women/Men/Kids). Chosen via inline chips; gates the
  /// subcategory drill-down which is scoped to it.
  CatalogCategory? _mainCategory;
  PickedCategory? _category;
  PickedBrand? _brand;
  String? _size;
  String? _conditionSlug;
  List<CatalogSizeValue> _sizes = const <CatalogSizeValue>[];
  // True once a subcategory's size config has been fetched. An empty config for
  // a chosen leaf means the item is "one size" (design: unique-size handling).
  bool _sizesLoaded = false;
  bool _showErrors = false;

  bool get _isOneSize => _category != null && _sizesLoaded && _sizes.isEmpty;

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _desc.dispose();
    super.dispose();
  }

  /// Selecting a root category resets any chosen subcategory + size.
  void _selectMainCategory(CatalogCategory category) {
    setState(() {
      _mainCategory = category;
      _category = null;
      _size = null;
      _sizes = const <CatalogSizeValue>[];
      _sizesLoaded = false;
    });
  }

  Future<void> _pickCategory() async {
    final result = await context.router.push(
      SellCategoryRoute(parent: _mainCategory),
    );
    if (!mounted) return;
    if (result is! PickedCategory) return;
    setState(() {
      _category = result;
      _size = null;
      _sizes = const <CatalogSizeValue>[];
      _sizesLoaded = false;
    });
    try {
      final sizes = await locator<CatalogRepository>().getSizeConfig(result.id);
      if (mounted) {
        setState(() {
          _sizes = sizes;
          _sizesLoaded = true;
          // One-size categories carry no size options — preselect "One size".
          if (sizes.isEmpty) _size = context.l10N.sell_size_one_size;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _sizesLoaded = true);
    }
  }

  Future<void> _pickBrand() async {
    final picked = await DSBottomSheet.show<PickedBrand>(
      context,
      title: context.l10N.sell_brand,
      child: const SellBrandPicker(),
    );
    if (picked != null) setState(() => _brand = picked);
  }

  num? get _priceValue => num.tryParse(_price.text.trim());
  bool get _titleValid => _title.text.trim().length >= 2;
  bool get _priceValid => (_priceValue ?? 0) > 0;
  // Description is required in the design (buyers rely on it).
  bool get _descValid => _desc.text.trim().length >= 3;

  /// The AI's per-locale drafts with `en` overridden by the user's final text.
  Map<String, dynamic>? _translations() {
    final ai = widget.state.draft.translations;
    if (ai == null || ai.isEmpty) return null;
    return <String, dynamic>{
      ...ai,
      'en': <String, dynamic>{
        'title': _title.text.trim(),
        'description': _desc.text.trim(),
      },
    };
  }

  void _submit() {
    final valid =
        _titleValid &&
        _priceValid &&
        _descValid &&
        _category != null &&
        _conditionSlug != null;
    if (!valid) {
      setState(() => _showErrors = true);
      return;
    }
    context.read<SellBloc>().add(
      SellProductSubmitted(
        CreateProductInput(
          title: _title.text.trim(),
          price: _priceValue!,
          conditionId: _conditionSlug!,
          categoryId: _category!.id,
          description: _desc.text.trim(),
          size: _size,
          brandId: _brand?.id,
          brandName: _brand?.id == null ? _brand?.name : null,
          images: widget.state.imageUrls,
          translations: _translations(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              DSSpacing.s,
              DSSpacing.xxs,
              DSSpacing.s,
              DSSpacing.s,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SellPhotoStripWidget(
                  photoPaths: state.imageUrls,
                  onEditTapped: () => context.read<SellBloc>().add(
                    const SellEditPhotosRequested(),
                  ),
                ),
                const SizedBox(height: DSSpacing.s),
                if (state.aiFilled.isNotEmpty) ...<Widget>[
                  Row(
                    children: <Widget>[
                      const DSSparkle(size: 15),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          context.l10N.sell_prefilled_by_ai,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: DSFontSize.bodyMedium,
                            fontWeight: DSFontWeight.medium,
                            color: DSColor.onSurface60,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DSSpacing.s),
                ],
                DSFieldLabel(
                  context.l10N.sell_title,
                  required: true,
                  suffix:
                      state.aiFilled.contains(SellDraftField.title) &&
                          !_titleEdited
                      ? const SellFieldAiBadgeWidget()
                      : _aiSuffix(
                          context,
                          state.draft.title,
                          _title.text,
                          _titleEdited,
                        ),
                ),
                DSTextField(
                  controller: _title,
                  hintText: context.l10N.sell_title_hint,
                  onChanged: (_) {
                    setState(() => _titleEdited = true);
                    context.read<SellBloc>().add(
                      const SellDraftFieldEdited(SellDraftField.title),
                    );
                  },
                  errorText: _showErrors && !_titleValid
                      ? context.l10N.sell_title_error
                      : null,
                ),
                const SizedBox(height: DSSpacing.xs),
                DSFieldLabel(
                  context.l10N.sell_price,
                  required: true,
                  suffix:
                      state.aiFilled.contains(SellDraftField.price) &&
                          !_priceEdited
                      ? const SellFieldAiBadgeWidget()
                      : _aiSuffix(
                          context,
                          state.draft.price?.toString(),
                          _price.text,
                          _priceEdited,
                        ),
                ),
                DSTextField(
                  controller: _price,
                  hintText: context.l10N.sell_price_hint,
                  keyboardType: TextInputType.number,
                  trailing: Text(
                    context.l10N.sell_price_suffix,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodyLarge,
                      fontWeight: DSFontWeight.semiBold,
                      color: DSColor.onSurface60,
                    ),
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (_) {
                    setState(() => _priceEdited = true);
                    context.read<SellBloc>().add(
                      const SellDraftFieldEdited(SellDraftField.price),
                    );
                  },
                  errorText: _showErrors && !_priceValid
                      ? context.l10N.sell_price_error
                      : null,
                ),
                const SizedBox(height: DSSpacing.xs),
                DSFieldLabel(
                  context.l10N.sell_description,
                  required: true,
                  suffix:
                      state.aiFilled.contains(SellDraftField.description) &&
                          !_descEdited
                      ? const SellFieldAiBadgeWidget()
                      : _aiSuffix(
                          context,
                          state.draft.description,
                          _desc.text,
                          _descEdited,
                        ),
                ),
                DSTextField(
                  controller: _desc,
                  hintText: context.l10N.sell_description_hint,
                  maxLines: 4,
                  maxLength: 2000,
                  onChanged: (_) {
                    setState(() => _descEdited = true);
                    context.read<SellBloc>().add(
                      const SellDraftFieldEdited(SellDraftField.description),
                    );
                  },
                  errorText: _showErrors && !_descValid
                      ? context.l10N.sell_description_error
                      : null,
                ),
                const SizedBox(height: DSSpacing.m),
                Padding(
                  padding: const EdgeInsets.only(bottom: DSSpacing.s),
                  child: Text(
                    context.l10N.sell_product_details,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.titleLarge,
                      fontWeight: DSFontWeight.semiBold,
                      color: DSColor.onSurface,
                    ),
                  ),
                ),
                // Main category chips (Women / Men / Kids) — pick one, then a
                // scoped subcategory drill-down appears below (design split).
                _sectionLabel(context.l10N.sell_category, required: true),
                Wrap(
                  spacing: DSSpacing.xxs,
                  runSpacing: DSSpacing.xxs,
                  children: state.rootCategories
                      .map(
                        (CatalogCategory c) => DSSelectableChip(
                          label: c.label,
                          selected: _mainCategory?.id == c.id,
                          onTap: () => _selectMainCategory(c),
                        ),
                      )
                      .toList(),
                ),
                if (_mainCategory != null) ...<Widget>[
                  const SizedBox(height: DSSpacing.s),
                  _sectionLabel(context.l10N.sell_subcategory, required: true),
                  _trigger(
                    _category?.path ?? context.l10N.sell_choose_subcategory,
                    _pickCategory,
                  ),
                ],
                if (_showErrors && _category == null)
                  _errorLine(context.l10N.sell_category_error),
                const SizedBox(height: DSSpacing.s),
                _sectionLabel(context.l10N.sell_brand),
                _trigger(
                  _brand?.name ?? context.l10N.sell_optional,
                  _pickBrand,
                ),
                if (_sizes.isNotEmpty) ...<Widget>[
                  const SizedBox(height: DSSpacing.s),
                  // Label left, EU/UK/US segmented toggle inline right (design).
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        DSFieldLabel(context.l10N.sell_size),
                        SellSizeToggleWidget(
                          current: state.sizeSystem,
                          onToggle: (SizeSystem system) => context
                              .read<SellBloc>()
                              .add(SellSizeSystemToggled(system)),
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: DSSpacing.xxs,
                    runSpacing: DSSpacing.xxs,
                    children: _sizes
                        .map(
                          (CatalogSizeValue s) => DSSelectableChip(
                            label: s.label,
                            selected: _size == s.token,
                            onTap: () => setState(() => _size = s.token),
                          ),
                        )
                        .toList(),
                  ),
                ] else if (_isOneSize) ...<Widget>[
                  // Unique-size category: a single, preselected "One size" chip.
                  const SizedBox(height: DSSpacing.s),
                  _sectionLabel(context.l10N.sell_size),
                  DSSelectableChip(
                    label: context.l10N.sell_size_one_size,
                    selected: true,
                    onTap: () {},
                  ),
                ],
                const SizedBox(height: DSSpacing.s),
                _sectionLabel(context.l10N.sell_condition, required: true),
                Wrap(
                  spacing: DSSpacing.xxs,
                  runSpacing: DSSpacing.xxs,
                  children: state.conditions
                      .map(
                        (CatalogCondition c) => DSSelectableChip(
                          label: c.label,
                          selected: _conditionSlug == c.slug,
                          onTap: () => setState(() => _conditionSlug = c.slug),
                        ),
                      )
                      .toList(),
                ),
                if (_showErrors && _conditionSlug == null)
                  _errorLine(context.l10N.sell_condition_error),
                const SizedBox(height: DSSpacing.s),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DSSpacing.s),
                  child: Text(
                    context.l10N.sellRequiredHint,
                    style: const TextStyle(
                      fontFamily: dsFontFamily,
                      fontSize: DSFontSize.bodySmall,
                      color: DSColor.onSurface45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        DSBottomBar(
          child: DSButtonElevated(
            text: context.l10N.sell_list_item,
            isLoading: state.isCreating,
            onPressed: _submit,
          ),
        ),
      ],
    );
  }

  Widget? _aiSuffix(
    BuildContext context,
    String? aiValue,
    String current,
    bool edited,
  ) {
    if (aiValue == null || aiValue.isEmpty || edited || current != aiValue) {
      return null;
    }
    return const SellFieldAiBadgeWidget();
  }

  Widget _sectionLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DSFieldLabel(text, required: required),
    );
  }

  Widget _trigger(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: DSColor.card,
          borderRadius: BorderRadius.circular(DSBorderRadius.input),
          border: Border.all(color: DSColor.onSurface15),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodyLarge,
                  color: DSColor.onSurface75,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: DSColor.onSurface45,
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: dsFontFamily,
          fontSize: DSFontSize.bodyMedium,
          color: DSColor.danger,
        ),
      ),
    );
  }
}
