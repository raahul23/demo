import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/services/phone_number_service.dart';
import 'login_form_state.dart';

class LoginFormCubit extends Cubit<LoginFormState> {
  final PhoneNumberService phoneNumberService;

  LoginFormCubit({required this.phoneNumberService})
    : super(LoginFormState.initial());

  void onInputChanged(String raw) {
    final digits = phoneNumberService.digitsOnly(raw);
    final cappedDigits = digits.length > 10 ? digits.substring(0, 10) : digits;
    final formatted = phoneNumberService.formatIndian(cappedDigits);
    final error = phoneNumberService.validateIndian(cappedDigits);
    final e164 = error == null ? phoneNumberService.toE164(cappedDigits) : null;
    emit(
      state.copyWith(
        formatted: formatted,
        digits: cappedDigits,
        error: error,
        phoneE164: e164,
        canSubmit: error == null && cappedDigits.length == 10,
      ),
    );
  }

  void submit() {
    if (state.canSubmit && state.phoneE164 != null) {
      emit(state.copyWith(submitRequested: true, submitError: null));
      return;
    }
    final error =
        state.error ?? phoneNumberService.validateIndian(state.formatted);
    emit(state.copyWith(showValidation: true, error: error, submitError: error));
  }

  void consumeSubmit() {
    emit(state.copyWith(resetSubmitRequested: true, clearSubmitError: true));
  }
}
