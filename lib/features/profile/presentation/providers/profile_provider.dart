
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileProvider(this._repository);

  bool _isUploading = false;
  String? _errorMessage;

  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  Future<bool> uploadProfilePicture({
    required List<int> bytes,
    required String filename,
  }) async {
    if (_isUploading) return false;

    if (bytes.isEmpty) {
      _errorMessage = 'The selected image is empty.';
      notifyListeners();
      return false;
    }

    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.uploadProfilePicture(
        bytes: bytes,
        filename: filename,
      );

      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e, stackTrace) {
      debugPrint('Profile picture upload failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      _errorMessage =
          'Could not upload the profile picture. Please try again.';
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
