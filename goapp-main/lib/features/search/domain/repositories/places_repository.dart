import '../entities/place_suggestion.dart';

abstract class PlacesRepository {
  Future<List<PlaceSuggestion>> autocomplete({
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
