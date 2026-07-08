import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/domain/product/entity/product.dart';
import 'package:klozy/src/feature/reels/domain/reels_repository.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reel_composer_error_reason.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reel_composer_event.dart';
import 'package:klozy/src/feature/reels/presentation/bloc/reel_composer_state.dart';

@injectable
class ReelComposerBloc extends Bloc<ReelComposerEvent, ReelComposerState> {
  final ReelsRepository _reelsRepository;

  List<Product> _products = const <Product>[];

  ReelComposerBloc(this._reelsRepository) : super(const ReelComposerLoading()) {
    on<ReelComposerStarted>(_onStarted);
    on<ReelComposerSubmitted>(_onSubmitted);
  }

  Future<void> _onStarted(
    ReelComposerStarted event,
    Emitter<ReelComposerState> emit,
  ) async {
    emit(const ReelComposerLoading());
    try {
      _products = await _reelsRepository.myProducts();
    } catch (_) {
      _products = const <Product>[];
    }
    emit(ReelComposerReady(products: _products));
  }

  Future<void> _onSubmitted(
    ReelComposerSubmitted event,
    Emitter<ReelComposerState> emit,
  ) async {
    emit(const ReelComposerPosting());
    try {
      final created = await _reelsRepository.createReel(
        caption: event.caption,
        taggedProductIds: event.taggedProductIds,
      );
      if (created.uploadUrl.isEmpty) {
        throw Exception('No upload URL returned.');
      }
      await _reelsRepository.uploadVideo(created.uploadUrl, event.videoPath);
      emit(const ReelComposerDone());
    } catch (_) {
      emit(
        ReelComposerReady(
          products: _products,
          errorReason: ReelComposerErrorReason.postFailed,
        ),
      );
    }
  }
}
