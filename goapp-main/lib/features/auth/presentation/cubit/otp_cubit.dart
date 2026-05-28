import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import '../../../../core/error/failures.dart';

part 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  static const int otpLength = 4;
  static const int _maxOtpLength = 6;
  final ResendOtpUseCase resendOtpUseCase;
  Timer? _timer;

  OtpCubit({
    required this.resendOtpUseCase,
    bool startTimer = true,
  }) : super(OtpState.initial()) {
    if (startTimer) {
      _startTimer();
    }
  }

  void updateCode(String code) {
    emit(state.copyWith(code: code));
  }

  Future<void> submit(String phoneNumber, String otpId) async {
    final length = state.code.length;
    if (length < otpLength || length > _maxOtpLength) {
      emit(
        state.copyWith(
          submitError: 'Enter 4 to 6 digit OTP',
          submitRequested: false,
          isLoading: false,
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, submitError: null));

    // Development/testing flow: accept any 4-6 digit OTP.
    await Future.delayed(const Duration(milliseconds: 800));

    if (state.code.length >= otpLength && state.code.length <= _maxOtpLength) {
      emit(
        state.copyWith(
          isLoading: false,
          submitRequested: true,
          submitError: null,
        ),
      );
    } else {
      emit(
        state.copyWith(
          isLoading: false,
          submitError: 'Invalid OTP',
          submitRequested: false,
        ),
      );
    }
  }

  Future<void> resend(String phone) async {
    if (!state.canResend) return;
    
    emit(state.copyWith(isLoading: true));
    
    final result = await resendOtpUseCase(phone: phone);
    
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: _messageForFailure(failure),
            resendMessage: null,
          ),
        );
      },
      (_) {
        _startTimer();
        emit(
          state.copyWith(
            isLoading: false,
            resendMessage: 'OTP resent successfully',
            errorMessage: null,
          ),
        );
      },
    );
  }

  void consumeActions() {
    emit(state.copyWith(
      resetSubmitRequested: true,
      clearMessages: true,
      isLoading: false,
    ));
  }

  void _startTimer() {
    _timer?.cancel();
    emit(state.copyWith(secondsLeft: 30, canResend: false));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsLeft <= 1) {
        timer.cancel();
        emit(state.copyWith(secondsLeft: 0, canResend: true));
        return;
      }
      emit(state.copyWith(secondsLeft: state.secondsLeft - 1));
    });
  }

  String _messageForFailure(Failure failure) {
    return failure.message;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
