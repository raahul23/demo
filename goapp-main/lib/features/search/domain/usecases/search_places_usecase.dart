import '../entities/place_suggestion.dart';
import '../repositories/places_repository.dart';

class SearchPlacesUseCase {
  final PlacesRepository repository;

  SearchPlacesUseCase(this.repository);

  Future<List<PlaceSuggestion>> call({
    required String input,
    String? countryCode,
  }) {
    return repository.autocomplete(
      input: input,
      countryCode: countryCode,
    );
  }
}
