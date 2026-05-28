import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/payment/domain/entities/payment_option.dart';
import 'package:goapp/features/payment/domain/repositories/payment_repository.dart';
import 'package:goapp/features/payment/domain/usecases/get_payment_options_usecase.dart';
import 'package:goapp/features/payment/domain/usecases/submit_payment_usecase.dart';
import 'package:goapp/features/payment/presentation/cubit/payment_cubit.dart';

class FakePaymentRepository implements PaymentRepository {
  List<PaymentOption> options = const [
    PaymentOption(
      id: 'upi',
      type: PaymentMethodType.upi,
      title: 'UPI',
      subtitle: 'UPI',
      isRecommended: true,
    ),
    PaymentOption(
      id: 'cash',
      type: PaymentMethodType.cash,
      title: 'Cash',
      subtitle: 'Cash',
      isRecommended: false,
    ),
  ];

  String? lastOptionId;
  double? lastAmount;

  @override
  Future<List<PaymentOption>> getPaymentOptions({
    required double amount,
  }) async {
    return options;
  }

  @override
  Future<bool> pay({
    required String optionId,
    required double amount,
  }) async {
    lastOptionId = optionId;
    lastAmount = amount;
    return true;
  }
}

void main() {
  test('loads options and selects', () async {
    final repo = FakePaymentRepository();
    final cubit = PaymentCubit(
      getPaymentOptionsUseCase: GetPaymentOptionsUseCase(repo),
      submitPaymentUseCase: SubmitPaymentUseCase(repo),
      amount: 100,
    );

    await cubit.loadOptions();

    expect(cubit.state.options.length, 2);
    expect(cubit.state.loading, false);

    cubit.selectOption(cubit.state.options.first);
    expect(cubit.state.selected?.id, 'upi');

    await cubit.pay();
    expect(cubit.state.success, true);
    expect(repo.lastOptionId, 'upi');
    expect(repo.lastAmount, 100);

    await cubit.close();
  });
}
