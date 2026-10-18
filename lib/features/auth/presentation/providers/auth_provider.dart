import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider(this._repository);

  bool _isLoading = false;
  User? _user;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  Future<bool> login({required String email, required String password}) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repository.login(email: email, password: password);

      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } on FormatException {
      _errorMessage = 'Invalid login response from server.';
      return false;
    } catch (_) {
      _errorMessage = 'Login failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.register(
        fullName: fullName.trim(),
        email: email.trim(),
        password: password,
      );

      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } on FormatException {
      _errorMessage = 'Invalid registration response from server.';
      return false;
    } catch (_) {
      _errorMessage = 'Registration failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool?> checkAuthStatus() async {
    if (_isLoading) return null;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // No token means the user is not authenticated.
      final hasToken = await _repository.hasAccessToken();

      if (!hasToken) {
        _user = null;
        return false;
      }

      // Verify the stored token with the backend.
      _user = await _repository.getCurrentUser();

      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await _repository.logout();
        _user = null;
        return false;
      }

      _errorMessage = e.message;
      return null;
    } on FormatException {
      // A malformed authentication response is not proof
      // that the saved token is invalid.
      _errorMessage = 'Invalid authentication response.';
      return null;
    } catch (_) {
      _errorMessage = 'Unable to verify your session. Check your connection.';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> refreshCurrentUser() async {
  try {
    final currentUser = await _repository.getCurrentUser();

    _user = currentUser;
    notifyListeners();

    return true;
  } catch (e) {
    _errorMessage = 'Failed to refresh profile information.';
    notifyListeners();

    return false;
  }

}
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
