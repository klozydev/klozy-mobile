import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:klozy/src/core/components/app_error_type.dart';
import 'package:klozy/src/domain/catalog/catalog_repository.dart';
import 'package:klozy/src/domain/catalog/entity/catalog_category.dart';
import 'package:klozy/src/domain/me/me_repository.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/personalize_event.dart';
import 'package:klozy/src/feature/onboarding/presentation/bloc/personalize_state.dart';

@injectable
class PersonalizeBloc extends Bloc<PersonalizeEvent, PersonalizeState> {
  final CatalogRepository _catalogRepository;
  final MeRepository _meRepository;

  List<CatalogCategory> _categories = const <CatalogCategory>[];

  PersonalizeBloc(this._catalogRepository, this._meRepository)
    : super(const PersonalizeLoading()) {
    on<PersonalizeStarted>(_onStarted);
    on<PersonalizeBrandQueryChanged>(_onBrandQuery);
    on<PersonalizeSubmitted>(_onSubmitted);
  }

  Future<void> _onStarted(
    PersonalizeStarted event,
    Emitter<PersonalizeState> emit,
  ) async {
    emit(const PersonalizeLoading());
    try {
      _categories = await _catalogRepository.getRootCategories();
      final brands = await _catalogRepository.searchBrands();
      emit(PersonalizeReady(categories: _categories, brands: brands));
    } catch (error) {
      emit(PersonalizeFailure(AppErrorType.fromException(error)));
    }
  }

  Future<void> _onBrandQuery(
    PersonalizeBrandQueryChanged event,
    Emitter<PersonalizeState> emit,
  ) async {
    final current = state;
    if (current is! PersonalizeReady) return;
    try {
      final brands = await _catalogRepository.searchBrands(
        query: event.query.trim().isEmpty ? null : event.query.trim(),
      );
      emit(current.copyWith(brands: brands));
    } catch (_) {
      // Keep the existing list on a failed search.
    }
  }

  Future<void> _onSubmitted(
    PersonalizeSubmitted event,
    Emitter<PersonalizeState> emit,
  ) async {
    final current = state;
    if (current is PersonalizeReady) {
      emit(current.copyWith(isSubmitting: true));
    }
    // Best-effort: personalize is skippable, so proceed even if the save fails.
    try {
      await _meRepository.updatePreferences(event.preferences);
    } catch (_) {}
    emit(const PersonalizeCompleted());
  }
}
