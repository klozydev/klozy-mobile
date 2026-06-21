import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/core/components/app_error_widget.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/design/tokens/ds_spacing.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_list/chat_list_bloc.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_list/chat_list_event.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_list/chat_list_state.dart';
import 'package:klozy/src/feature/chat/presentation/screen/states/chat_list_loading_widget.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/chat_list_row.dart';
import 'package:klozy/src/feature/chat/presentation/screen/widgets/empty_chats_widget.dart';
import 'package:klozy/src/router/app_router.dart';

/// Messages tab content — the live list of conversations. The whole list comes
/// from a single Firestore query (participant names embedded in each thread
/// doc), so it paints in one snapshot with no per-row loading.
class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.l10N.chat_title,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.displayLarge,
                    fontWeight: DSFontWeight.bold,
                    color: DSColor.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<ChatListBloc, ChatListState>(
                builder: _builder,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _builder(BuildContext context, ChatListState state) {
    switch (state) {
      case ChatListLoadingState():
        return const ChatListLoadingWidget();
      case ChatListErrorState(:final type):
        return AppErrorWidget(
          type: type,
          onRetry: () =>
              context.read<ChatListBloc>().add(const ChatListStarted()),
        );
      case ChatListLoadedState():
        if (state.isEmpty) return const EmptyChatsWidget();
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, DSSpacing.xl),
          itemCount: state.threads.length,
          itemBuilder: (BuildContext context, int i) {
            final ChatThread thread = state.threads[i];
            return ChatListRow(
              thread: thread,
              onTap: () => context.router.push(
                ChatThreadRoute(conversationId: thread.id),
              ),
            );
          },
        );
    }
  }
}
