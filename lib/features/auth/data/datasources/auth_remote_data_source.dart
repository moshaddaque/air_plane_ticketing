
import 'package:air_plane_ticketing/features/auth/data/models/register_request_model.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  AuthRemoteDataSource(
    this._apiClient,
    this._secureStorage,
  );

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      body: {
        'email': email,
        'password': password,
      },
    );

    return LoginResponseModel.fromJson(response);
  }

  
Future<UserModel> register(
  RegisterRequestModel request,
) async {
  final response = await _apiClient.post(
    '/api/v1/auth/register',
    body: request.toJson(),
  );

  return UserModel.fromJson(response);
}


  Future<UserModel> getCurrentUser() async {
    final token = await _secureStorage.getAccessToken();

    if (token == null || token.isEmpty) {
      throw const FormatException(
        'Access token not found.',
      );
    }

    final response = await _apiClient.get(
      ApiConstants.me,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return UserModel.fromJson(response);
  }
}
