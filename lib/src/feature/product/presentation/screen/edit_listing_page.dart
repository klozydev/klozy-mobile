import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_field_label.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_selectable_chip.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_condition.dart';
import 'package:klozy/src/domain/product/entity/product_detail.dart';
import 'package:klozy/src/domain/product/products_repository.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_brand_picker.dart';
import 'package:klozy/src/feature/sell/presentation/widget/sell_category_picker.dart';

@RoutePage()
class EditListingPage extends StatefulWidget {
  final String productId;

  const EditListingPage({@PathParam('id') required this.productId, super.key});

  @override
  State<EditListingPage> createState() => _EditListingPageState();
}

class _EditListingPageState extends State<EditListingPage> {
  final ProductsRepository _products = locator<ProductsRepository>();
  final CatalogRepository _catalog = locator<CatalogRepository>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _size = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  List<CatalogCondition> _conditions = const <CatalogCondition>[];
  String? _conditionSlug;
  List<CatalogCategory> _roots = const <CatalogCategory>[];
  PickedCategory? _category;
  PickedBrand? _brand;
  String _currentBrand = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _description.dispose();
    _size.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final ProductDetail detail = await _products.getProduct(widget.productId);
      _title.text = detail.title;
      _price.text = detail.price.toInt().toString();
      _description.text = detail.description;
      _size.text = detail.size;
      _currentBrand = detail.brand;
      try {
        _conditions = await _catalog.getConditions();
        for (final CatalogCondition c in _conditions) {
          if (c.label == detail.conditionLabel) {
            _conditionSlug = c.slug;
            break;
          }
        }
      } catch (_) {}
      try {
        _roots = await _catalog.getRootCategories();
      } catch (_) {}
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  bool get _valid =>
      _title.text.trim().length >= 2 &&
      (num.tryParse(_price.text.trim()) ?? 0) > 0;

  Future<void> _pickCategory(CatalogCategory root) async {
    final picked = await DSBottomSheet.show<PickedCategory>(
      context,
      title: root.label,
      child: SellCategoryPicker(root: root),
    );
    if (picked != null) setState(() => _category = picked);
  }

  Future<void> _pickBrand() async {
    final picked = await DSBottomSheet.show<PickedBrand>(
      context,
      title: context.l10N.sell_brand,
      child: const SellBrandPicker(),
    );
    if (picked != null) setState(() => _brand = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _products.updateProduct(
        widget.productId,
        title: _title.text.trim(),
        description: _description.text.trim(),
        price: num.tryParse(_price.text.trim()),
        size: _size.text.trim(),
        conditionId: _conditionSlug,
        categoryId: _category?.id,
        brandId: _brand?.id,
        brandName: _brand?.id == null ? _brand?.name : null,
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
        title: Text(l.product_edit_listing),
      ),
      bottomNavigationBar: _loading
          ? null
          : DSBottomBar(
              child: DSButtonElevated(
                text: l.settings_save,
                isEnable: _valid,
                isLoading: _saving,
                onPressed: _save,
              ),
            ),
      body: _loading
          ? const DSLoader()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: <Widget>[
                DSFieldLabel(l.sell_title, required: true),
                DSTextField(
                  controller: _title,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                DSFieldLabel(l.sell_price, required: true),
                DSTextField(
                  controller: _price,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                DSFieldLabel(l.sell_description),
                DSTextField(
                  controller: _description,
                  maxLines: 4,
                  maxLength: 2000,
                ),
                const SizedBox(height: 12),
                DSFieldLabel(l.sell_size),
                DSTextField(controller: _size),
                if (_conditions.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  DSFieldLabel(l.sell_condition),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _conditions
                        .map(
                          (CatalogCondition c) => DSSelectableChip(
                            label: c.label,
                            selected: _conditionSlug == c.slug,
                            onTap: () =>
                                setState(() => _conditionSlug = c.slug),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (_roots.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  DSFieldLabel(l.sell_category),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _roots
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
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _category!.path,
                        style: const TextStyle(
                          fontFamily: dsFontFamily,
                          fontSize: DSFontSize.bodyMedium,
                          fontWeight: DSFontWeight.medium,
                          color: DSColor.primary,
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 16),
                DSFieldLabel(l.sell_brand),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickBrand,
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
                            _brand?.name ??
                                (_currentBrand.isEmpty
                                    ? l.sell_optional
                                    : _currentBrand),
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
                ),
              ],
            ),
    );
  }
}
