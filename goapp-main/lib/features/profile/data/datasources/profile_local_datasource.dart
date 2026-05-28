import '../models/profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<void> cacheProfile(ProfileModel profile);

  Future<ProfileModel?> getCachedProfile();

  Future<void> clearProfile();
}
