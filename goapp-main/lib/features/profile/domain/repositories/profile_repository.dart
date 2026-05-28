import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Profile>> createProfile({
    required String name,
    required String gender,
    required String email,
    required String emergencyContact,
  });

  Future<Either<Failure, Profile?>> getCachedProfile();
}
