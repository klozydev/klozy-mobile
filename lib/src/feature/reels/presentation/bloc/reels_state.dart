import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/feature/reels/domain/entity/reel.dart';

@immutable
sealed class ReelsState extends Equatable {
  const ReelsState();

  @override
  List<Object?> get props => [];
}

final class ReelsLoadingState extends ReelsState {
  const ReelsLoadingState();
}

final class ReelsErrorState extends ReelsState {
  final AppErrorType type;

  const ReelsErrorState({required this.type});

  @override
  List<Object?> get props => [type];
}

final class ReelsReadyState extends ReelsState {
  final List<Reel> reels;
  final bool isLoadingMore;
  final bool hasMore;

  const ReelsReadyState({
    required this.reels,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  ReelsReadyState copyWith({
    List<Reel>? reels,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return ReelsReadyState(
      reels: reels ?? this.reels,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [reels, isLoadingMore, hasMore];
}
