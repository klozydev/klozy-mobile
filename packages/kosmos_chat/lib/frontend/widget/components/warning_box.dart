import 'package:core_kosmos/core_kosmos.dart';
import 'package:flutter/material.dart';
import 'package:kosmos_chat/kosmos_chat.dart';

class WarningMessageBox extends StatefulHookConsumerWidget {
  final MessageModel message;
  final BoxDecoration? decoration;
  final bool? maxWidthSize;

  /// Theme
  final String? themeName;
  final TchatMessageThemeData? theme;

  const WarningMessageBox({
    super.key,
    required this.message,
    this.decoration,
    this.maxWidthSize,

    /// Theme
    this.theme,
    this.themeName,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WarningMessageBoxState();
}

class _WarningMessageBoxState extends ConsumerState<WarningMessageBox> {


  @override
  Widget build(BuildContext context) {
    final TchatMessageThemeData themeData =
      loadThemeData(widget.theme, widget.themeName ?? "tchat_message_theme", () => kDefaultTchatMessageTheme,
      isDark: ref.read(isDarkModeProvider).isDarkMode,);
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: Container(
          decoration: widget.decoration ?? themeData.eventDecoration,
          constraints: themeData.eventConstraints,
          padding: themeData.eventPadding,
          child: Row(
            mainAxisSize: widget.maxWidthSize == true ? MainAxisSize.max : MainAxisSize.min,
            children: [
              (widget.maxWidthSize == true)
                  ? Expanded(
                      child: Text(
                      widget.message.content!.tr(namedArgs: widget.message.metadata["event_data"] ?? {}),
                      style: themeData.eventTextStyle,
                      textAlign: TextAlign.center,
                    ))
                  : Text(
                      widget.message.content!.tr(namedArgs: widget.message.metadata["event_data"] ?? {}),
                      style: themeData.eventTextStyle,
                      textAlign: TextAlign.center,
                    )
            ],
          ),
        ),
      ),
    );
  }
}
