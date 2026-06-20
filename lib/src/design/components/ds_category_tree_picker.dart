import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_category_breadcrumb.dart';
import 'package:klozy/src/design/components/ds_category_list_item.dart';
import 'package:klozy/src/design/components/ds_category_tree_chip.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';

/// Result of a leaf selection: the leaf's [id] and the human-readable
/// breadcrumb [path] (e.g. "Women › Dresses").
class PickedCategory extends Equatable {
  final String id;
  final String path;

  const PickedCategory({required this.id, required this.path});

  @override
  List<Object?> get props => [id, path];
}

/// Shared drill-down category tree picker. The container (page or sheet)
/// decides the chrome; this widget owns the drill-down + leaf selection.
class DSCategoryTreePicker extends StatefulWidget {
  final CatalogRepository repo;
  final void Function(PickedCategory picked) onLeafSelected;
  final bool showBreadcrumb;

  /// When provided, the drill-down starts *inside* this category (its children
  /// are shown first) instead of at the catalog root. Used by Search, where the
  /// user has already tapped a root category card.
  final CatalogCategory? initialParent;

  /// When true, children render as a wrap of pill chips (the design's Filters
  /// sheet style) and the picked leaf stays highlighted with the breadcrumb
  /// still navigable — instead of the default full-width list rows.
  final bool chipLayout;

  /// Fired (chip layout) when a previously-selected leaf is abandoned by
  /// drilling into another branch or tapping back up the breadcrumb.
  final VoidCallback? onSelectionCleared;

  /// Backend facet counts keyed by category id (any drill level — counts are
  /// rolled up over `categoryPathIds`). When provided, each node shows its item
  /// count and categories with no matching items (count 0 / absent) are hidden.
  final Map<String, int>? categoryCounts;

  const DSCategoryTreePicker({
    super.key,
    required this.repo,
    required this.onLeafSelected,
    this.showBreadcrumb = true,
    this.initialParent,
    this.chipLayout = false,
    this.onSelectionCleared,
    this.categoryCounts,
  });

  @override
  State<DSCategoryTreePicker> createState() => _DSCategoryTreePickerState();
}

enum _PickerStatus { loading, loaded, error }

class _DSCategoryTreePickerState extends State<DSCategoryTreePicker> {
  final List<CatalogCategory> _path = <CatalogCategory>[];
  List<CatalogCategory> _items = const <CatalogCategory>[];
  _PickerStatus _status = _PickerStatus.loading;

  /// Chip-layout only: the leaf the user landed on (kept highlighted, with the
  /// breadcrumb still showing it).
  String? _selectedLeafId;

  @override
  void initState() {
    super.initState();
    final seed = widget.initialParent;
    if (seed != null) {
      _path.add(seed);
      _load(parentId: seed.id);
    } else {
      _load(parentId: null);
    }
  }

  Future<void> _load({required String? parentId}) async {
    setState(() => _status = _PickerStatus.loading);
    try {
      final items = await widget.repo.getCategories(parentId: parentId);
      if (!mounted) return;
      setState(() {
        _items = items;
        _status = _PickerStatus.loaded;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _status = _PickerStatus.error);
    }
  }

  void _onTap(CatalogCategory category) {
    if (category.hasChildren) {
      final bool hadLeaf = _selectedLeafId != null;
      setState(() {
        _path.add(category);
        _selectedLeafId = null;
      });
      if (hadLeaf) widget.onSelectionCleared?.call();
      _load(parentId: category.id);
    } else {
      final breadcrumb = <String>[
        ..._path.map((CatalogCategory c) => c.label),
        category.label,
      ].join(' › ');
      if (widget.chipLayout) {
        // Keep the picker mounted: push the leaf into the breadcrumb, highlight
        // it, and show the deepest-level hint instead of unmounting.
        setState(() {
          _path.add(category);
          _selectedLeafId = category.id;
          _items = const <CatalogCategory>[];
          _status = _PickerStatus.loaded;
        });
      }
      widget.onLeafSelected(PickedCategory(id: category.id, path: breadcrumb));
    }
  }

  void _onBreadcrumbTapped(int levelIndex) {
    final bool hadLeaf = _selectedLeafId != null;
    setState(() => _selectedLeafId = null);
    if (hadLeaf) widget.onSelectionCleared?.call();
    if (levelIndex == -1) {
      // Back to root
      _path.clear();
      _load(parentId: null);
    } else {
      final parentId = _path[levelIndex].id;
      _path.removeRange(levelIndex + 1, _path.length);
      _load(parentId: parentId);
    }
  }

  /// Items to render, hiding zero-count categories when facet counts are given.
  List<CatalogCategory> get _visibleItems {
    final Map<String, int>? counts = widget.categoryCounts;
    if (counts == null) return _items;
    return _items
        .where((CatalogCategory c) => (counts[c.id] ?? 0) > 0)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.showBreadcrumb && _path.isNotEmpty)
          DSCategoryBreadcrumb(
            path: _path,
            rootLabel: context.l10N.categoryPickerBreadcrumbRoot,
            onLevelTapped: _onBreadcrumbTapped,
          ),
        _body(context),
      ],
    );
  }

  Widget _body(BuildContext context) {
    return switch (_status) {
      _PickerStatus.loading => const Padding(
        padding: EdgeInsets.symmetric(vertical: DSSpacing.xl),
        child: DSLoader(),
      ),
      _PickerStatus.error => _ErrorRetry(
        onRetry: () => _load(parentId: _path.isEmpty ? null : _path.last.id),
      ),
      _PickerStatus.loaded =>
        widget.chipLayout
            ? _chipBody(context)
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _visibleItems.length,
                itemBuilder: (BuildContext context, int index) {
                  final category = _visibleItems[index];
                  return DSCategoryListItem(
                    category: category,
                    count: widget.categoryCounts?[category.id],
                    onTap: () => _onTap(category),
                  );
                },
              ),
    };
  }

  Widget _chipBody(BuildContext context) {
    if (_visibleItems.isEmpty && _path.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: DSSpacing.xxs),
        child: Text(
          context.l10N.categoryPickerDeepestHint,
          style: const TextStyle(
            fontFamily: dsFontFamily,
            fontSize: DSFontSize.bodyMedium,
            color: DSColor.onSurface45,
          ),
        ),
      );
    }
    return Wrap(
      spacing: DSSpacing.xs,
      runSpacing: DSSpacing.xs,
      children: _visibleItems
          .map(
            (CatalogCategory c) => DSCategoryTreeChip(
              category: c,
              selected: c.id == _selectedLeafId,
              count: widget.categoryCounts?[c.id],
              onTap: () => _onTap(c),
            ),
          )
          .toList(),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorRetry({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSSpacing.xl),
      child: Center(
        child: TextButton(
          onPressed: onRetry,
          child: Text(
            context.l10N.categoryPickerRetry,
            style: const TextStyle(
              fontFamily: dsFontFamily,
              fontSize: DSFontSize.bodyMedium,
              color: DSColor.primary,
            ),
          ),
        ),
      ),
    );
  }
}
