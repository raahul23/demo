part of 'otp_cubit.dart';

const Object _otpNoChange = Object();

class OtpState {
  final String code;
  final int secondsLeft;
  final bool canResend;
  final bool submitRequested;
  final String? submitError;
  final String? resendMessage;
  final String? errorMessage;
  final bool isLoading;

  const OtpState({
    required this.code,
    required this.secondsLeft,
    required this.canResend,
    required this.submitRequested,
    required this.submitError,
    required this.resendMessage,
    required this.errorMessage,
    required this.isLoading,
  });

  factory OtpState.initial() {
    return const OtpState(
      code: '',
      secondsLeft: 30,
      canResend: false,
      submitRequested: false,
      submitError: null,
      resendMessage: null,
      errorMessage: null,
      isLoading: false,
    );
  }

  OtpState copyWith({
    String? code,
    int? secondsLeft,
    bool? canResend,
    bool? submitRequested,
    Object? submitError = _otpNoChange,
    Object? resendMessage = _otpNoChange,
    Object? errorMessage = _otpNoChange,
    bool? isLoading,
    bool resetSubmitRequested = false,
    bool clearMessages = false,
  }) {
    return OtpState(
      code: code ?? this.code,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      canResend: canResend ?? this.canResend,
      submitRequested: resetSubmitRequested
          ? false
          : (submitRequested ?? this.submitRequested),
      submitError: clearMessages
          ? null
          : (submitError == _otpNoChange ? this.submitError : submitError as String?),
      resendMessage: clearMessages
          ? null
          : (resendMessage == _otpNoChange ? this.resendMessage : resendMessage as String?),
      errorMessage: clearMessages
          ? null
          : (errorMessage == _otpNoChange ? this.errorMessage : errorMessage as String?),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
