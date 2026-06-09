import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel.dart';

@immutable
sealed class ReelsEvent extends Equatable {
  const ReelsEvent();

  @override
  List<Object?> get props => [];
}

final class ReelsInitEvent extends ReelsEvent {
  const ReelsInitEvent();
}

final class ReelsLoadMoreEvent extends ReelsEvent {
  const ReelsLoadMoreEvent();
}

final class ReelsLikeToggledEvent extends ReelsEvent {
  final Reel reel;

  const ReelsLikeToggledEvent(this.reel);

  @override
  List<Object?> get props => [reel];
}

final class ReelsViewedEvent extends ReelsEvent {
  final String reelId;

  const ReelsViewedEvent(this.reelId);

  @override
  List<Object?> get props => [reelId];
}

final class ReelsDeletedEvent extends ReelsEvent {
  final String reelId;

  const ReelsDeletedEvent(this.reelId);

  @override
  List<Object?> get props => [reelId];
}
