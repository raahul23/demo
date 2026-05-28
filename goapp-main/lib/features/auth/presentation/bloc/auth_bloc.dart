import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/request_otp_usecase.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RequestOtpUseCase requestOtpUseCase;
  final ResendOtpUseCase resendOtpUseCase;

  AuthBloc(this.loginUseCase, this.requestOtpUseCase, this.resendOtpUseCase)
    : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RequestOtpRequested>(_onRequestOtpRequested);
    on<ResendOtpRequested>(_onResendOtpRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginUseCase(
      phone: event.phone,
      otp: event.otp,
      otpId: event.otpId,
    );

    result.fold(
      (failure) {
        emit(AuthFailure(_messageForFailure(failure)));
      },
      (user) {
        emit(AuthSuccess(user));
      },
    );
  }

  Future<void> _onRequestOtpRequested(
    RequestOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await requestOtpUseCase(phone: event.phone);
    result.fold(
      (failure) => emit(AuthFailure(_messageForFailure(failure))),
      (otpId) => emit(OtpRequestSuccess(otpId)),
    );
  }

  Future<void> _onResendOtpRequested(
    ResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await resendOtpUseCase(phone: event.phone);
    result.fold(
      (failure) => emit(AuthFailure(_messageForFailure(failure))),
      (_) => emit(OtpResendSuccess('OTP resent')),
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
