import '../repositories/payment_repository.dart';

class SubmitPaymentUseCase {
  final PaymentRepository repository;

  SubmitPaymentUseCase(this.repository);

  Future<bool> call({
    required String optionId,
    required double amount,
  }) {
    return repository.pay(optionId: optionId, amount: amount);
  }
}
