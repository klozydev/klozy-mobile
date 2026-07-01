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

/// Brand selector — a dropdown of catalog brands, narrowed by a local
/// (client-side) name search over the already-loaded list. The seller picks
/// from the curated catalog; the search never hits the network.
class SellBrandPicker extends StatefulWidget {
  const SellBrandPicker({super.key});

  @override
  State<SellBrandPicker> createState() => _SellBrandPickerState();
}

class _SellBrandPickerState extends State<SellBrandPicker> {
  final CatalogRepository _catalog = locator<CatalogRepository>();
  final TextEditingController _query = TextEditingController();
  List<CatalogBrand>? _brands;
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final brands = await _catalog.searchBrands();
    if (!mounted) return;
    setState(() => _brands = brands);
  }

  void _onQueryChanged(String value) {
    setState(() => _filter = value.trim().toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final brands = _brands;
    if (brands == null) {
      return const SizedBox(height: 120, child: DSLoader());
    }
    final List<CatalogBrand> visible = _filter.isEmpty
        ? brands
        : brands
              .where((CatalogBrand b) => b.name.toLowerCase().contains(_filter))
              .toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DSTextField(
          controller: _query,
          hintText: context.l10N.onboarding_brands_search_hint,
          prefixIcon: Icons.search_rounded,
          onChanged: _onQueryChanged,
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 360),
          child: ListView(
            shrinkWrap: true,
            children: visible
                .map(
                  (CatalogBrand b) => DSListItem(
                    title: b.name,
                    onTap: () =>
                        Navigator.of(context).pop((id: b.id, name: b.name)),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
