import 'package:shared_preferences/shared_preferences.dart';

class LocationPermissionStorage {
  static const denyCountKey = 'location_deny_count';
  final SharedPreferences prefs;

  LocationPermissionStorage(this.prefs);

  Future<int> getDenyCount() async {
    return prefs.getInt(denyCountKey) ?? 0;
  }

  Future<void> setDenyCount(int value) async {
    await prefs.setInt(denyCountKey, value);
  }
}
