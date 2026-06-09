import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_list_item.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_brand.dart';

/// Chosen brand — a catalog id, or a freeform name.
typedef PickedBrand = ({String? id, String name});

class SellBrandPicker extends StatefulWidget {
  const SellBrandPicker({super.key});

  @override
  State<SellBrandPicker> createState() => _SellBrandPickerState();
}

class _SellBrandPickerState extends State<SellBrandPicker> {
  final CatalogRepository _catalog = locator<CatalogRepository>();
  final TextEditingController _query = TextEditingController();
  List<CatalogBrand>? _brands;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final brands = await _catalog.searchBrands(
      query: query.trim().isEmpty ? null : query.trim(),
    );
    if (!mounted) return;
    setState(() => _brands = brands);
  }

  @override
  Widget build(BuildContext context) {
    final brands = _brands;
    final query = _query.text.trim();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DSTextField(
          controller: _query,
          hintText: context.l10N.sell_search_brands,
          prefixIcon: Icons.search_rounded,
          onChanged: (String value) {
            setState(() {});
            _search(value);
          },
        ),
        const SizedBox(height: 8),
        if (brands == null)
          const SizedBox(height: 120, child: DSLoader())
        else
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                if (query.isNotEmpty)
                  DSListItem(
                    title: context.l10N.sell_use_quoted(query),
                    onTap: () =>
                        Navigator.of(context).pop((id: null, name: query)),
                  ),
                ...brands.map(
                  (CatalogBrand b) => DSListItem(
                    title: b.name,
                    onTap: () =>
                        Navigator.of(context).pop((id: b.id, name: b.name)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
