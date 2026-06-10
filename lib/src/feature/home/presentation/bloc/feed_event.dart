import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

final class FeedStarted extends FeedEvent {
  const FeedStarted();
}

final class FeedCategorySelected extends FeedEvent {
  /// null = "All".
  final String? rootCategoryId;

  const FeedCategorySelected(this.rootCategoryId);

  @override
  List<Object?> get props => [rootCategoryId];
}

final class FeedLoadMore extends FeedEvent {
  const FeedLoadMore();
}

/// Quiet reload (pull-to-refresh or a data-changed event) — keeps the current
/// items on screen until the fresh first page arrives.
final class FeedRefreshed extends FeedEvent {
  const FeedRefreshed();
}
