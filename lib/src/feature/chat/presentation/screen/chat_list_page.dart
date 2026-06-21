import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_list/chat_list_bloc.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_list/chat_list_event.dart';
import 'package:klozy/src/feature/chat/presentation/screen/chat_list_view.dart';

/// Provides the [ChatListBloc] and renders the messages list. Hosted by the
/// chat tab ([ChatPage]) for signed-in users.
class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatListBloc>(
      create: (_) => locator<ChatListBloc>()..add(const ChatListStarted()),
      child: const ChatListView(),
    );
  }
}
