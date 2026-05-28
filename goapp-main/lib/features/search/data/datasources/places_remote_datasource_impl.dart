import '../../../../core/network/places_service.dart';
import '../models/place_suggestion_model.dart';
import 'places_remote_datasource.dart';

class PlacesRemoteDataSourceImpl implements PlacesRemoteDataSource {
  final PlacesService service;

  PlacesRemoteDataSourceImpl(this.service);

  @override
  Future<List<PlaceSuggestionModel>> autocomplete({
    required String input,
    String? countryCode,
  }) {
    return service.autocomplete(
      input: input,
      countryCode: countryCode,
    );
  }

  @override
  Future<String> reverseGeocode({
    required double lat,
    required double lng,
  }) {
    return service.reverseGeocode(lat: lat, lng: lng);
  }

  @override
  Future<Map<String, double>> placeDetails({
    required String placeId,
  }) {
    return service.placeDetails(placeId: placeId);
  }
}
