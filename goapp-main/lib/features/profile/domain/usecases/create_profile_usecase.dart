import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class CreateProfileUseCase {
  final ProfileRepository repository;

  CreateProfileUseCase(this.repository);

  Future<Either<Failure, Profile>> call({
    required String name,
    required String gender,
    required String email,
    required String emergencyContact,
  }) {
    return repository.createProfile(
      name: name,
      gender: gender,
      email: email,
      emergencyContact: emergencyContact,
    );
  }
}
