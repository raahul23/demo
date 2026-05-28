import '../../domain/entities/place_suggestion.dart';
import '../../domain/repositories/places_repository.dart';
import '../datasources/places_remote_datasource.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  final PlacesRemoteDataSource remoteDataSource;

  PlacesRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<PlaceSuggestion>> autocomplete({
    required String input,
    String? countryCode,
  }) async {
    return remoteDataSource.autocomplete(
      input: input,
      countryCode: countryCode,
    );
  }

  @override
  Future<String> reverseGeocode({
    required double lat,
    required double lng,
  }) {
    return remoteDataSource.reverseGeocode(lat: lat, lng: lng);
  }

  @override
  Future<Map<String, double>> placeDetails({
    required String placeId,
  }) {
    return remoteDataSource.placeDetails(placeId: placeId);
  }
}
