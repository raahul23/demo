import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> createProfile({
    required String name,
    required String gender,
    required String email,
    required String emergencyContact,
  });
}
