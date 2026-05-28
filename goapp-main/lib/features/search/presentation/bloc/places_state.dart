import '../../domain/entities/place_suggestion.dart';

abstract class PlacesState {}

class PlacesInitial extends PlacesState {}

class PlacesLoading extends PlacesState {}

class PlacesLoaded extends PlacesState {
  final List<PlaceSuggestion> suggestions;

  PlacesLoaded(this.suggestions);
}

class PlacesError extends PlacesState {
  final String message;

  PlacesError(this.message);
}
