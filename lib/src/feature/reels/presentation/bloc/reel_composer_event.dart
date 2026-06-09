import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class ReelComposerEvent extends Equatable {
  const ReelComposerEvent();

  @override
  List<Object?> get props => [];
}

final class ReelComposerStarted extends ReelComposerEvent {
  const ReelComposerStarted();
}

final class ReelComposerSubmitted extends ReelComposerEvent {
  final String videoPath;
  final String? caption;
  final List<String> taggedProductIds;

  const ReelComposerSubmitted({
    required this.videoPath,
    this.caption,
    this.taggedProductIds = const <String>[],
  });

  @override
  List<Object?> get props => [videoPath, caption, taggedProductIds];
}
