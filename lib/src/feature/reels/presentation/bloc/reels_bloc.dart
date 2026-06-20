import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:event_bus/event_bus.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/core/events/reels_changed_event.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel.dart';
import 'package:klozy/src/feature/reels/domain/reels_repository.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reels_event.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reels_state.dart';

@injectable
class ReelsBloc extends Bloc<ReelsEvent, ReelsState> {
  final ReelsRepository _reelsRepository;

  final List<StreamSubscription<Object?>> _subscriptions =
      <StreamSubscription<Object?>>[];

  static const int _limit = 10;
  int _page = 1;

  ReelsBloc(this._reelsRepository, EventBus eventBus)
    : super(const ReelsLoadingState()) {
    on<ReelsInitEvent>(_onInit);
    on<ReelsLoadMoreEvent>(_onLoadMore);
    on<ReelsLikeToggledEvent>(_onLikeToggled);
    on<ReelsViewedEvent>(_onViewed);
    on<ReelsDeletedEvent>(_onDeleted);
    // Refresh the feed when a reel is created/changed elsewhere (e.g. after
    // the composer finishes uploading a new reel).
    _subscriptions.add(
      eventBus.on<ReelsChangedEvent>().listen(
        (_) => add(const ReelsInitEvent()),
      ),
    );
  }

  @override
  Future<void> close() {
    for (final StreamSubscription<Object?> sub in _subscriptions) {
      sub.cancel();
    }
    return super.close();
  }

  Future<void> _onInit(ReelsInitEvent event, Emitter<ReelsState> emit) async {
    emit(const ReelsLoadingState());
    try {
      _page = 1;
      final page = await _reelsRepository.feed(page: _page, limit: _limit);
      emit(
        ReelsReadyState(reels: page.data, hasMore: page.data.length >= _limit),
      );
    } catch (error) {
      emit(ReelsErrorState(type: AppErrorType.fromException(error)));
    }
  }

  Future<void> _onLoadMore(
    ReelsLoadMoreEvent event,
    Emitter<ReelsState> emit,
  ) async {
    final current = state;
    if (current is! ReelsReadyState ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));
    try {
      final page = await _reelsRepository.feed(page: _page + 1, limit: _limit);
      _page += 1;
      emit(
        current.copyWith(
          reels: <Reel>[...current.reels, ...page.data],
          isLoadingMore: false,
          hasMore: page.data.length >= _limit,
        ),
      );
    } catch (_) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onLikeToggled(
    ReelsLikeToggledEvent event,
    Emitter<ReelsState> emit,
  ) async {
    final current = state;
    if (current is! ReelsReadyState) return;
    final reel = event.reel;
    final nowLiked = !reel.isLiked;
    final updated = reel.copyWith(
      isLiked: nowLiked,
      likes: reel.likes + (nowLiked ? 1 : -1),
    );
    emit(current.copyWith(reels: _replace(current.reels, updated)));
    try {
      nowLiked
          ? await _reelsRepository.like(reel.id)
          : await _reelsRepository.unlike(reel.id);
    } catch (_) {
      final latest = state;
      if (latest is ReelsReadyState) {
        emit(latest.copyWith(reels: _replace(latest.reels, reel)));
      }
    }
  }

  void _onViewed(ReelsViewedEvent event, Emitter<ReelsState> emit) {
    unawaited(_reelsRepository.view(event.reelId));
  }

  Future<void> _onDeleted(
    ReelsDeletedEvent event,
    Emitter<ReelsState> emit,
  ) async {
    final current = state;
    if (current is! ReelsReadyState) return;
    try {
      await _reelsRepository.delete(event.reelId);
    } catch (_) {}
    emit(
      current.copyWith(
        reels: current.reels.where((Reel r) => r.id != event.reelId).toList(),
      ),
    );
  }

  List<Reel> _replace(List<Reel> reels, Reel updated) {
    return reels.map((Reel r) => r.id == updated.id ? updated : r).toList();
  }
}
