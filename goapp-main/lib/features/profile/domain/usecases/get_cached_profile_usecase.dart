import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetCachedProfileUseCase {
  final ProfileRepository repository;

  GetCachedProfileUseCase(this.repository);

  Future<Either<Failure, Profile?>> call() {
    return repository.getCachedProfile();
  }
}
