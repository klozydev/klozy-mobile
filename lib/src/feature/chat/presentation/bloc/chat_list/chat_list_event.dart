import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';

@immutable
sealed class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class ChatListStarted extends ChatListEvent {
  const ChatListStarted();
}

/// Internal — emitted by the threads stream subscription.
final class ChatListThreadsReceived extends ChatListEvent {
  final List<ChatThread> threads;

  const ChatListThreadsReceived(this.threads);

  @override
  List<Object?> get props => <Object?>[threads];
}

/// Internal — emitted when the threads stream errors.
final class ChatListErrored extends ChatListEvent {
  final Object error;

  const ChatListErrored(this.error);

  @override
  List<Object?> get props => <Object?>[error];
}
