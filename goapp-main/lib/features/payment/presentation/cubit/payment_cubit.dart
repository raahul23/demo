import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/payment_option.dart';
import '../../domain/usecases/get_payment_options_usecase.dart';
import '../../domain/usecases/submit_payment_usecase.dart';
import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final GetPaymentOptionsUseCase getPaymentOptionsUseCase;
  final SubmitPaymentUseCase submitPaymentUseCase;
  final double amount;

  PaymentCubit({
    required this.getPaymentOptionsUseCase,
    required this.submitPaymentUseCase,
    required this.amount,
  }) : super(PaymentState.initial()) {
    loadOptions();
  }

  Future<void> loadOptions() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final options = await getPaymentOptionsUseCase(amount: amount);
      emit(
        state.copyWith(
          options: options,
          selected: options.isNotEmpty ? options.first : null,
          loading: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          loading: false,
          errorMessage: 'Failed to load payment options',
        ),
      );
    }
  }

  void selectOption(PaymentOption option) {
    emit(state.copyWith(selected: option, clearError: true));
  }

  Future<void> pay() async {
    if (state.selected == null) {
      emit(state.copyWith(errorMessage: 'Select a payment method'));
      return;
    }
    emit(state.copyWith(processing: true, clearError: true));
    try {
      final success = await submitPaymentUseCase(
        optionId: state.selected!.id,
        amount: amount,
      );
      emit(
        state.copyWith(
          processing: false,
          success: success,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          processing: false,
          errorMessage: 'Payment failed. Try again.',
        ),
      );
    }
  }

  void clearSuccess() {
    emit(state.copyWith(success: false));
  }
}
