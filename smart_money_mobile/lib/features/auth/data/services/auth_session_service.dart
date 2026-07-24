import 'package:flutter/foundation.dart';
import 'token_storage_service.dart';

class AuthSessionService {
  const AuthSessionService({
    TokenStorageService tokenStorageService = const TokenStorageService(),
  }) : _tokenStorageService = tokenStorageService;

  final TokenStorageService _tokenStorageService;

  Future<bool> hasValidSession() async {
    try {
      final accessToken = await _tokenStorageService.getAccessToken();

      debugPrint(
        'TOKEN FOUND AFTER RELOAD: '
        '${accessToken != null && accessToken.isNotEmpty}',
      );

      return accessToken != null && accessToken.isNotEmpty;
    } catch (error) {
      debugPrint('TOKEN READ ERROR: $error');
      return false;
    }
  }
}
