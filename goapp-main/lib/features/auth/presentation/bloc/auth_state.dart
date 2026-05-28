import '../../domain/entities/user.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;

  AuthSuccess(this.user);
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}

class OtpRequestSuccess extends AuthState {
  final String otpId;

  OtpRequestSuccess(this.otpId);
}

class OtpResendSuccess extends AuthState {
  final String message;

  OtpResendSuccess(this.message);
}
