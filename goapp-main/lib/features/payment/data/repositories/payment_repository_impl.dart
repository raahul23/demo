import '../../domain/entities/payment_option.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PaymentOption>> getPaymentOptions({
    required double amount,
  }) {
    return remoteDataSource.fetchOptions(amount: amount);
  }

  @override
  Future<bool> pay({
    required String optionId,
    required double amount,
  }) {
    return remoteDataSource.submitPayment(
      optionId: optionId,
      amount: amount,
    );
  }
}
