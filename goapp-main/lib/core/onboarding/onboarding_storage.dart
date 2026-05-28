import 'package:shared_preferences/shared_preferences.dart';

enum OnboardingStage {
  none,
  profile,
  location,
  done,
}

class OnboardingStorage {
  static const _key = 'onboarding_stage';
  static const _authIntroSeenKey = 'auth_intro_seen';

  final SharedPreferences prefs;

  OnboardingStorage(this.prefs);

  Future<OnboardingStage> getStage() async {
    final value = prefs.getString(_key);
    return _fromString(value);
  }

  Future<void> setStage(OnboardingStage stage) async {
    await prefs.setString(_key, stage.name);
  }

  Future<void> clear() async {
    await prefs.remove(_key);
  }

  Future<bool> getAuthIntroSeen() async {
    return prefs.getBool(_authIntroSeenKey) ?? false;
  }

  Future<void> setAuthIntroSeen(bool seen) async {
    await prefs.setBool(_authIntroSeenKey, seen);
  }

  OnboardingStage _fromString(String? value) {
    switch (value) {
      case 'profile':
        return OnboardingStage.profile;
      case 'location':
        return OnboardingStage.location;
      case 'done':
        return OnboardingStage.done;
      default:
        return OnboardingStage.none;
    }
  }
}
