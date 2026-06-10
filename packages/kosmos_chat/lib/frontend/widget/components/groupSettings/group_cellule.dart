import 'package:core_kosmos/core_kosmos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kosmos_chat/backend/model/tchatGroupSettings/cellule_group_section.dart';
import 'package:kosmos_chat/frontend/theme/groupSettings/group_cellule_theme_data.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';

class GroupCellule extends ConsumerStatefulWidget {
  final String? themeName;
  final CelluleGroupModel model;
  final String tchatId;
  final GroupCelluleThemeData? theme;
  const GroupCellule(
      {super.key,
      this.theme,
      this.themeName,
      required this.model,
      required this.tchatId});
  @override
  ConsumerState<GroupCellule> createState() => _GroupCelluleState();
}

class _GroupCelluleState extends ConsumerState<GroupCellule> {
  bool state = false;

  @override
  void initState() {
    super.initState();
    execAfterBuild(() {
      setState(() {
        state =
            widget.model.initialSwitchValue?.call(context, widget.tchatId) ??
                false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final GroupCelluleThemeData themeData = loadThemeData(widget.theme,
      widget.themeName ?? "group_cellule", () => kDefaultGroupCellule,
      isDark: ref.read(isDarkModeProvider).isDarkMode,       );
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius:
              themeData.decoration?.borderRadius ?? BorderRadius.zero),
      child: InkWell(
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        onTap: () async {
          if (widget.model.type == CelluleType.switcher) {
            if (widget.model.onSwitch != null) {
              updateState(await widget.model.onSwitch!(
                  context, ref, !state, widget.tchatId));
            }
          } else if (widget.model.onTap != null) {
            widget.model.onTap!(context, ref, widget.tchatId);
          }
        },
        child: Container(
          padding: themeData.padding,
          decoration: themeData.decoration,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          constraints: BoxConstraints(minHeight: formatHeight(62)),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.model.prefixBuilder != null ||
                  widget.model.prefixSvgPath != null) ...[
                if (widget.model.prefixSvgPath != null)
                  Container(
                    width: formatWidth(37),
                    height: formatWidth(37),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(formatWidth(37)),
                        color: themeData.prefixIconBackgroundColor,
                        gradient: themeData.prefixIconBackgroundGradient),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    // ignore: deprecated_member_use
                    child: Center(
                        child: SvgPicture.asset(widget.model.prefixSvgPath!,
                            color: themeData.prefixIconColor)),
                  )
                else
                  Container(
                    width: formatWidth(37),
                    height: formatWidth(37),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(formatWidth(37))),
                    clipBehavior: Clip.antiAlias,
                    child: widget.model.prefixBuilder!(context, ref),
                  ),
                sw(16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      widget.model.tileBuilder(context, ref),
                      style: themeData.titleStyle,
                      maxLines: widget.model.subTitleBuilder != null ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.model.subTitleBuilder != null)
                      Text(widget.model.subTitleBuilder!.call(context, ref),
                          style: themeData.subtitleStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (widget.model.showNotifAlert != null &&
                  widget.model.showNotifAlert!.call(context, ref)) ...[
                sw(4),
                Container(
                  width: formatWidth(8),
                  height: formatWidth(8),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: DefaultColor.error),
                ),
              ],
              _generateStateSuffix(context, ref, themeData),
            ],
          ),
        ),
      ),
    );
  }

  Widget _generateStateSuffix(BuildContext context, WidgetRef ref, GroupCelluleThemeData themeData) {
    if (widget.model.type == CelluleType.action) {
      return Row(
        children: [
          sw(8),
          Icon(Icons.arrow_forward_ios_rounded,
              color: themeData.actionIconColor, size: formatWidth(14))
        ],
      );
    } else if (widget.model.type == CelluleType.switcher) {
      return Row(
        children: [
          sw(8),
          IgnorePointer(
            child: KosmosSwicth(
              isActive: state,
              onSwipe: (_) => setState(() async => state = await widget
                  .model.onSwitch!
                  .call(context, ref, !state, widget.tchatId)),
            ),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  void updateState(bool newState) => setState(() => state = newState);
}
