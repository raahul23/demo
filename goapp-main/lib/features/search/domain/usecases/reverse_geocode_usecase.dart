import '../repositories/places_repository.dart';

class ReverseGeocodeUseCase {
  final PlacesRepository repository;

  ReverseGeocodeUseCase(this.repository);

  Future<String> call({
    required double lat,
    required double lng,
  }) {
    return repository.reverseGeocode(lat: lat, lng: lng);
  }
}
