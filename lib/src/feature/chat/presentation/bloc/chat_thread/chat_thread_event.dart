import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_message.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_outgoing_media.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';

@immutable
sealed class ChatThreadEvent extends Equatable {
  const ChatThreadEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class ChatThreadStarted extends ChatThreadEvent {
  final String threadId;

  const ChatThreadStarted(this.threadId);

  @override
  List<Object?> get props => <Object?>[threadId];
}

/// Internal — messages stream tick.
final class ChatMessagesReceived extends ChatThreadEvent {
  final List<ChatMessage> messages;

  const ChatMessagesReceived(this.messages);

  @override
  List<Object?> get props => <Object?>[messages];
}

/// Internal — thread doc stream tick (header data).
final class ChatThreadReceived extends ChatThreadEvent {
  final ChatThread? thread;

  const ChatThreadReceived(this.thread);

  @override
  List<Object?> get props => <Object?>[thread];
}

/// Internal — a stream errored.
final class ChatThreadStreamErrored extends ChatThreadEvent {
  final Object error;

  const ChatThreadStreamErrored(this.error);

  @override
  List<Object?> get props => <Object?>[error];
}

final class ChatTextSent extends ChatThreadEvent {
  final String text;

  const ChatTextSent(this.text);

  @override
  List<Object?> get props => <Object?>[text];
}

final class ChatReplySet extends ChatThreadEvent {
  final ChatMessage? replyTo;

  const ChatReplySet(this.replyTo);

  @override
  List<Object?> get props => <Object?>[replyTo];
}

final class ChatMediaPicked extends ChatThreadEvent {
  final List<ChatOutgoingMedia> items;

  const ChatMediaPicked(this.items);

  @override
  List<Object?> get props => <Object?>[items];
}

final class ChatAudioRecorded extends ChatThreadEvent {
  final ChatOutgoingMedia audio;

  const ChatAudioRecorded(this.audio);

  @override
  List<Object?> get props => <Object?>[audio];
}

final class ChatOfferResponded extends ChatThreadEvent {
  final String offerId;
  final bool accept;

  const ChatOfferResponded({required this.offerId, required this.accept});

  @override
  List<Object?> get props => <Object?>[offerId, accept];
}

final class ChatConversationDeleted extends ChatThreadEvent {
  const ChatConversationDeleted();
}

final class ChatUserBlocked extends ChatThreadEvent {
  const ChatUserBlocked();
}
