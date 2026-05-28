import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> requestOtp({
    required String phone,
  });

  Future<Either<Failure, User>> login({
    required String phone,
    required String otp,
    String? otpId,
  });

  Future<Either<Failure, void>> resendOtp({
    required String phone,
  });

  Future<bool> isLoggedIn();
  Future<void> logout();
}
