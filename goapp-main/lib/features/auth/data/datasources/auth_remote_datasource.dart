import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<String> requestOtp({
    required String phone,
  });

  Future<UserModel> login({
    required String phone,
    required String otp,
    String? otpId,
  });

  Future<void> resendOtp({
    required String phone,
  });
}
