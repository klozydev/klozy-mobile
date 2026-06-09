import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_list_item.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';

/// The chosen leaf category — id + a human-readable breadcrumb.
typedef PickedCategory = ({String id, String path});

/// Drill-down category picker (within a root). Returns the chosen leaf via
/// `Navigator.pop`. A node with no children is treated as selectable.
class SellCategoryPicker extends StatefulWidget {
  final CatalogCategory root;

  const SellCategoryPicker({super.key, required this.root});

  @override
  State<SellCategoryPicker> createState() => _SellCategoryPickerState();
}

class _SellCategoryPickerState extends State<SellCategoryPicker> {
  final CatalogRepository _catalog = locator<CatalogRepository>();
  final List<CatalogCategory> _trail = <CatalogCategory>[];
  List<CatalogCategory>? _children;

  @override
  void initState() {
    super.initState();
    _trail.add(widget.root);
    _load(widget.root.id);
  }

  Future<void> _load(String parentId) async {
    setState(() => _children = null);
    final children = await _catalog.getCategories(parentId: parentId);
    if (!mounted) return;
    setState(() => _children = children);
  }

  void _select(CatalogCategory category) {
    if (category.hasChildren) {
      _trail.add(category);
      _load(category.id);
    } else {
      Navigator.of(context).pop((
        id: category.id,
        path: <CatalogCategory>[
          ..._trail,
          category,
        ].map((CatalogCategory c) => c.label).join(' › '),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final children = _children;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            _trail.map((CatalogCategory c) => c.label).join(' › '),
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodyMedium,
              color: DSColor.onSurface60,
            ),
          ),
        ),
        if (children == null)
          const SizedBox(height: 120, child: DSLoader())
        else if (children.isEmpty)
          DSListItem(
            title: context.l10N.sell_use_quoted(_trail.last.label),
            onTap: () => Navigator.of(context).pop((
              id: _trail.last.id,
              path: _trail.map((CatalogCategory c) => c.label).join(' › '),
            )),
          )
        else
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: children
                  .map(
                    (CatalogCategory c) => DSListItem(
                      title: c.label,
                      trailing: c.hasChildren
                          ? const Icon(
                              Icons.chevron_right,
                              color: DSColor.onSurface45,
                            )
                          : null,
                      onTap: () => _select(c),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}
