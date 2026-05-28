import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/services/profile_validation_service.dart';
import 'profile_setup_state.dart';

class ProfileSetupCubit extends Cubit<ProfileSetupState> {
  final ProfileValidationService validationService;

  ProfileSetupCubit({required this.validationService})
      : super(ProfileSetupState.initial());

  void updateName(String value) {
    emit(
      state.copyWith(
        name: value,
        nameError: state.showValidation
            ? validationService.validateName(value)
            : state.nameError,
      ),
    );
  }

  void updateGender(String value) {
    emit(
      state.copyWith(
        gender: value,
        genderError: state.showValidation
            ? validationService.validateGender(value)
            : state.genderError,
      ),
    );
  }

  void updateEmail(String value) {
    emit(
      state.copyWith(
        email: value,
        emailError: state.showValidation
            ? validationService.validateEmail(value)
            : state.emailError,
      ),
    );
  }

  void updateEmergency(String value) {
    emit(
      state.copyWith(
        emergencyContact: value,
        emergencyError: state.showValidation
            ? validationService.validateEmergency(value)
            : state.emergencyError,
      ),
    );
  }

  void submit() {
    final nameError = validationService.validateName(state.name);
    final genderError = validationService.validateGender(state.gender);
    final emailError = validationService.validateEmail(state.email);
    final emergencyError =
        validationService.validateEmergency(state.emergencyContact);
    final hasError =
        nameError != null || genderError != null || emailError != null || emergencyError != null;
    if (hasError) {
      emit(
        state.copyWith(
          showValidation: true,
          nameError: nameError,
          genderError: genderError,
          emailError: emailError,
          emergencyError: emergencyError,
          submitRequested: false,
          submission: null,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        showValidation: true,
        submitRequested: true,
        submission: ProfileSubmission(
          name: state.name.trim(),
          gender: state.gender.trim(),
          email: state.email.trim(),
          emergencyContact:
              validationService.normalizeEmergency(state.emergencyContact),
        ),
      ),
    );
  }

  void setInitial({
    required String name,
    required String gender,
    required String email,
    required String emergencyContact,
  }) {
    emit(
      state.copyWith(
        name: name,
        gender: gender.isEmpty ? state.gender : gender,
        email: email,
        emergencyContact: emergencyContact,
        nameError: null,
        genderError: null,
        emailError: null,
        emergencyError: null,
        showValidation: false,
      ),
    );
  }

  void consumeSubmit() {
    emit(state.copyWith(resetSubmitRequested: true));
  }
}
