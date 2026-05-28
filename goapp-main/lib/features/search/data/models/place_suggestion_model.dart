import '../../domain/entities/place_suggestion.dart';

class PlaceSuggestionModel extends PlaceSuggestion {
  PlaceSuggestionModel({
    required super.description,
    required super.placeId,
  });

  factory PlaceSuggestionModel.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestionModel(
      description: json['description'] ?? '',
      placeId: json['place_id'] ?? '',
    );
  }
}
