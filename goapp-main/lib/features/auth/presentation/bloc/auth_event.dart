abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String phone;
  final String otp;
  final String? otpId;

  LoginRequested({required this.phone, required this.otp, this.otpId});
}

class RequestOtpRequested extends AuthEvent {
  final String phone;

  RequestOtpRequested({required this.phone});
}

class ResendOtpRequested extends AuthEvent {
  final String phone;

  ResendOtpRequested({required this.phone});
}
