import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/auth_repository.dart';

class RequestOtpUseCase {
  final AuthRepository repository;

  RequestOtpUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String phone,
  }) {
    return repository.requestOtp(phone: phone);
  }
}
