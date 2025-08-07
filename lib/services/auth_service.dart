import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_response.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Login user
  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: ApiConstants.loginEndpoint,
        body: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response);
      
      if (authResponse.success && authResponse.data != null) {
        // Save token and user data
        await _saveAuthData(authResponse.data!);
      } else if (!authResponse.success) {
        // Jika success = false, lempar error dengan message dari API
        throw Exception(authResponse.message);
      }

      return authResponse;
    } catch (e) {
      // Re-throw error tanpa menambah prefix
      rethrow;
    }
  }

  // Register user
  static Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: ApiConstants.registerEndpoint,
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response);
      
      if (authResponse.success && authResponse.data != null) {
        // Save token and user data
        await _saveAuthData(authResponse.data!);
      } else if (!authResponse.success) {
        // Jika success = false, lempar error dengan message dari API
        throw Exception(authResponse.message);
      }

      return authResponse;
    } catch (e) {
      // Re-throw error tanpa menambah prefix
      rethrow;
    }
  }

  // Get user info
  static Future<UserInfoResponse> getUserInfo() async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await ApiService.get(
        endpoint: ApiConstants.userInfoEndpoint,
        token: token,
      );

      return UserInfoResponse.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mendapatkan info user: ${e.toString()}');
    }
  }

  // Logout user
  static Future<void> logout() async {
    try {
      final token = await getAccessToken();
      if (token != null) {
        await ApiService.post(
          endpoint: ApiConstants.logoutEndpoint,
          body: {},
          token: token,
        );
      }
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      // Always clear local data
      await clearAuthData();
    }
  }

  // Save authentication data
  static Future<void> _saveAuthData(AuthData authData) async {
    await _storage.write(
      key: ApiConstants.accessTokenKey,
      value: authData.accessToken,
    );
    await _storage.write(
      key: ApiConstants.userDataKey,
      value: jsonEncode(authData.user.toJson()),
    );
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: ApiConstants.accessTokenKey);
  }

  // Get user data
  static Future<User?> getUserData() async {
    final userDataString = await _storage.read(key: ApiConstants.userDataKey);
    if (userDataString != null) {
      final userDataJson = jsonDecode(userDataString);
      return User.fromJson(userDataJson);
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }

  // Clear authentication data
  static Future<void> clearAuthData() async {
    await _storage.delete(key: ApiConstants.accessTokenKey);
    await _storage.delete(key: ApiConstants.userDataKey);
  }
}