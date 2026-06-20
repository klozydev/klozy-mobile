import 'package:flutter/material.dart';
import 'package:klozy/src/design/components/ds_list_item.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_brand.dart';

/// Chosen brand — a catalog id, or a freeform name.
typedef PickedBrand = ({String? id, String name});

/// Brand selector — a fixed dropdown of catalog brands (design: no free-text
/// search, the seller picks from the curated list).
class SellBrandPicker extends StatefulWidget {
  const SellBrandPicker({super.key});

  @override
  State<SellBrandPicker> createState() => _SellBrandPickerState();
}

class _SellBrandPickerState extends State<SellBrandPicker> {
  final CatalogRepository _catalog = locator<CatalogRepository>();
  List<CatalogBrand>? _brands;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final brands = await _catalog.searchBrands();
    if (!mounted) return;
    setState(() => _brands = brands);
  }

  @override
  Widget build(BuildContext context) {
    final brands = _brands;
    if (brands == null) {
      return const SizedBox(height: 120, child: DSLoader());
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 360),
      child: ListView(
        shrinkWrap: true,
        children: brands
            .map(
              (CatalogBrand b) => DSListItem(
                title: b.name,
                onTap: () =>
                    Navigator.of(context).pop((id: b.id, name: b.name)),
              ),
            )
            .toList(),
      ),
    );
  }
}
