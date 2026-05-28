import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile_model.dart';
import 'profile_local_datasource.dart';

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  static const _profileKey = 'profile_cache';

  final SharedPreferences prefs;

  ProfileLocalDataSourceImpl(this.prefs);

  @override
  Future<void> cacheProfile(ProfileModel profile) async {
    final jsonString = jsonEncode(profile.toJson());
    await prefs.setString(_profileKey, jsonString);
  }

  @override
  Future<ProfileModel?> getCachedProfile() async {
    final jsonString = prefs.getString(_profileKey);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    return ProfileModel.fromJson(jsonMap);
  }

  @override
  Future<void> clearProfile() async {
    await prefs.remove(_profileKey);
  }
}
