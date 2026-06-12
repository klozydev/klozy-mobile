import 'dart:async';

import 'package:core_kosmos/core_kosmos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kosmos_chat/backend/kosmos_chat_backend.dart';
import 'package:kosmos_chat/backend/utils/utils.dart';
import 'package:kosmos_chat/frontend/kosmos_chat_frontend.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';

/// {@category Widget}
/// {@category Tchat}
///
/// Permet d'afficher la liste des tchats de l'utilisateur.
///
/// Vous pouvez définir si l'utilisateur peut créer un nouveau
/// tchat via la clé [canCreateNewTchat].
/// **/!\ Attention**, si vous souhaitez créer un nouveau
/// tchat, vous devez fournir une action via le paramètre
/// [topActionEvent].
///
/// Vous pouvez configurer les différents affichages de la
/// liste :
///
/// - [noTchatBuilder] : Permet de configurer l'affichage
///  lorsque l'utilisateur n'a aucun tchat.
/// - [tchatRowBuilder] : Permet de configurer l'affichage
/// d'une ligne de tchat, par défaut il affiche un
/// [TchatRowItem].
///
/// Les tchats row sont wrapper dans un [Slidable] qui
/// permet d'afficher des actions spécifiques.
/// Par défaut, 2 actions sont disponibles:
///
/// - [actionMoreEvent] : Permet d'afficher un menu
/// d'action.
/// - [actionDeleteEvent] : Permet de supprimer le tchat.
///
/// Vous pouvez également configurer les actions via la
/// clé [buildTchatRowAction].
///
/// Si jamais vous ne fournissez pas d'événement via les
/// clés [actionMoreEvent] ou [actionDeleteEvent], la page
/// va automatiquement utiliser les événements par défaut
/// [reportAndLockEvent] et [deleteEvent]. (Si un
/// utilisateur est déjà bloqué, le widget proposera
/// l'événement [unLockEvent] à la place de
/// [reportAndLockEvent]).
///
/// Vous pouvez fournir un thème via la clé "tchat_theme"
/// ou via la clé [themeName]. Vous pouvez également
/// fournir un thème [TchatThemeData] via la clé [theme].
class TchatListWidget extends StatefulHookConsumerWidget {
  /// Config
  final bool canCreateNewTchat;
  final bool addBackButton;

  /// Builder
  final Widget Function(BuildContext)? noTchatBuilder;
  final Widget Function(BuildContext, TchatModel, TchatThemeData?)?
      tchatRowBuilder;

  final FutureOr<void> Function(BuildContext)? topActionEvent;
  final ActionPane Function(BuildContext context, TchatModel tchat)?
      buildTchatRowAction;
  final void Function(BuildContext, WidgetRef, TchatModel)? actionMoreEvent;
  final void Function(BuildContext, TchatModel)? actionDeleteEvent;

  /// Default event
  final void Function(WidgetRef, BuildContext, TchatModel)? reportAndLockEvent;
  final void Function(WidgetRef, TchatModel)? unLockEvent;
  final void Function(WidgetRef, TchatModel)? deleteEvent;

  /// Ui
  final String? topActionSvgAsset;

  /// Theme
  final String? themeName;
  final TchatThemeData? theme;

  const TchatListWidget({
    super.key,

    /// Config
    this.canCreateNewTchat = true,
    this.addBackButton = false,
    this.noTchatBuilder,
    this.tchatRowBuilder,
    this.topActionEvent,
    this.buildTchatRowAction,
    this.actionDeleteEvent,
    this.actionMoreEvent,
    this.deleteEvent,
    this.reportAndLockEvent,
    this.unLockEvent,

    /// Ui
    this.topActionSvgAsset,

    /// Theme
    this.themeName,
    this.theme,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TchatListWidgetState();
}

class _TchatListWidgetState extends ConsumerState<TchatListWidget> {
  

  late final TchatBackEndConfig _backEndConfig = getTchatBackEndConfig();

  bool mutex = true;
  @override
  Widget build(BuildContext context) {
    final TchatThemeData themeData = loadThemeData(widget.theme,
      widget.themeName ?? "tchat_theme", () => kDefaultTchatTheme,
      isDark: ref.watch(isDarkModeProvider).isDarkMode,       );
    if (FirebaseAuth.instance.currentUser?.uid == null) return Container();

    List<TchatModel>? tchatList = ref
        .watch(tchatListProvider(FirebaseAuth.instance.currentUser!.uid))
        .tchatList
        ?.where((e) => !e.closed || _backEndConfig.showTchatIfClosed)
        .toList();

    TchatFrontEndConfig frontEndConfig = getTchatFrontEndConfig();
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (frontEndConfig.listing.addTopPadding)
          SliverToBoxAdapter(
              child: SizedBox(
                  height:
                      MediaQuery.of(context).padding.top + formatHeight(12))),
        if (!frontEndConfig.listing.hideHeaderChatList) ...[
          SliverToBoxAdapter(
              child: Container(
            constraints: BoxConstraints(
                minHeight: formatHeight(54), maxHeight: formatHeight(60)),
            child: _buildListHeader(context, themeData),
          )),
          SliverToBoxAdapter(child: SizedBox(height: formatHeight(24))),
        ],
        if (tchatList == null)
          SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, _) => _buildShimmerList(context, themeData),
                  childCount: 4))
        else
          (tchatList.isEmpty)
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: widget.noTchatBuilder?.call(context) ??
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: formatWidth(50))
                                .copyWith(
                                    bottom: formatHeight(24) +
                                        MediaQuery.of(context).padding.bottom),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "package.tchat.list.no-tchat".tr(),
                                textAlign: TextAlign.center,
                                style: themeData.tchatListNoTchatStyle,
                              ),
                              sh(6),
                              Text(
                                "package.tchat.list.no-tchat-content".tr(),
                                textAlign: TextAlign.center,
                                style:themeData.tchatListNoTchatContentStyle,
                              ),
                            ],
                          ),
                        ),
                      ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => KeyedSubtree(
                        key: ValueKey(tchatList[index].id),
                        child: _buildTchatRow(context, tchatList[index], themeData)),
                    childCount: tchatList.length,
                  ),
                ),
      ],
    );
  }

  /// Permet de build le header de la liste. Contenant
  /// le titre de la liste et le bouton pour créer un nouveau
  /// tchat.
  Widget _buildListHeader(BuildContext context, TchatThemeData themeData) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 0,
          right: 0,
          child: Center(
              child: Text("package.tchat.list.title".tr(),
                  textAlign: TextAlign.center,
                  style: themeData.tchatListTitleStyle)),
        ),
        if (widget.addBackButton) ...[
          Positioned(
            left: 0,
            child: ButtonBack(
              padding: pw(27.5),
              onTap: () => AutoRouter.of(context).pop(),
            ),
          ),
        ],
        if (widget.canCreateNewTchat) ...[
          Positioned(
            right: 0,
            child: InkWell(
              onTap: () async => await widget.topActionEvent?.call(context),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: formatWidth(18)),
                child: SvgPicture.asset(
                    widget.topActionSvgAsset ?? "assets/svg/ic_edit.svg",
                    color: themeData.tchatListIconColor,
                    package: widget.topActionSvgAsset != null
                        ? null
                        : "kosmos_chat"),
              ),
            ),
          )
        ],
      ],
    );
  }

  /// Permet de build les items de tchat.
  /// Correspond à chaque conversation différentes.
  Widget _buildTchatRow(BuildContext context, TchatModel tchat, TchatThemeData themeData) {
    if (widget.tchatRowBuilder != null) {
      return widget.tchatRowBuilder!.call(context, tchat, themeData);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () async {
            if (mutex == false) return;
            mutex = false;
            await getTchatBackEndConfig()
                .tchatInterface
                .openTchat(context, ref, tchat);

            mutex = true;
          },
          child: TchatRowItem(
            data: tchat,
            theme: themeData,
            buildTchatRowAction: widget.buildTchatRowAction,
            actionDeleteEvent:
                widget.actionDeleteEvent ?? _defaultActionDeleteEvent,
            actionMoreEvent: widget.actionMoreEvent ?? _defaultActionMoreEvent,
          ),
        ),
        sh(13),
      ],
    );
  }

  /// Afficher l'animation de chargement de la liste
  Widget _buildShimmerList(BuildContext context,TchatThemeData themeData) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: formatWidth(26))
          .copyWith(bottom: formatHeight(12)),
      child: Shimmer.fromColors(
        baseColor: themeData.tchatListShimmerBaseColor ?? Colors.grey.shade300,
        highlightColor:
            themeData.tchatListShimmerHighlightColor ?? Colors.grey.shade200,
        direction: ShimmerDirection.ltr,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (themeData.tchatRowShowIcon) ...[
              Container(
                width: formatWidth(51),
                height: formatWidth(51),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(formatWidth(51)),
                ),
              ),
              sw(16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: formatWidth(100),
                    height: formatHeight(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(formatWidth(20)),
                    ),
                  ),
                  sh(8),
                  Container(
                    width: formatWidth(250),
                    height: formatHeight(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(formatWidth(20)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Permet d'afficher les événements par défaut
  /// lors du clic sur le bouton de suppression.
  /// Uniquement si l'utilisateur n'a pas défini
  /// son propre événement via la clé
  /// [TchatListWidget.actionDeleteEvent].
  Future<void> _defaultActionDeleteEvent(
      BuildContext context, TchatModel tchat) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          message: Text("package.tchat.event.delete-tchat-sure".tr()),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: Text('utils.cancel'.tr()),
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                widget.deleteEvent?.call(ref, tchat);
                Navigator.pop(context);
              },
              isDestructiveAction: true,
              child: Text('package.tchat.event.delete-tchat'.tr()),
            ),
          ],
        );
      },
    );
  }

  /// Permet d'afficher les événements par défaut
  /// lors du clic sur le bouton de plus.
  /// Uniquement si l'utilisateur n'a pas défini
  /// son propre événement via la clé
  /// [TchatListWidget.actionMoreEvent].
  Future<void> _defaultActionMoreEvent(
      BuildContext context, WidgetRef ref, TchatModel tchat) async {
    final otherId = tchat.participants.firstWhere(
        (element) => element != FirebaseAuth.instance.currentUser!.uid);

    if (tchat.isGroup) return;

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          message: Text("utils.what-do-you-want-to-do".tr()),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: Text('utils.cancel'.tr()),
          ),
          actions: [
            if (!(ref.read(userProvider).metadata?.bloquedUsers ?? const [])
                .contains(otherId))
              CupertinoActionSheetAction(
                onPressed: () async {
                  widget.reportAndLockEvent?.call(ref, context, tchat);
                  Navigator.pop(context);
                },
                isDestructiveAction: true,
                child: Text('package.tchat.event.report-and-block'.tr()),
              )
            else if ((ref.read(userProvider).metadata?.bloquedUsers ??
                    const [])
                .contains(otherId))
              CupertinoActionSheetAction(
                onPressed: () async {
                  widget.unLockEvent?.call(ref, tchat);
                  Navigator.pop(context);
                },
                isDefaultAction: true,
                child: Text('utils.unlock'.tr()),
              ),
          ],
        );
      },
    );
  }
}
