import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/payment_option.dart';
import 'payment_remote_datasource.dart';

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiClient _apiClient;

  PaymentRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<PaymentOption>> fetchOptions({required double amount}) async {
    try {
      final response = await _apiClient.get(
        '/payments/options',
        queryParameters: {'amount': amount},
      );
      final List<dynamic> data = response.data as List<dynamic>? ?? [];
      return data.map((json) => _optionFromJson(json as Map<String, dynamic>)).toList();
    } on DioException {
      return _fallbackOptions();
    }
  }

  PaymentOption _optionFromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'cash';
    final PaymentMethodType type;
    switch (typeStr) {
      case 'upi':
        type = PaymentMethodType.upi;
      case 'card':
        type = PaymentMethodType.card;
      case 'wallet':
        type = PaymentMethodType.wallet;
      default:
        type = PaymentMethodType.cash;
    }

    return PaymentOption(
      id: json['id'] as String,
      type: type,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      isRecommended: json['is_recommended'] as bool? ?? false,
    );
  }

  @override
  Future<bool> submitPayment({
    required String optionId,
    required double amount,
  }) async {
    try {
      await _apiClient.post(
        '/payments/submit',
        data: {'option_id': optionId, 'amount': amount},
      );
      return true;
    } on DioException {
      return false;
    }
  }

  List<PaymentOption> _fallbackOptions() => const [
        PaymentOption(
          id: 'cash',
          type: PaymentMethodType.cash,
          title: 'Cash',
          subtitle: 'Pay cash to driver',
          isRecommended: true,
        ),
        PaymentOption(
          id: 'upi',
          type: PaymentMethodType.upi,
          title: 'UPI',
          subtitle: 'Pay via UPI apps',
          isRecommended: false,
        ),
      ];
}
