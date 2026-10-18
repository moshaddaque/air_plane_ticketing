import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> uploadProfilePicture({
    required List<int> bytes,
    required String filename,
  }) {
    return _remoteDataSource.uploadProfilePicture(
      bytes: bytes,
      filename: filename,
    );
  }
}
