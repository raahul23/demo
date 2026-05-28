import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_services_usecase.dart';
import 'services_state.dart';

class ServicesCubit extends Cubit<ServicesState> {
  ServicesCubit(this._getServicesUseCase) : super(ServicesState.initial());

  final GetServicesUseCase _getServicesUseCase;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final items = await _getServicesUseCase();
      emit(state.copyWith(items: items, loading: false));
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          errorMessage: 'Unable to load services',
        ),
      );
    }
  }
}
