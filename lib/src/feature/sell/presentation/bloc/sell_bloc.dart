import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_condition.dart';
import 'package:klozy/src/domain/product/products_repository.dart';
import 'package:klozy/src/domain/sell/entity/sell_draft.dart';
import 'package:klozy/src/domain/sell/sell_repository.dart';
import 'package:klozy/src/domain/uploads/uploads_repository.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_event.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_state.dart';

@injectable
class SellBloc extends Bloc<SellEvent, SellState> {
  final UploadsRepository _uploadsRepository;
  final SellRepository _sellRepository;
  final ProductsRepository _productsRepository;
  final CatalogRepository _catalogRepository;

  SellBloc(
    this._uploadsRepository,
    this._sellRepository,
    this._productsRepository,
    this._catalogRepository,
  ) : super(const SellPhotosState(<String>[])) {
    on<SellStarted>(_onStarted);
    on<SellPhotosUpdated>(_onPhotosUpdated);
    on<SellAnalyzeRequested>(_onAnalyzeRequested);
    on<SellProductSubmitted>(_onSubmitted);
  }

  void _onStarted(SellStarted event, Emitter<SellState> emit) {
    emit(const SellPhotosState(<String>[]));
  }

  void _onPhotosUpdated(SellPhotosUpdated event, Emitter<SellState> emit) {
    emit(SellPhotosState(event.paths));
  }

  Future<void> _onAnalyzeRequested(
    SellAnalyzeRequested event,
    Emitter<SellState> emit,
  ) async {
    if (event.paths.isEmpty) return;
    emit(const SellAnalyzingState());
    try {
      final urls = await _uploadsRepository.uploadImages(event.paths);
      if (urls.isEmpty) {
        emit(const SellErrorState(type: AppErrorType.unknown));
        return;
      }
      // AI analysis is best-effort — a failure leaves the draft empty.
      SellDraft draft;
      try {
        draft = await _sellRepository.analyze(urls.take(6).toList());
      } catch (_) {
        draft = SellDraft.empty;
      }
      List<CatalogCategory> categories;
      try {
        categories = await _catalogRepository.getRootCategories();
      } catch (_) {
        categories = const <CatalogCategory>[];
      }
      List<CatalogCondition> conditions;
      try {
        conditions = await _catalogRepository.getConditions();
      } catch (_) {
        conditions = const <CatalogCondition>[];
      }
      emit(
        SellRecapState(
          draft: draft,
          rootCategories: categories,
          conditions: conditions,
          imageUrls: urls,
        ),
      );
    } catch (error) {
      emit(SellErrorState(type: AppErrorType.fromException(error)));
    }
  }

  Future<void> _onSubmitted(
    SellProductSubmitted event,
    Emitter<SellState> emit,
  ) async {
    final current = state;
    if (current is! SellRecapState) return;
    emit(current.copyWith(isCreating: true));
    try {
      final id = await _productsRepository.createProduct(event.input);
      emit(SellDoneState(id));
    } catch (_) {
      emit(
        current.copyWith(
          isCreating: false,
          submitError: "Couldn't publish your listing. Please try again.",
        ),
      );
    }
  }
}
