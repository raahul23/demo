class LoginFormState {
  final String formatted;
  final String digits;
  final String? error;
  final String? phoneE164;
  final bool canSubmit;
  final bool showValidation;
  final bool submitRequested;
  final String? submitError;

  const LoginFormState({
    required this.formatted,
    required this.digits,
    required this.error,
    required this.phoneE164,
    required this.canSubmit,
    required this.showValidation,
    required this.submitRequested,
    required this.submitError,
  });

  factory LoginFormState.initial() {
    return const LoginFormState(
      formatted: '',
      digits: '',
      error: null,
      phoneE164: null,
      canSubmit: false,
      showValidation: false,
      submitRequested: false,
      submitError: null,
    );
  }

  LoginFormState copyWith({
    String? formatted,
    String? digits,
    String? error,
    String? phoneE164,
    bool? canSubmit,
    bool? showValidation,
    bool? submitRequested,
    String? submitError,
    bool resetSubmitRequested = false,
    bool clearSubmitError = false,
  }) {
    return LoginFormState(
      formatted: formatted ?? this.formatted,
      digits: digits ?? this.digits,
      error: error ?? this.error,
      phoneE164: phoneE164 ?? this.phoneE164,
      canSubmit: canSubmit ?? this.canSubmit,
      showValidation: showValidation ?? this.showValidation,
      submitRequested: resetSubmitRequested
          ? false
          : (submitRequested ?? this.submitRequested),
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    );
  }
}
