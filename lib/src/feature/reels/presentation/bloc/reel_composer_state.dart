import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:klozy/src/domain/product/entity/product.dart';

@immutable
sealed class ReelComposerState extends Equatable {
  const ReelComposerState();

  @override
  List<Object?> get props => [];
}

final class ReelComposerLoading extends ReelComposerState {
  const ReelComposerLoading();
}

final class ReelComposerReady extends ReelComposerState {
  final List<Product> products;
  final String? errorMessage;

  const ReelComposerReady({required this.products, this.errorMessage});

  @override
  List<Object?> get props => [products, errorMessage];
}

final class ReelComposerPosting extends ReelComposerState {
  const ReelComposerPosting();
}

final class ReelComposerDone extends ReelComposerState {
  const ReelComposerDone();
}
