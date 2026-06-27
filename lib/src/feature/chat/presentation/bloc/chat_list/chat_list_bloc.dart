import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:event_bus/event_bus.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/events/profile_changed_event.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';
import 'package:klozy/src/feature/chat/domain/usecase/watch_threads.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_list/chat_list_event.dart';
import 'package:klozy/src/feature/chat/presentation/bloc/chat_list/chat_list_state.dart';

@injectable
class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  ChatListBloc(this._watchThreads, EventBus eventBus)
    : super(const ChatListLoadingState()) {
    on<ChatListStarted>(_onStarted);
    on<ChatListThreadsReceived>(_onReceived);
    on<ChatListErrored>(_onErrored);
    // Completing/editing the profile resolves the backend session that the
    // thread stream depends on, but those flows only fire ProfileChangedEvent.
    // Re-run the stream so a stuck "Something went wrong" state recovers without
    // a restart (the ChatRepository clears its cached profile on the same event,
    // so this reload fetches fresh data).
    _profileSub = eventBus.on<ProfileChangedEvent>().listen(
      (_) => add(const ChatListStarted()),
    );
  }

  final WatchThreads _watchThreads;
  StreamSubscription<List<ChatThread>>? _sub;
  StreamSubscription<ProfileChangedEvent>? _profileSub;

  void _onStarted(ChatListStarted event, Emitter<ChatListState> emit) {
    emit(const ChatListLoadingState());
    _sub?.cancel();
    _sub = _watchThreads().listen(
      (List<ChatThread> threads) => add(ChatListThreadsReceived(threads)),
      onError: (Object error) => add(ChatListErrored(error)),
    );
  }

  void _onReceived(ChatListThreadsReceived event, Emitter<ChatListState> emit) {
    emit(ChatListLoadedState(event.threads));
  }

  void _onErrored(ChatListErrored event, Emitter<ChatListState> emit) {
    emit(ChatListErrorState(type: AppErrorType.fromException(event.error)));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _profileSub?.cancel();
    return super.close();
  }
}
