import "package:flutter_test/flutter_test.dart";
import "package:goapp/features/activity/presentation/cubit/wallet_cubit.dart";

void main() {
  group("WalletCubit", () {
    test("has default state", () {
      final cubit = WalletCubit();
      expect(cubit.state.selectedMethod, 0);
      expect(cubit.state.autoRefillEnabled, isTrue);
    });

    test("selects payment method", () {
      final cubit = WalletCubit();
      cubit.selectMethod(2);
      expect(cubit.state.selectedMethod, 2);
    });

    test("toggles auto-refill", () {
      final cubit = WalletCubit();
      cubit.setAutoRefill(false);
      expect(cubit.state.autoRefillEnabled, isFalse);
    });
  });
}
