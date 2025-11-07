import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/services/api/api.dart';
import '../data/services/api/api_response.dart';
import '../data/services/local_storage_service.dart';
import '../app/locator.dart';

class AuthService {
  final Api _api = locator<Api>();
  final LocalStorageService _storageService = locator<LocalStorageService>();

  // Hardcoded JWT token and user ID for temporary authentication
  static const String _tempJwtToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3ZDk4MTQ1ODE2Y2UxZjVkZTNkNGY3NiIsInN1YiI6IjY3ZDk4MTQ1ODE2Y2UxZjVkZTNkNGY3NiIsInJvbGUiOiJwbGF5ZXIiLCJpYXQiOjE3NDU4MzcxMDEsImV4cCI6MTc0NjQ0MTkwMX0.txQZUhd9VNGJDKQw1YKBFOFIuJhWN10n0rYQBTz6kyI";
  static const String _tempUserId = "67d98145816ce1f5de3d4f76";

  Future<ApiResponse> authenticateWithGoogle(String token) async {
    try {
      // Instead of calling the actual API, use the hardcoded token
      debugPrint('Using temporary JWT for Google authentication');

      // Save the hardcoded token to secure storage
      await _storageService.setStorageValue(
          LocalStorageKeys.accessToken, _tempJwtToken);

      // Save user ID for future use
      await _storageService.setStorageValue(
          LocalStorageKeys.userId, _tempUserId);

      // Update API service token
      _api.updateToken(_tempJwtToken);

      return ApiResponse(
        isSuccessful: true,
        token: _tempJwtToken,
        data: {'id': _tempUserId, 'role': 'player'},
        message: 'Authentication successful',
      );

      // Original implementation (commented out - uncomment when backend is ready)
      /*
      final body = {'token': token};

      final response = await _api.postData(
        '/api/auth/google',
        body,
        hasHeader: false,
      );

      if (response.isSuccessful && response.data != null) {
        // Save the token to secure storage
        if (response.token != null) {
          await _storageService.setStorageValue(
              LocalStorageKeys.accessToken, response.token!);

          // Update API service token
          _api.updateToken(response.token);
        }
      }

      return response;
      */
    } catch (e) {
      debugPrint('Error in temporary Google authentication: $e');
      return ApiResponse(
        isSuccessful: false,
        message: 'Authentication failed: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse> authenticateWithFacebook(String token) async {
    try {
      // Instead of calling the actual API, use the hardcoded token
      debugPrint('Using temporary JWT for Facebook authentication');

      // Save the hardcoded token to secure storage
      await _storageService.setStorageValue(
          LocalStorageKeys.accessToken, _tempJwtToken);

      // Save user ID for future use
      await _storageService.setStorageValue(
          LocalStorageKeys.userId, _tempUserId);

      // Update API service token
      _api.updateToken(_tempJwtToken);

      return ApiResponse(
        isSuccessful: true,
        token: _tempJwtToken,
        data: {'id': _tempUserId, 'role': 'player'},
        message: 'Authentication successful',
      );

      // Original implementation (commented out - uncomment when backend is ready)
      /*
      final body = {'token': token};

      final response = await _api.postData(
        '/api/auth/facebook',
        body,
        hasHeader: false,
      );

      if (response.isSuccessful && response.data != null) {
        // Save the token to secure storage
        if (response.token != null) {
          await _storageService.setStorageValue(
              LocalStorageKeys.accessToken, response.token!);

          // Update API service token
          _api.updateToken(response.token);
        }
      }

      return response;
      */
    } catch (e) {
      debugPrint('Error in temporary Facebook authentication: $e');
      return ApiResponse(
        isSuccessful: false,
        message: 'Authentication failed: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse> authenticateWithApple(String token) async {
    try {
      // Instead of calling the actual API, use the hardcoded token
      debugPrint('Using temporary JWT for Apple authentication');

      // Save the hardcoded token to secure storage
      await _storageService.setStorageValue(
          LocalStorageKeys.accessToken, _tempJwtToken);

      // Save user ID for future use
      await _storageService.setStorageValue(
          LocalStorageKeys.userId, _tempUserId);

      // Update API service token
      _api.updateToken(_tempJwtToken);

      return ApiResponse(
        isSuccessful: true,
        token: _tempJwtToken,
        data: {'id': _tempUserId, 'role': 'player'},
        message: 'Authentication successful',
      );

      // Original implementation (commented out - uncomment when backend is ready)
      /*
      final body = {'token': token};

      final response = await _api.postData(
        '/api/auth/apple',
        body,
        hasHeader: false,
      );

      if (response.isSuccessful && response.data != null) {
        // Save the token to secure storage
        if (response.token != null) {
          await _storageService.setStorageValue(
              LocalStorageKeys.accessToken, response.token!);

          // Update API service token
          _api.updateToken(response.token);
        }
      }

      return response;
      */
    } catch (e) {
      debugPrint('Error in temporary Apple authentication: $e');
      return ApiResponse(
        isSuccessful: false,
        message: 'Authentication failed: ${e.toString()}',
      );
    }
  }

  Future<bool> isAuthenticated() async {
    final token =
        await _storageService.getStorageValue(LocalStorageKeys.accessToken);
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await _storageService.removeStorageValue(LocalStorageKeys.accessToken);
    await _storageService.removeStorageValue(LocalStorageKeys.userId);
    _api.updateToken(null);
  }
}
