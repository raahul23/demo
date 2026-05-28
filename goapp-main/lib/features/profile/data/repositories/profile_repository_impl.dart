import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Profile>> createProfile({
    required String name,
    required String gender,
    required String email,
    required String emergencyContact,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final profile = await remoteDataSource.createProfile(
        name: name,
        gender: gender,
        email: email,
        emergencyContact: emergencyContact,
      );
      await localDataSource.cacheProfile(profile);
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, Profile?>> getCachedProfile() async {
    try {
      final profile = await localDataSource.getCachedProfile();
      return Right(profile);
    } catch (_) {
      return const Left(CacheFailure('Failed to read profile'));
    }
  }
}
