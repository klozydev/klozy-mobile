import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_category_breadcrumb.dart';
import 'package:klozy/src/design/components/ds_category_list_item.dart';
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

  const DSCategoryTreePicker({
    super.key,
    required this.repo,
    required this.onLeafSelected,
    this.showBreadcrumb = true,
  });

  @override
  State<DSCategoryTreePicker> createState() => _DSCategoryTreePickerState();
}

enum _PickerStatus { loading, loaded, error }

class _DSCategoryTreePickerState extends State<DSCategoryTreePicker> {
  final List<CatalogCategory> _path = <CatalogCategory>[];
  List<CatalogCategory> _items = const <CatalogCategory>[];
  _PickerStatus _status = _PickerStatus.loading;

  @override
  void initState() {
    super.initState();
    _load(parentId: null);
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
      setState(() => _path.add(category));
      _load(parentId: category.id);
    } else {
      final breadcrumb = <String>[
        ..._path.map((CatalogCategory c) => c.label),
        category.label,
      ].join(' › ');
      widget.onLeafSelected(PickedCategory(id: category.id, path: breadcrumb));
    }
  }

  void _onBreadcrumbTapped(int levelIndex) {
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
      _PickerStatus.loaded => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _items.length,
        itemBuilder: (BuildContext context, int index) {
          final category = _items[index];
          return DSCategoryListItem(
            category: category,
            onTap: () => _onTap(category),
          );
        },
      ),
    };
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
