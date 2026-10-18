import 'package:air_plane_ticketing/features/auth/data/models/register_request_model.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);

  @override
  Future<User> login({required String email, required String password}) async {
    final response = await _remoteDataSource.login(
      email: email.trim(),
      password: password,
    );

    // Save the token only after successful response parsing.
    await _secureStorage.saveAccessToken(response.accessToken);

    return response.user;
  }

  @override
  Future<User> getCurrentUser() async {
    return _remoteDataSource.getCurrentUser();
  }

  @override
  Future<bool> hasAccessToken() async {
    final token = await _secureStorage.getAccessToken();

    return token != null && token.trim().isNotEmpty;
  }

  @override
  Future<User> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final request = RegisterRequestModel(
      fullName: fullName,
      email: email,
      password: password,
    );

    return _remoteDataSource.register(request);
  }

  @override
  Future<void> logout() async {
    await _secureStorage.deleteAccessToken();
  }
}
