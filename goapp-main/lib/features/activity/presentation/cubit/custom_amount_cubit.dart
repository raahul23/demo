import "package:flutter_bloc/flutter_bloc.dart";

class EnterCustomAmountState {
  const EnterCustomAmountState({
    required this.amount,
    required this.minAmount,
    required this.maxAmount,
  });

  final String amount;
  final double minAmount;
  final double maxAmount;

  bool get isValidAmount {
    if (amount.isEmpty) return false;
    final value = double.tryParse(amount) ?? 0;
    return value >= minAmount && value <= maxAmount;
  }

  double? get parsedAmount => double.tryParse(amount);

  EnterCustomAmountState copyWith({
    String? amount,
    double? minAmount,
    double? maxAmount,
  }) {
    return EnterCustomAmountState(
      amount: amount ?? this.amount,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
    );
  }
}

class EnterCustomAmountCubit extends Cubit<EnterCustomAmountState> {
  EnterCustomAmountCubit({
    String? initialAmount,
    double minAmount = 100,
    double maxAmount = 50000,
  }) : super(
    EnterCustomAmountState(
      amount: initialAmount ?? "550",
      minAmount: minAmount,
      maxAmount: maxAmount,
    ),
  );

  void onKeyPress(String key) {
    final amount = state.amount;
    if (key == "backspace") {
      if (amount.isEmpty) return;
      emit(state.copyWith(amount: amount.substring(0, amount.length - 1)));
      return;
    }

    if (key == ".") {
      if (amount.contains(".")) return;
      emit(state.copyWith(amount: "$amount$key"));
      return;
    }

    final newAmount = "$amount$key";
    final value = double.tryParse(newAmount) ?? 0;
    if (value > state.maxAmount) return;
    emit(state.copyWith(amount: newAmount));
  }
}
