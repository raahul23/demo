import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/search_places_usecase.dart';
import 'places_event.dart';
import 'places_state.dart';

class PlacesBloc extends Bloc<PlacesEvent, PlacesState> {
  final SearchPlacesUseCase searchPlacesUseCase;

  PlacesBloc(this.searchPlacesUseCase) : super(PlacesInitial()) {
    on<PlacesQueryChanged>(_onQueryChanged);
    on<PlacesQueryCleared>(_onQueryCleared);
  }

  Future<void> _onQueryChanged(
    PlacesQueryChanged event,
    Emitter<PlacesState> emit,
  ) async {
    emit(PlacesLoading());
    try {
      final results = await searchPlacesUseCase(
        input: event.query,
        countryCode: event.countryCode,
      );
      emit(PlacesLoaded(results));
    } catch (_) {
      emit(PlacesError('Failed to load suggestions'));
    }
  }

  void _onQueryCleared(
    PlacesQueryCleared event,
    Emitter<PlacesState> emit,
  ) {
    emit(PlacesInitial());
  }
}
