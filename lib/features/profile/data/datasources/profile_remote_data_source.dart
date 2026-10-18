import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';

class ProfileRemoteDataSource {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  ProfileRemoteDataSource(this._apiClient, this._secureStorage);

  Future<void> uploadProfilePicture({
    required List<int> bytes,
    required String filename,
  }) async {
    final token = await _secureStorage.getAccessToken();

    if (token == null || token.trim().isEmpty) {
      throw Exception('Please log in before uploading a profile picture.');
    }

    await _apiClient.uploadFile(
      path: '/api/v1/auth/me/profile-picture',
      bytes: bytes,
      filename: filename,
      accessToken: token,
      fieldName: 'file',
    );
  }
}
