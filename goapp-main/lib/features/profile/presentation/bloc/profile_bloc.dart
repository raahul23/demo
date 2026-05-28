import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/usecases/create_profile_usecase.dart';
import '../../domain/usecases/get_cached_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final CreateProfileUseCase createProfileUseCase;
  final GetCachedProfileUseCase getCachedProfileUseCase;

  ProfileBloc(
    this.createProfileUseCase,
    this.getCachedProfileUseCase, {
    bool autoLoad = true,
  }) : super(ProfileInitial()) {
    on<ProfileRequested>(_onProfileRequested);
    on<ProfileSubmitted>(_onProfileSubmitted);
    if (autoLoad) {
      add(ProfileRequested());
    }
  }

  Future<void> _onProfileRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await getCachedProfileUseCase();
    result.fold(
      (_) {},
      (profile) {
        if (profile != null) {
          emit(ProfileSuccess(profile));
        }
      },
    );
  }

  Future<void> _onProfileSubmitted(
    ProfileSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await createProfileUseCase(
      name: event.name,
      gender: event.gender,
      email: event.email,
      emergencyContact: event.emergencyContact,
    );
    result.fold(
      (failure) => emit(ProfileFailure(_messageForFailure(failure))),
      (profile) => emit(ProfileSuccess(profile)),
    );
  }

  String _messageForFailure(Failure failure) {
    if (failure is NetworkFailure) {
      return failure.message;
    }
    if (failure is ServerFailure) {
      return failure.message;
    }
    if (failure is CacheFailure) {
      return failure.message;
    }
    return 'Something went wrong';
  }
}
