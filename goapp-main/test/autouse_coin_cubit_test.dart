import "package:flutter_test/flutter_test.dart";
import "package:goapp/features/activity/presentation/cubit/autouse_coin_cubit.dart";

void main() {
  group("AutoUseCoinCubit", () {
    test("starts enabled by default", () {
      final cubit = AutoUseCoinCubit();
      expect(cubit.state, isTrue);
    });

    test("updates enabled state", () {
      final cubit = AutoUseCoinCubit();
      cubit.setEnabled(false);
      expect(cubit.state, isFalse);
    });
  });
}
