import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/util/app_share.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel.dart';
import 'package:klozy/src/feature/reels/domain/reels_repository.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reels_bloc.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reels_event.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reels_state.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_comments_sheet.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_edit_sheet.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_menu_sheet.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_page_widget.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_progress_dots_widget.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_shop_sheet.dart';

/// The TikTok-style vertical reel viewer used in the Home "Reels" tab. [active]
/// is true only while the Reels tab is selected (so videos pause otherwise).
class ReelViewerWidget extends StatefulWidget {
  final bool active;

  const ReelViewerWidget({super.key, required this.active});

  @override
  State<ReelViewerWidget> createState() => _ReelViewerWidgetState();
}

class _ReelViewerWidgetState extends State<ReelViewerWidget> {
  final ReelsBloc _bloc = locator<ReelsBloc>()..add(const ReelsInitEvent());
  final PageController _pageController = PageController();
  int _index = 0;
  String? _myId;

  @override
  void initState() {
    super.initState();
    locator<MeRepository>().getMe().then((me) {
      if (mounted) setState(() => _myId = me.id);
    }).ignore();
  }

  @override
  void dispose() {
    _bloc.close();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(List<Reel> reels) {
    final reel = reels[_index];
    _bloc.add(ReelsViewedEvent(reel.id));
    if (_index >= reels.length - 2) {
      _bloc.add(const ReelsLoadMoreEvent());
    }
  }

  Future<void> _openShop(Reel reel) {
    return DSBottomSheet.show<void>(
      context,
      title: context.l10N.reels_shop_the_look,
      child: ReelShopSheet(reelId: reel.id),
    );
  }

  Future<void> _openComments(Reel reel) {
    final isOwner = _myId != null && reel.author.id == _myId;
    return DSBottomSheet.show<void>(
      context,
      title: context.l10N.reels_comments_title,
      child: ReelCommentsSheet(reelId: reel.id, isReelOwner: isOwner),
    );
  }

  Future<void> _editCaption(Reel reel) async {
    final caption = await DSBottomSheet.show<String>(
      context,
      title: context.l10N.reels_edit_reel,
      child: ReelEditSheet(caption: reel.caption),
    );
    if (caption == null || !mounted) return;
    try {
      await locator<ReelsRepository>().updateReel(reel.id, caption: caption);
      if (mounted) {
        context.showSnackBar(context.l10N.reels_caption_updated);
        _bloc.add(const ReelsInitEvent());
      }
    } catch (_) {
      if (mounted) context.showSnackBar(context.l10N.settings_save_failed);
    }
  }

  Future<void> _openMenu(Reel reel) {
    final isOwner = _myId != null && reel.author.id == _myId;
    return DSBottomSheet.show<void>(
      context,
      child: ReelMenuSheet(
        isOwner: isOwner,
        onShare: () {
          Navigator.of(context).maybePop();
          AppShare.reel(reel.id, caption: reel.caption);
        },
        onEdit: () {
          Navigator.of(context).maybePop();
          _editCaption(reel);
        },
        onDelete: () {
          _bloc.add(ReelsDeletedEvent(reel.id));
          Navigator.of(context).maybePop();
          context.showSnackBar(context.l10N.reels_deleted_snackbar);
        },
        onReport: () {
          locator<ReelsRepository>().report(reel.id, 'Reported from app');
          Navigator.of(context).maybePop();
          context.showSnackBar(context.l10N.reels_report_received_snackbar);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReelsBloc>.value(
      value: _bloc,
      child: BlocBuilder<ReelsBloc, ReelsState>(
        builder: (BuildContext context, ReelsState state) {
          return switch (state) {
            ReelsLoadingState() => const ColoredBox(
              color: DSColor.surface,
              child: DSLoader(),
            ),
            ReelsErrorState(:final type) => AppErrorWidget(
              type: type,
              onRetry: () => _bloc.add(const ReelsInitEvent()),
            ),
            ReelsReadyState() => _viewer(state),
          };
        },
      ),
    );
  }

  Widget _viewer(ReelsReadyState state) {
    if (state.reels.isEmpty) {
      return ColoredBox(
        color: DSColor.surface,
        child: Center(
          child: Text(
            context.l10N.reels_empty,
            style: const TextStyle(color: DSColor.onSurface45),
          ),
        ),
      );
    }
    return Stack(
      children: <Widget>[
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: state.reels.length,
          onPageChanged: (int i) {
            setState(() => _index = i);
            _onPageChanged(state.reels);
          },
          itemBuilder: (BuildContext context, int i) {
            final reel = state.reels[i];
            return ReelPageWidget(
              reel: reel,
              isActive: widget.active && i == _index,
              isOwner: _myId != null && reel.author.id == _myId,
              onLike: () => _bloc.add(ReelsLikeToggledEvent(reel)),
              onShop: () => _openShop(reel),
              onShare: () => AppShare.reel(reel.id, caption: reel.caption),
              onMenu: () => _openMenu(reel),
              onComments: () => _openComments(reel),
            );
          },
        ),
        Positioned(
          top: MediaQuery.viewPaddingOf(context).top + 56,
          right: 14,
          child: ReelProgressDotsWidget(
            count: state.reels.length,
            current: _index,
          ),
        ),
      ],
    );
  }
}
