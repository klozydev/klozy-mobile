import 'package:injectable/injectable.dart';
import 'package:klozy/src/data/places/datasource/places_remote_datasource.dart';
import 'package:klozy/src/data/places/mapper/places_mapper.dart';
import 'package:klozy/src/domain/places/entity/place_details.dart';
import 'package:klozy/src/domain/places/entity/place_suggestion.dart';
import 'package:klozy/src/domain/places/places_repository.dart';

@LazySingleton(as: PlacesRepository)
class PlacesRepositoryImpl implements PlacesRepository {
  PlacesRepositoryImpl(this._datasource, this._mapper);

  final PlacesRemoteDatasource _datasource;
  final PlacesMapper _mapper;

  @override
  Future<List<PlaceSuggestion>> autocomplete(String query) async {
    final responses = await _datasource.autocomplete(query);
    return responses.map(_mapper.toSuggestion).toList();
  }

  @override
  Future<PlaceDetails> details(String placeId) async {
    final response = await _datasource.details(placeId);
    return _mapper.toDetails(response);
  }
}
