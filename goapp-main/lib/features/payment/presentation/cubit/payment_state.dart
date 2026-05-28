import '../../domain/entities/payment_option.dart';

class PaymentState {
  final List<PaymentOption> options;
  final PaymentOption? selected;
  final bool loading;
  final bool processing;
  final bool success;
  final String? errorMessage;

  const PaymentState({
    required this.options,
    required this.selected,
    required this.loading,
    required this.processing,
    required this.success,
    required this.errorMessage,
  });

  factory PaymentState.initial() {
    return const PaymentState(
      options: [],
      selected: null,
      loading: true,
      processing: false,
      success: false,
      errorMessage: null,
    );
  }

  PaymentState copyWith({
    List<PaymentOption>? options,
    PaymentOption? selected,
    bool? loading,
    bool? processing,
    bool? success,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaymentState(
      options: options ?? this.options,
      selected: selected ?? this.selected,
      loading: loading ?? this.loading,
      processing: processing ?? this.processing,
      success: success ?? this.success,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
