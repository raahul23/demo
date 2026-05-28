import "package:flutter_test/flutter_test.dart";
import "package:goapp/features/activity/presentation/cubit/custom_amount_cubit.dart";

void main() {
  group("EnterCustomAmountCubit", () {
    test("uses default initial amount and validation", () {
      final cubit = EnterCustomAmountCubit();
      expect(cubit.state.amount, "550");
      expect(cubit.state.isValidAmount, isTrue);
    });

    test("handles numeric key input and backspace", () {
      final cubit = EnterCustomAmountCubit(initialAmount: "10");
      cubit.onKeyPress("2");
      expect(cubit.state.amount, "102");
      cubit.onKeyPress("backspace");
      expect(cubit.state.amount, "10");
    });

    test("allows only one decimal separator", () {
      final cubit = EnterCustomAmountCubit(initialAmount: "12");
      cubit.onKeyPress(".");
      cubit.onKeyPress("3");
      cubit.onKeyPress(".");
      expect(cubit.state.amount, "12.3");
    });

    test("does not exceed max amount", () {
      final cubit = EnterCustomAmountCubit(initialAmount: "99", maxAmount: 100);
      cubit.onKeyPress("9");
      expect(cubit.state.amount, "99");
    });

    test("validates minimum and maximum bounds", () {
      final cubit = EnterCustomAmountCubit(
        initialAmount: "150",
        minAmount: 100,
        maxAmount: 200,
      );
      expect(cubit.state.isValidAmount, isTrue);

      final invalidLow = EnterCustomAmountCubit(
        initialAmount: "50",
        minAmount: 100,
        maxAmount: 200,
      );
      expect(invalidLow.state.isValidAmount, isFalse);
    });
  });
}
