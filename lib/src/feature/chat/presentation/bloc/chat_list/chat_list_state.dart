import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';

@immutable
sealed class ChatListState extends Equatable {
  const ChatListState();

  @override
  List<Object?> get props => <Object?>[];
}

final class ChatListLoadingState extends ChatListState {
  const ChatListLoadingState();
}

final class ChatListErrorState extends ChatListState {
  final AppErrorType type;

  const ChatListErrorState({required this.type});

  @override
  List<Object?> get props => <Object?>[type];
}

final class ChatListLoadedState extends ChatListState {
  final List<ChatThread> threads;

  const ChatListLoadedState(this.threads);

  bool get isEmpty => threads.isEmpty;

  int get unreadCount => threads.where((ChatThread t) => t.hasUnread).length;

  @override
  List<Object?> get props => <Object?>[threads];
}
