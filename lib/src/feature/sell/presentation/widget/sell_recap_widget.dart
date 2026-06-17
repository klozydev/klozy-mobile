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
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
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

  PickedCategory? _category;
  PickedBrand? _brand;
  String? _size;
  String? _conditionSlug;
  List<CatalogSizeValue> _sizes = const <CatalogSizeValue>[];
  bool _showErrors = false;

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickCategory() async {
    final result = await context.router.push(const SellCategoryRoute());
    if (!mounted) return;
    if (result is! PickedCategory) return;
    setState(() {
      _category = result;
      _size = null;
      _sizes = const <CatalogSizeValue>[];
    });
    try {
      final sizes = await locator<CatalogRepository>().getSizeConfig(result.id);
      if (mounted) setState(() => _sizes = sizes);
    } catch (_) {}
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
                  onEditTapped: () => context.router.maybePop(),
                ),
                const SizedBox(height: DSSpacing.s),
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
                ),
                const SizedBox(height: DSSpacing.m),
                _sectionLabel(context.l10N.sell_category, required: true),
                _trigger(
                  _category?.path ?? context.l10N.sell_optional,
                  _pickCategory,
                ),
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
                  _sectionLabel(context.l10N.sell_size),
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
                  const SizedBox(height: DSSpacing.xxs),
                  SellSizeToggleWidget(
                    current: state.sizeSystem,
                    onToggle: (SizeSystem system) => context
                        .read<SellBloc>()
                        .add(SellSizeSystemToggled(system)),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.auto_awesome, size: 11, color: DSColor.primary),
        const SizedBox(width: 4),
        Text(
          context.l10N.sell_suggested_by_ai,
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: 10.5,
            fontWeight: DSFontWeight.semiBold,
            color: DSColor.primary,
          ),
        ),
      ],
    );
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
