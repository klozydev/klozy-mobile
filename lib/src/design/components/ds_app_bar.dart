import 'package:flutter/material.dart';

import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';

enum BackType { modal, push, none }

class DSAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? _title;
  final BackType _backType;
  final VoidCallback? _overrideBackAction;
  final Widget? _trailing;

  const DSAppBar({
    super.key,
    String? title,
    required BackType backType,
    VoidCallback? overrideBackAction,
    Widget? trailing,
  }) : _title = title,
       _backType = backType,
       _overrideBackAction = overrideBackAction,
       _trailing = trailing;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      foregroundColor: DSColor.onSurface,
      elevation: 0,
      centerTitle: true,
      leading: _leading(context),
      titleTextStyle: context.textTheme.bodyLarge?.copyWith(
        color: DSColor.onSurface,
        fontWeight: FontWeight.w600,
      ),
      title: _title == null ? null : Text(_title),
      actions: _trailing == null ? const [] : [_trailing],
    );
  }

  Widget? _leading(BuildContext context) {
    final IconData? icon = switch (_backType) {
      BackType.modal => Icons.close,
      BackType.push => Icons.arrow_back_ios,
      BackType.none => null,
    };
    if (icon == null) return null;
    return Padding(
      padding: const EdgeInsets.only(left: DSSpacing.s),
      child: InkWell(
        onTap: () {
          if (_overrideBackAction != null) {
            _overrideBackAction();
          } else {
            Navigator.of(context).maybePop();
          }
        },
        child: Center(
          child: Icon(icon, size: DSSpacing.l, color: DSColor.onSurface),
        ),
      ),
    );
  }
}
