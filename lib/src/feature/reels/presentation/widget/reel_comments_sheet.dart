import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/components/ds_text_field.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel_comment.dart';
import 'package:klozy/src/feature/reels/domain/reels_repository.dart';

/// Comments sheet — list + composer; author or reel owner can delete.
class ReelCommentsSheet extends StatefulWidget {
  final String reelId;
  final bool isReelOwner;

  const ReelCommentsSheet({
    super.key,
    required this.reelId,
    this.isReelOwner = false,
  });

  @override
  State<ReelCommentsSheet> createState() => _ReelCommentsSheetState();
}

class _ReelCommentsSheetState extends State<ReelCommentsSheet> {
  final ReelsRepository _repo = locator<ReelsRepository>();
  final TextEditingController _input = TextEditingController();
  bool _loading = true;
  bool _sending = false;
  String? _myId;
  List<ReelComment> _comments = const <ReelComment>[];

  @override
  void initState() {
    super.initState();
    _load();
    locator<MeRepository>().getMe().then((me) {
      if (mounted) setState(() => _myId = me.id);
    }).ignore();
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      _comments = await _repo.comments(widget.reelId);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _send() async {
    final body = _input.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final comment = await _repo.addComment(widget.reelId, body);
      _input.clear();
      setState(() => _comments = <ReelComment>[..._comments, comment]);
    } catch (_) {
      if (mounted) context.showSnackBar(context.l10N.reels_comment_failed);
    }
    if (mounted) setState(() => _sending = false);
  }

  Future<void> _delete(ReelComment comment) async {
    setState(
      () => _comments = _comments
          .where((ReelComment c) => c.id != comment.id)
          .toList(),
    );
    try {
      await _repo.deleteComment(widget.reelId, comment.id);
    } catch (_) {}
  }

  bool _canDelete(ReelComment c) =>
      widget.isReelOwner || (_myId != null && c.authorId == _myId);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (_loading)
            const SizedBox(height: 120, child: DSLoader())
          else if (_comments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                context.l10N.reels_no_comments,
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodyMedium,
                  color: DSColor.onSurface45,
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _comments.length,
                itemBuilder: (BuildContext context, int i) => _CommentRow(
                  comment: _comments[i],
                  canDelete: _canDelete(_comments[i]),
                  onDelete: () => _delete(_comments[i]),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: DSTextField(
                  controller: _input,
                  hintText: context.l10N.reels_comment_hint,
                  maxLength: 1000,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _input.text.trim().isEmpty
                        ? DSColor.onSurface07
                        : DSColor.primary,
                    shape: BoxShape.circle,
                  ),
                  child: _sending
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: DSColor.surface,
                          ),
                        )
                      : Icon(
                          Icons.arrow_upward_rounded,
                          size: 20,
                          color: _input.text.trim().isEmpty
                              ? DSColor.onSurface45
                              : DSColor.surface,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  final ReelComment comment;
  final bool canDelete;
  final VoidCallback onDelete;

  const _CommentRow({
    required this.comment,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 15,
            backgroundColor: DSColor.lowBlack,
            backgroundImage: comment.authorAvatar == null
                ? null
                : NetworkImage(comment.authorAvatar!),
            child: comment.authorAvatar == null
                ? const Icon(Icons.person, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  comment.authorName,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodySmall,
                    fontWeight: DSFontWeight.semiBold,
                    color: DSColor.onSurface60,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  comment.body,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodyMedium,
                    height: 1.35,
                    color: DSColor.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (canDelete)
            GestureDetector(
              onTap: onDelete,
              child: const Padding(
                padding: EdgeInsets.only(left: 8, top: 2),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 16,
                  color: DSColor.onSurface35,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
