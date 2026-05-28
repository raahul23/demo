import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String phone,
    required String otp,
    String? otpId,
  }) {
    return repository.login(
      phone: phone,
      otp: otp,
      otpId: otpId,
    );
  }
}
