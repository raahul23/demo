import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/core/onboarding/onboarding_storage.dart';
import 'package:goapp/features/auth/presentation/cubit/auth_onboarding_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('loads seen=false by default and can mark seen', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final cubit = AuthOnboardingCubit(OnboardingStorage(prefs));
    addTearDown(cubit.close);

    await Future<void>.delayed(const Duration(milliseconds: 1));
    expect(cubit.state.loading, false);
    expect(cubit.state.seen, false);

    await cubit.markSeen();
    expect(cubit.state.seen, true);
    expect(prefs.getBool('auth_intro_seen'), true);
  });

  test('loads seen=true when persisted', () async {
    SharedPreferences.setMockInitialValues({'auth_intro_seen': true});
    final prefs = await SharedPreferences.getInstance();
    final cubit = AuthOnboardingCubit(OnboardingStorage(prefs));
    addTearDown(cubit.close);

    await Future<void>.delayed(const Duration(milliseconds: 1));
    expect(cubit.state.loading, false);
    expect(cubit.state.seen, true);
  });
}
