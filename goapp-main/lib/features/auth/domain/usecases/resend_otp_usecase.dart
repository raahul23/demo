import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/auth_repository.dart';

class ResendOtpUseCase {
  final AuthRepository repository;

  ResendOtpUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String phone,
  }) {
    return repository.resendOtp(phone: phone);
  }
}
