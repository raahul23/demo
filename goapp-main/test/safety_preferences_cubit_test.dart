import "package:flutter_test/flutter_test.dart";
import "package:goapp/features/activity/presentation/cubit/safety_preference_cubit.dart";

void main() {
  group("SafetyPreferencesCubit", () {
    test("has default preference values", () {
      final cubit = SafetyPreferencesCubit();
      expect(cubit.state.autoShare, isTrue);
      expect(cubit.state.shareAtNight, isFalse);
    });

    test("updates both preferences", () {
      final cubit = SafetyPreferencesCubit();
      cubit.setAutoShare(false);
      cubit.setShareAtNight(true);
      expect(cubit.state.autoShare, isFalse);
      expect(cubit.state.shareAtNight, isTrue);
    });
  });
}
