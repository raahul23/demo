import 'package:flutter_test/flutter_test.dart';

import 'package:goapp/features/search/data/datasources/places_remote_datasource.dart';
import 'package:goapp/features/search/data/models/place_suggestion_model.dart';
import 'package:goapp/features/search/data/repositories/places_repository_impl.dart';

class FakePlacesRemoteDataSource implements PlacesRemoteDataSource {
  List<PlaceSuggestionModel> result = [];
  String reverseResult = 'Address';

  @override
  Future<List<PlaceSuggestionModel>> autocomplete({
    required String input,
    String? countryCode,
  }) async {
    return result;
  }

  @override
  Future<String> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    return reverseResult;
  }

  @override
  Future<Map<String, double>> placeDetails({
    required String placeId,
  }) async {
    return {'lat': 12.0, 'lng': 77.0};
  }
}

void main() {
  test('returns suggestions from remote datasource', () async {
    final remote = FakePlacesRemoteDataSource()
      ..result = [
        PlaceSuggestionModel(description: 'A', placeId: '1'),
        PlaceSuggestionModel(description: 'B', placeId: '2'),
      ];
    final repo = PlacesRepositoryImpl(remote);

    final result = await repo.autocomplete(input: 'a', countryCode: 'in');

    expect(result.length, 2);
    expect(result.first.description, 'A');
  });
}
