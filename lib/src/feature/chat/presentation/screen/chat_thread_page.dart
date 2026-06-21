import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_outgoing_media.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_participant.dart';
import 'package:klozy/src/feature/chat/domain/entity/media_type.dart';
import 'package:klozy/src/feature/chat/domain/entity/message_kind.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_thread/chat_thread_bloc.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_thread/chat_thread_event.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_thread/chat_thread_state.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/attach_choice.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/attach_sheet.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/chat_composer.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/media_lightbox.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/message_row.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/reply_preview_bar.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/thread_header.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/thread_menu_choice.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/thread_menu_sheet.dart';

/// One conversation: live messages, composer (text / media / voice), reply,
/// offer responses, and the overflow menu (report & block / delete).
@RoutePage()
class ChatThreadPage extends StatefulWidget implements AutoRouteWrapper {
  const ChatThreadPage({
    super.key,
    @PathParam('conversationId') required this.conversationId,
    this.otherName,
    this.otherAvatarUrl,
  });

  final String conversationId;

  /// Display hints from the launcher so the header renders before the
  /// conversation doc loads (instant open).
  final String? otherName;
  final String? otherAvatarUrl;

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<ChatThreadBloc>(
      create: (_) =>
          locator<ChatThreadBloc>()..add(ChatThreadStarted(conversationId)),
      child: this,
    );
  }

  @override
  State<ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends State<ChatThreadPage> {
  final ScrollController _scroll = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  ChatThreadBloc get _bloc => context.read<ChatThreadBloc>();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  // ── attach / pickers (platform APIs stay in the widget layer) ──────────────

  Future<void> _openAttach() async {
    final AttachChoice? choice = await DSBottomSheet.show<AttachChoice>(
      context,
      child: const AttachSheet(),
    );
    if (choice == null || !mounted) return;
    switch (choice) {
      case AttachChoice.photo:
        await _pickPhotos();
      case AttachChoice.camera:
        await _pickCamera();
      case AttachChoice.audio:
        await _pickFiles(FileType.audio, MediaType.audio);
      case AttachChoice.document:
        await _pickFiles(FileType.any, MediaType.other);
    }
  }

  Future<void> _pickPhotos() async {
    final List<XFile> files = await _imagePicker.pickMultipleMedia();
    if (files.isEmpty) return;
    final List<ChatOutgoingMedia> items = files
        .map(
          (XFile f) => ChatOutgoingMedia(
            file: File(f.path),
            type: _isVideoPath(f.path) ? MediaType.video : MediaType.image,
            name: f.name,
          ),
        )
        .toList();
    _bloc.add(ChatMediaPicked(items));
  }

  Future<void> _pickCamera() async {
    final XFile? shot = await _imagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (shot == null) return;
    _bloc.add(
      ChatMediaPicked(<ChatOutgoingMedia>[
        ChatOutgoingMedia(
          file: File(shot.path),
          type: MediaType.image,
          name: shot.name,
        ),
      ]),
    );
  }

  Future<void> _pickFiles(FileType type, MediaType mediaType) async {
    final FilePickerResult? result = await FilePicker.pickFiles(type: type);
    if (result == null) return;
    final List<ChatOutgoingMedia> items = result.files
        .where((PlatformFile f) => f.path != null)
        .map(
          (PlatformFile f) => ChatOutgoingMedia(
            file: File(f.path!),
            type: mediaType,
            name: f.name,
          ),
        )
        .toList();
    if (items.isNotEmpty) _bloc.add(ChatMediaPicked(items));
  }

  bool _isVideoPath(String path) {
    final String ext = path.split('.').last.toLowerCase();
    return <String>['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp'].contains(ext);
  }

  // ── menu / media ───────────────────────────────────────────────────────────

  Future<void> _openMenu() async {
    final ThreadMenuChoice? choice = await DSBottomSheet.show<ThreadMenuChoice>(
      context,
      child: const ThreadMenuSheet(),
    );
    if (choice == null || !mounted) return;
    switch (choice) {
      case ThreadMenuChoice.reportAndBlock:
        _bloc.add(const ChatUserBlocked());
      case ThreadMenuChoice.delete:
        _bloc.add(const ChatConversationDeleted());
    }
  }

  void _openMedia(ChatMessage message) {
    final String? url = message.firstMedia?.url;
    if (url == null) return;
    MediaLightbox.open(
      context,
      url: url,
      isVideo: message.kind == ChatMessageKind.video,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      body: BlocConsumer<ChatThreadBloc, ChatThreadState>(
        listenWhen: _listenWhen,
        listener: _listener,
        builder: _builder,
      ),
    );
  }

  bool _listenWhen(ChatThreadState prev, ChatThreadState curr) {
    if (curr is ChatThreadClosedState) return true;
    if (prev is ChatThreadLoadedState && curr is ChatThreadLoadedState) {
      return prev.messages.length != curr.messages.length;
    }
    return curr is ChatThreadLoadedState;
  }

  void _listener(BuildContext context, ChatThreadState state) {
    if (state is ChatThreadClosedState) {
      context.router.maybePop();
      return;
    }
    if (state is ChatThreadLoadedState) _scrollToBottom();
  }

  Widget _builder(BuildContext context, ChatThreadState state) {
    final ChatParticipant? loaded = state is ChatThreadLoadedState
        ? state.thread?.other
        : null;
    // Prefer the loaded participant once it has a name; otherwise show the
    // launcher hint so the header is correct instantly.
    final ChatParticipant other =
        (loaded != null && loaded.displayName.isNotEmpty)
        ? loaded
        : ChatParticipant(
            id: loaded?.id ?? '',
            displayName: widget.otherName ?? loaded?.displayName ?? '',
            avatarUrl: widget.otherAvatarUrl ?? loaded?.avatarUrl,
          );

    return Column(
      children: <Widget>[
        ThreadHeader(
          other: other,
          onBack: () => context.router.maybePop(),
          onMenu: _openMenu,
        ),
        Expanded(child: _body(context, state)),
        if (state is ChatThreadLoadedState && state.replyTo != null)
          ReplyPreviewBar(
            replyTo: state.replyTo!,
            onCancel: () => _bloc.add(const ChatReplySet(null)),
          ),
        ChatComposer(
          onAttach: _openAttach,
          onSendText: (String text) => _bloc.add(ChatTextSent(text)),
          onSendAudio: (ChatOutgoingMedia audio) =>
              _bloc.add(ChatAudioRecorded(audio)),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, ChatThreadState state) {
    switch (state) {
      case ChatThreadLoadingState():
        return const DSLoader();
      case ChatThreadErrorState(:final type):
        return AppErrorWidget(
          type: type,
          onRetry: () => _bloc.add(ChatThreadStarted(widget.conversationId)),
        );
      case ChatThreadClosedState():
        return const SizedBox.shrink();
      case ChatThreadLoadedState():
        if (state.isEmpty) return const SizedBox.shrink();
        return ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
          itemCount: state.messages.length,
          itemBuilder: (BuildContext context, int i) {
            final ChatMessage message = state.messages[i];
            return MessageRow(
              message: message,
              onReply: (ChatMessage m) => _bloc.add(ChatReplySet(m)),
              onOpenMedia: _openMedia,
              onAcceptOffer: (ChatMessage m) => _bloc.add(
                ChatOfferResponded(
                  offerId: m.offer?.offerId ?? '',
                  accept: true,
                ),
              ),
              onRefuseOffer: (ChatMessage m) => _bloc.add(
                ChatOfferResponded(
                  offerId: m.offer?.offerId ?? '',
                  accept: false,
                ),
              ),
            );
          },
        );
    }
  }
}
