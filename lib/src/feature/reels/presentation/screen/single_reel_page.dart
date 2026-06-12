import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/util/app_share.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_glass_button.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel.dart';
import 'package:klozy/src/feature/reels/domain/reels_repository.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_comments_sheet.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_edit_sheet.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_menu_sheet.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_page_widget.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_shop_sheet.dart';

/// Full-screen viewer for a single reel (opened from a profile reel grid).
@RoutePage()
class SingleReelPage extends StatefulWidget {
  final String reelId;

  const SingleReelPage({@PathParam('id') required this.reelId, super.key});

  @override
  State<SingleReelPage> createState() => _SingleReelPageState();
}

class _SingleReelPageState extends State<SingleReelPage> {
  final ReelsRepository _repo = locator<ReelsRepository>();
  Reel? _reel;
  AppErrorType? _error;
  bool _loading = true;
  String? _myId;

  @override
  void initState() {
    super.initState();
    _load();
    locator<MeRepository>().getMe().then((me) {
      if (mounted) setState(() => _myId = me.id);
    }).ignore();
  }

  bool get _isOwner {
    final reel = _reel;
    return reel != null && _myId != null && reel.author.id == _myId;
  }

  Future<void> _toggleLike(Reel reel) async {
    final nowLiked = !reel.isLiked;
    final updated = reel.copyWith(
      isLiked: nowLiked,
      likes: reel.likes + (nowLiked ? 1 : -1),
    );
    setState(() => _reel = updated);
    try {
      nowLiked ? await _repo.like(reel.id) : await _repo.unlike(reel.id);
    } catch (_) {
      // Roll the optimistic toggle back.
      if (mounted) setState(() => _reel = reel);
    }
  }

  Future<void> _editCaption(Reel reel) async {
    final caption = await DSBottomSheet.show<String>(
      context,
      title: context.l10N.reels_edit_reel,
      child: ReelEditSheet(caption: reel.caption),
    );
    if (caption == null || !mounted) return;
    try {
      await _repo.updateReel(reel.id, caption: caption);
      if (mounted) {
        context.showSnackBar(context.l10N.reels_caption_updated);
        setState(() => _reel = reel.copyWith(caption: caption));
      }
    } catch (_) {
      if (mounted) context.showSnackBar(context.l10N.settings_save_failed);
    }
  }

  Future<void> _delete(Reel reel) async {
    try {
      await _repo.delete(reel.id);
      if (mounted) {
        context.showSnackBar(context.l10N.reels_deleted_snackbar);
        await context.router.maybePop();
      }
    } catch (_) {
      if (mounted) context.showSnackBar(context.l10N.settings_save_failed);
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reel = await _repo.getReel(widget.reelId);
      unawaitedView();
      if (mounted) setState(() => _reel = reel);
    } catch (error) {
      if (mounted) setState(() => _error = AppErrorType.fromException(error));
    }
    if (mounted) setState(() => _loading = false);
  }

  void unawaitedView() {
    _repo.view(widget.reelId).ignore();
  }

  Future<void> _openShop(Reel reel) {
    return DSBottomSheet.show<void>(
      context,
      title: context.l10N.reels_shop_the_look,
      child: ReelShopSheet(reelId: reel.id),
    );
  }

  Future<void> _openMenu(Reel reel) {
    return DSBottomSheet.show<void>(
      context,
      child: ReelMenuSheet(
        isOwner: _isOwner,
        onEdit: () {
          Navigator.of(context).maybePop();
          _editCaption(reel);
        },
        onDelete: () {
          Navigator.of(context).maybePop();
          _delete(reel);
        },
        onReport: () {
          Navigator.of(context).maybePop();
          _repo.report(reel.id, 'Reported from app').ignore();
          context.showSnackBar(context.l10N.reels_report_received_snackbar);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reel = _reel;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          if (_loading)
            const DSLoader()
          else if (_error != null)
            AppErrorWidget(type: _error!, onRetry: _load)
          else if (reel != null)
            Positioned.fill(
              child: ReelPageWidget(
                key: ValueKey<String>(reel.id),
                reel: reel,
                isActive: true,
                isOwner: _isOwner,
                onLike: () => _toggleLike(reel),
                onShop: () => _openShop(reel),
                onShare: () => AppShare.reel(reel.id, caption: reel.caption),
                onMenu: () => _openMenu(reel),
                onComments: () => DSBottomSheet.show<void>(
                  context,
                  title: context.l10N.reels_comments_title,
                  child: ReelCommentsSheet(reelId: reel.id),
                ),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: DSGlassButton(
                onTap: () => context.router.maybePop(),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: DSColor.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
