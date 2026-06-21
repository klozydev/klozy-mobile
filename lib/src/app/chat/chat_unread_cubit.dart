import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/feature/chat/domain/entity/chat_thread.dart';
import 'package:klozy/src/feature/chat/domain/usecase/watch_threads.dart';

/// App-wide unread-conversation count — backs the chat tab badge in the shell.
///
/// Re-subscribes to the threads stream whenever the signed-in user changes, so
/// the badge is correct across login / logout.
@lazySingleton
class ChatUnreadCubit extends Cubit<int> {
  ChatUnreadCubit(this._watchThreads, this._auth) : super(0) {
    _authSub = _auth.authStateChanges().listen(_onUser);
    _onUser(_auth.currentUser);
  }

  final WatchThreads _watchThreads;
  final FirebaseAuth _auth;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<List<ChatThread>>? _threadsSub;

  void _onUser(User? user) {
    _threadsSub?.cancel();
    if (user == null) {
      emit(0);
      return;
    }
    _threadsSub = _watchThreads().listen(
      (List<ChatThread> threads) =>
          emit(threads.where((ChatThread t) => t.hasUnread).length),
      onError: (_) => emit(0),
    );
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    _threadsSub?.cancel();
    return super.close();
  }
}
