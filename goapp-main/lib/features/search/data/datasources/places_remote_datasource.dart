import '../models/place_suggestion_model.dart';

abstract class PlacesRemoteDataSource {
  Future<List<PlaceSuggestionModel>> autocomplete({
    required String input,
    String? countryCode,
  });

  Future<String> reverseGeocode({
    required double lat,
    required double lng,
  });

  Future<Map<String, double>> placeDetails({
    required String placeId,
  });
}
