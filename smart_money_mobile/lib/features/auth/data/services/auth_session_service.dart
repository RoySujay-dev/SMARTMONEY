// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

import '../models/refresh_token_request.dart';
import 'auth_api_service.dart';
import 'token_storage_service.dart';

class AuthSessionService {
  // Keep the public parameter name stable for callers/tests.
  AuthSessionService({
    TokenStorageService tokenStorageService = const TokenStorageService(),
    AuthApiService? authApiService,
  }) : _tokenStorageService = tokenStorageService,
       _authApiService = authApiService ?? AuthApiService(),
       _ownsAuthApiService = authApiService == null;

  final TokenStorageService _tokenStorageService;
  final AuthApiService _authApiService;
  final bool _ownsAuthApiService;

  Future<bool> hasValidSession() async {
    try {
      final accessToken = await _tokenStorageService.getAccessToken();
      final accessTokenExpiresAt =
          await _tokenStorageService.getAccessTokenExpiresAt();

      debugPrint(
        'TOKEN FOUND AFTER RELOAD: '
        '${accessToken != null && accessToken.isNotEmpty}',
      );

      if (accessToken != null &&
          accessToken.isNotEmpty &&
          accessTokenExpiresAt != null &&
          accessTokenExpiresAt.isAfter(
            DateTime.now().toUtc().add(const Duration(seconds: 30)),
          )) {
        return true;
      }

      return _refreshAccessToken();
    } catch (error) {
      debugPrint('TOKEN READ ERROR: $error');
      return false;
    }
  }

  Future<bool> _refreshAccessToken() async {
    final refreshToken = await _tokenStorageService.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      await _tokenStorageService.clearTokens();
      return false;
    }

    try {
      final response = await _authApiService.refreshToken(
        RefreshTokenRequest(refreshToken: refreshToken),
      );

      await _tokenStorageService.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        accessTokenExpiresAt: response.accessTokenExpiresAt,
      );

      return true;
    } catch (error) {
      debugPrint('TOKEN REFRESH ERROR: $error');
      await _tokenStorageService.clearTokens();
      return false;
    }
  }

  void dispose() {
    if (_ownsAuthApiService) {
      _authApiService.dispose();
    }
  }
}
