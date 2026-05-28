class ProfileSubmission {
  final String name;
  final String gender;
  final String email;
  final String emergencyContact;

  const ProfileSubmission({
    required this.name,
    required this.gender,
    required this.email,
    required this.emergencyContact,
  });
}

class ProfileSetupState {
  final String name;
  final String gender;
  final String email;
  final String emergencyContact;
  final String? nameError;
  final String? genderError;
  final String? emailError;
  final String? emergencyError;
  final bool showValidation;
  final bool submitRequested;
  final ProfileSubmission? submission;

  const ProfileSetupState({
    required this.name,
    required this.gender,
    required this.email,
    required this.emergencyContact,
    required this.nameError,
    required this.genderError,
    required this.emailError,
    required this.emergencyError,
    required this.showValidation,
    required this.submitRequested,
    required this.submission,
  });

  factory ProfileSetupState.initial() {
    return const ProfileSetupState(
      name: '',
      gender: 'Male',
      email: '',
      emergencyContact: '',
      nameError: null,
      genderError: null,
      emailError: null,
      emergencyError: null,
      showValidation: false,
      submitRequested: false,
      submission: null,
    );
  }

  ProfileSetupState copyWith({
    String? name,
    String? gender,
    String? email,
    String? emergencyContact,
    String? nameError,
    String? genderError,
    String? emailError,
    String? emergencyError,
    bool? showValidation,
    bool? submitRequested,
    ProfileSubmission? submission,
    bool resetSubmitRequested = false,
  }) {
    return ProfileSetupState(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      nameError: nameError ?? this.nameError,
      genderError: genderError ?? this.genderError,
      emailError: emailError ?? this.emailError,
      emergencyError: emergencyError ?? this.emergencyError,
      showValidation: showValidation ?? this.showValidation,
      submitRequested: resetSubmitRequested
          ? false
          : (submitRequested ?? this.submitRequested),
      submission: submission ?? this.submission,
    );
  }
}
