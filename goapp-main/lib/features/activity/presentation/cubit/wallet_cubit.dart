import "package:flutter_bloc/flutter_bloc.dart";

class WalletState {
  const WalletState({
    required this.selectedMethod,
    required this.autoRefillEnabled,
  });

  final int selectedMethod;
  final bool autoRefillEnabled;

  WalletState copyWith({int? selectedMethod, bool? autoRefillEnabled}) {
    return WalletState(
      selectedMethod: selectedMethod ?? this.selectedMethod,
      autoRefillEnabled: autoRefillEnabled ?? this.autoRefillEnabled,
    );
  }
}

class WalletCubit extends Cubit<WalletState> {
  WalletCubit()
      : super(const WalletState(selectedMethod: 0, autoRefillEnabled: true));

  void selectMethod(int methodIndex) {
    emit(state.copyWith(selectedMethod: methodIndex));
  }

  void setAutoRefill(bool enabled) {
    emit(state.copyWith(autoRefillEnabled: enabled));
  }
}
