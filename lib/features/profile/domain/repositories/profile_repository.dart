abstract class ProfileRepository {
  Future<void> uploadProfilePicture({
    required List<int> bytes,
    required String filename,
  });
}
