import '../entities/payment_option.dart';

abstract class PaymentRepository {
  Future<List<PaymentOption>> getPaymentOptions({
    required double amount,
  });

  Future<bool> pay({
    required String optionId,
    required double amount,
  });
}
