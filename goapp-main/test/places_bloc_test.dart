import 'package:flutter_test/flutter_test.dart';

import 'package:goapp/features/search/domain/entities/place_suggestion.dart';
import 'package:goapp/features/search/domain/repositories/places_repository.dart';
import 'package:goapp/features/search/domain/usecases/search_places_usecase.dart';
import 'package:goapp/features/search/presentation/bloc/places_bloc.dart';
import 'package:goapp/features/search/presentation/bloc/places_event.dart';
import 'package:goapp/features/search/presentation/bloc/places_state.dart';

class FakePlacesRepository implements PlacesRepository {
  List<PlaceSuggestion> result = [];

  @override
  Future<List<PlaceSuggestion>> autocomplete({
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
    return 'Address';
  }

  @override
  Future<Map<String, double>> placeDetails({
    required String placeId,
  }) async {
    return {'lat': 12.0, 'lng': 77.0};
  }
}

void main() {
  test('emits loading then loaded', () async {
    final repo = FakePlacesRepository()
      ..result = [
        PlaceSuggestion(description: 'A', placeId: '1'),
      ];
    final bloc = PlacesBloc(SearchPlacesUseCase(repo));

    final statesFuture = expectLater(
      bloc.stream,
      emitsInOrder([isA<PlacesLoading>(), isA<PlacesLoaded>()]),
    );

    bloc.add(PlacesQueryChanged(query: 'a'));
    await statesFuture;
  });
}
