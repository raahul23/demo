import 'package:dio/dio.dart';
import 'package:goapp/core/network/api_client.dart';
import 'package:goapp/core/network/api_endpoints.dart';

import '../../../../core/error/exceptions.dart';
import 'auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<String> requestOtp({required String phone}) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.authRequestOtp,
        data: {
          'phone': phone,
        },
      );
      return response.data['otp_id'] ?? '';
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to send OTP',
      );
    }
  }

  @override
  Future<UserModel> login({
    required String phone,
    required String otp,
    String? otpId,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.authLogin,
        data: {
          'phone': phone,
          'otp': otp,
          'otp_id': otpId,
        },
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Login failed',
      );
    }
  }

  @override
  Future<void> resendOtp({required String phone}) async {
    try {
      await apiClient.post(
        ApiEndpoints.authResendOtp,
        data: {
          'phone': phone,
        },
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Resend OTP failed',
      );
    }
  }
}
