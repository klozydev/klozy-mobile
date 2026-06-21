import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';

@immutable
sealed class ChatThreadState extends Equatable {
  const ChatThreadState();

  @override
  List<Object?> get props => <Object?>[];
}

final class ChatThreadLoadingState extends ChatThreadState {
  const ChatThreadLoadingState();
}

final class ChatThreadErrorState extends ChatThreadState {
  final AppErrorType type;

  const ChatThreadErrorState({required this.type});

  @override
  List<Object?> get props => <Object?>[type];
}

final class ChatThreadLoadedState extends ChatThreadState {
  final ChatThread? thread;
  final List<ChatMessage> messages;
  final ChatMessage? replyTo;

  const ChatThreadLoadedState({
    this.thread,
    this.messages = const <ChatMessage>[],
    this.replyTo,
  });

  bool get isEmpty => messages.isEmpty;

  ChatThreadLoadedState copyWith({
    ChatThread? thread,
    List<ChatMessage>? messages,
    ChatMessage? replyTo,
    bool clearReply = false,
  }) {
    return ChatThreadLoadedState(
      thread: thread ?? this.thread,
      messages: messages ?? this.messages,
      replyTo: clearReply ? null : (replyTo ?? this.replyTo),
    );
  }

  @override
  List<Object?> get props => <Object?>[thread, messages, replyTo];
}

/// Conversation was deleted — the page should pop.
final class ChatThreadClosedState extends ChatThreadState {
  const ChatThreadClosedState();
}
