import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;

  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  // Initialize auth state
  Future<void> initializeAuth() async {
    _setState(AuthState.loading);
    
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        final userData = await AuthService.getUserData();
        if (userData != null) {
          _user = userData;
          _setState(AuthState.authenticated);
        } else {
          _setState(AuthState.unauthenticated);
        }
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Gagal menginisialisasi auth: ${e.toString()}');
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);
    
    try {
      final response = await AuthService.login(
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        _user = response.data!.user;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);
    
    try {
      final response = await AuthService.register(
        name: name,
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        _user = response.data!.user;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _setState(AuthState.loading);
    
    try {
      await AuthService.logout();
      _user = null;
      _setState(AuthState.unauthenticated);
    } catch (e) {
      // Even if logout fails, clear local data
      _user = null;
      _setState(AuthState.unauthenticated);
    }
  }

  // Refresh user info
  Future<void> refreshUserInfo() async {
    if (_state != AuthState.authenticated) return;
    
    try {
      final response = await AuthService.getUserInfo();
      if (response.success) {
        _user = response.data.user;
        notifyListeners();
      }
    } catch (e) {
      // If refresh fails, might need to re-authenticate
      _setError('Gagal memperbarui info user: ${e.toString()}');
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _setState(AuthState.unauthenticated);
    }
  }

  void _setState(AuthState newState) {
    _state = newState;
    if (newState != AuthState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = _cleanErrorMessage(error);
    _setState(AuthState.error);
  }

  String _cleanErrorMessage(String error) {
    // Remove common error prefixes
    String cleanError = error;
    
    // Remove "Exception: " prefix
    if (cleanError.startsWith('Exception: ')) {
      cleanError = cleanError.substring(11);
    }
    
    // Remove "Login gagal: Exception: " or similar patterns
    if (cleanError.contains('gagal: Exception: ')) {
      cleanError = cleanError.split('gagal: Exception: ').last;
    }
    
    // Remove "Registrasi gagal: Exception: " or similar patterns
    if (cleanError.contains('Registrasi gagal: Exception: ')) {
      cleanError = cleanError.split('Registrasi gagal: Exception: ').last;
    }
    
    // Remove any remaining "Exception: " that might be nested
    while (cleanError.startsWith('Exception: ')) {
      cleanError = cleanError.substring(11);
    }
    
    return cleanError.trim();
  }
}