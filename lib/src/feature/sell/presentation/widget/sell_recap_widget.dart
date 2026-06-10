import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_field_label.dart';
import 'package:klozy/src/design/components/ds_selectable_chip.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_condition.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_size_value.dart';
import 'package:klozy/src/domain/product/entity/create_product_input.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_bloc.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_event.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_state.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_brand_picker.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_category_picker.dart';

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
  final TextEditingController _weight = TextEditingController();

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
    _weight.dispose();
    super.dispose();
  }

  Future<void> _pickCategory(CatalogCategory root) async {
    final picked = await DSBottomSheet.show<PickedCategory>(
      context,
      title: root.label,
      child: SellCategoryPicker(root: root),
    );
    if (picked == null) return;
    setState(() {
      _category = picked;
      _size = null;
      _sizes = const <CatalogSizeValue>[];
    });
    try {
      final sizes = await locator<CatalogRepository>().getSizeConfig(picked.id);
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
          weightGrams: num.tryParse(_weight.text.trim()),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DSFieldLabel(
                  context.l10N.sell_title,
                  required: true,
                  suffix: _aiSuffix(
                    context,
                    state.draft.title,
                    _title.text,
                    _titleEdited,
                  ),
                ),
                DSTextField(
                  controller: _title,
                  hintText: context.l10N.sell_title_hint,
                  onChanged: (_) => setState(() => _titleEdited = true),
                  errorText: _showErrors && !_titleValid
                      ? context.l10N.sell_title_error
                      : null,
                ),
                const SizedBox(height: 12),
                DSFieldLabel(
                  context.l10N.sell_price,
                  required: true,
                  suffix: _aiSuffix(
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
                  onChanged: (_) => setState(() => _priceEdited = true),
                  errorText: _showErrors && !_priceValid
                      ? context.l10N.sell_price_error
                      : null,
                ),
                const SizedBox(height: 12),
                DSFieldLabel(
                  context.l10N.sell_description,
                  suffix: _aiSuffix(
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
                  onChanged: (_) => setState(() => _descEdited = true),
                ),
                const SizedBox(height: 12),
                DSFieldLabel(context.l10N.sell_weight),
                DSTextField(
                  controller: _weight,
                  hintText: context.l10N.sell_weight_hint,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                const SizedBox(height: 20),
                _sectionLabel(context.l10N.sell_category, required: true),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: state.rootCategories
                      .map(
                        (CatalogCategory c) => DSSelectableChip(
                          label: c.label,
                          selected: false,
                          onTap: () => _pickCategory(c),
                        ),
                      )
                      .toList(),
                ),
                if (_category != null)
                  _selectedRow(context.l10N.sell_category, _category!.path),
                if (_showErrors && _category == null)
                  _errorLine(context.l10N.sell_category_error),
                const SizedBox(height: 16),
                _sectionLabel(context.l10N.sell_brand),
                _trigger(
                  _brand?.name ?? context.l10N.sell_optional,
                  _pickBrand,
                ),
                if (_sizes.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  _sectionLabel(context.l10N.sell_size),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
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
                ],
                const SizedBox(height: 16),
                _sectionLabel(context.l10N.sell_condition, required: true),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
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

  Widget _selectedRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        value,
        style: const TextStyle(
          fontFamily: dsFontFamily,
          fontSize: DSFontSize.bodyMedium,
          fontWeight: DSFontWeight.medium,
          color: DSColor.primary,
        ),
      ),
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
