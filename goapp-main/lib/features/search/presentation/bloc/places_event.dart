abstract class PlacesEvent {}

class PlacesQueryChanged extends PlacesEvent {
  final String query;
  final String? countryCode;

  PlacesQueryChanged({
    required this.query,
    this.countryCode,
  });
}

class PlacesQueryCleared extends PlacesEvent {}
