import '../repositories/places_repository.dart';

class GetPlaceDetailsUseCase {
  final PlacesRepository repository;

  GetPlaceDetailsUseCase(this.repository);

  Future<Map<String, double>> call({
    required String placeId,
  }) {
    return repository.placeDetails(placeId: placeId);
  }
}
