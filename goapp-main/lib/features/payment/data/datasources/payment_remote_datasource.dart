import '../../domain/entities/payment_option.dart';

abstract class PaymentRemoteDataSource {
  Future<List<PaymentOption>> fetchOptions({required double amount});

  Future<bool> submitPayment({
    required String optionId,
    required double amount,
  });
}
