import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/util/app_share.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel.dart';
import 'package:klozy/src/feature/reels/domain/reels_repository.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_comments_sheet.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_edit_sheet.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_menu_sheet.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_page_widget.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_processing_widget.dart';
import 'package:klozy/src/feature/reels/presentation/widget/reel_shop_sheet.dart';

/// Loads one reel by id (polling while Mux transcodes), then renders the
/// engagement overlay. Used as a single page in the profile reel pager.
class ReelPageLoaderWidget extends StatefulWidget {
  final String reelId;
  final bool isActive;

  /// Current user id, used to decide owner-only menu actions.
  final String? myId;

  const ReelPageLoaderWidget({
    required this.reelId,
    required this.isActive,
    required this.myId,
    super.key,
  });

  @override
  State<ReelPageLoaderWidget> createState() => _ReelPageLoaderWidgetState();
}

class _ReelPageLoaderWidgetState extends State<ReelPageLoaderWidget> {
  static const Duration _pollInterval = Duration(seconds: 3);
  static const int _maxPolls = 20;

  final ReelsRepository _repo = locator<ReelsRepository>();
  Reel? _reel;
  AppErrorType? _error;
  bool _loading = true;
  Timer? _pollTimer;
  int _polls = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  bool _isOwner(Reel reel) =>
      widget.myId != null && reel.author.id == widget.myId;

  Future<void> _load() async {
    _pollTimer?.cancel();
    _polls = 0;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reel = await _repo.getReel(widget.reelId);
      if (mounted) setState(() => _reel = reel);
      if (reel.isReady) {
        _unawaitedView();
      } else {
        _schedulePoll();
      }
    } catch (error) {
      if (mounted) setState(() => _error = AppErrorType.fromException(error));
    }
    if (mounted) setState(() => _loading = false);
  }

  /// Re-fetch a still-processing reel until Mux finishes transcoding (the API
  /// reconciles to READY on read), then build the player.
  void _schedulePoll() {
    if (_polls >= _maxPolls) return;
    _pollTimer = Timer(_pollInterval, () async {
      if (!mounted) return;
      _polls++;
      try {
        final reel = await _repo.getReel(widget.reelId);
        if (!mounted) return;
        setState(() => _reel = reel);
        if (reel.isReady) {
          _unawaitedView();
        } else {
          _schedulePoll();
        }
      } catch (_) {
        _schedulePoll();
      }
    });
  }

  void _unawaitedView() {
    _repo.view(widget.reelId).ignore();
  }

  Future<void> _openShop(Reel reel) {
    return DSBottomSheet.show<void>(
      context,
      title: context.l10N.reels_shop_the_look,
      child: ReelShopSheet(reelId: reel.id),
    );
  }

  Future<void> _openComments(Reel reel) {
    return DSBottomSheet.show<void>(
      context,
      title: context.l10N.reels_comments_title,
      child: ReelCommentsSheet(reelId: reel.id, isReelOwner: _isOwner(reel)),
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
      await _repo.updateReel(reel.id, caption: caption);
      if (mounted) {
        context.showSnackBar(context.l10N.reels_caption_updated);
        _load();
      }
    } catch (_) {
      if (mounted) context.showSnackBar(context.l10N.settings_save_failed);
    }
  }

  Future<void> _deleteReel(Reel reel) async {
    try {
      await _repo.delete(reel.id);
      if (mounted) {
        context.showSnackBar(context.l10N.reels_deleted_snackbar);
        context.router.maybePop();
      }
    } catch (_) {
      if (mounted) context.showSnackBar(context.l10N.settings_save_failed);
    }
  }

  Future<void> _openMenu(Reel reel) {
    return DSBottomSheet.show<void>(
      context,
      child: ReelMenuSheet(
        isOwner: _isOwner(reel),
        onShare: () {
          Navigator.of(context).maybePop();
          AppShare.reel(reel.id, caption: reel.caption);
        },
        onEdit: () {
          Navigator.of(context).maybePop();
          _editCaption(reel);
        },
        onDelete: () {
          Navigator.of(context).maybePop();
          _deleteReel(reel);
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
    if (_loading) return const DSLoader();
    if (_error != null) return AppErrorWidget(type: _error!, onRetry: _load);
    if (reel == null) return const SizedBox.shrink();
    if (!reel.isReady) return const ReelProcessingWidget();
    return ReelPageWidget(
      reel: reel,
      isActive: widget.isActive,
      isOwner: _isOwner(reel),
      onLike: () => _repo.like(reel.id).ignore(),
      onShop: () => _openShop(reel),
      onShare: () => AppShare.reel(reel.id, caption: reel.caption),
      onMenu: () => _openMenu(reel),
      onComments: () => _openComments(reel),
    );
  }
}
