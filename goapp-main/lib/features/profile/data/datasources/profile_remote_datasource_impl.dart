import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import 'profile_remote_datasource.dart';
import '../models/profile_model.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ProfileModel> createProfile({
    required String name,
    required String gender,
    required String email,
    required String emergencyContact,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.profileCreate,
        data: {
          'name': name,
          'gender': gender,
          'email': email,
          'emergency_contact': emergencyContact,
        },
      );
      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Profile creation failed',
      );
    }
  }
}
