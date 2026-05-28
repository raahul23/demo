import '../entities/payment_option.dart';
import '../repositories/payment_repository.dart';

class GetPaymentOptionsUseCase {
  final PaymentRepository repository;

  GetPaymentOptionsUseCase(this.repository);

  Future<List<PaymentOption>> call({required double amount}) {
    return repository.getPaymentOptions(amount: amount);
  }
}
