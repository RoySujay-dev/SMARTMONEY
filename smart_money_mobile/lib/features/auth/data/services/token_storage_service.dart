// ignore_for_file: prefer_initializing_formals

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorageService {
  // Keep the public parameter name stable for callers/tests.
  const TokenStorageService({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _accessTokenExpiresAtKey = 'access_token_expires_at';

  final FlutterSecureStorage _storage;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiresAt,
  }) async {
    final expiresAt = accessTokenExpiresAt.toUtc().toIso8601String();
    final preferences = await SharedPreferences.getInstance();

    await Future.wait([
      preferences.setString(_accessTokenKey, accessToken),
      preferences.setString(_refreshTokenKey, refreshToken),
      preferences.setString(_accessTokenExpiresAtKey, expiresAt),
    ]);

    await _trySecureWrite(_accessTokenKey, accessToken);
    await _trySecureWrite(_refreshTokenKey, refreshToken);
    await _trySecureWrite(_accessTokenExpiresAtKey, expiresAt);
  }

  Future<String?> getAccessToken() async {
    return _readToken(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _readToken(_refreshTokenKey);
  }

  Future<DateTime?> getAccessTokenExpiresAt() async {
    final value = await _readToken(_accessTokenExpiresAtKey);

    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value)?.toUtc();
  }

  Future<void> clearTokens() async {
    final preferences = await SharedPreferences.getInstance();

    await Future.wait([
      preferences.remove(_accessTokenKey),
      preferences.remove(_refreshTokenKey),
      preferences.remove(_accessTokenExpiresAtKey),
    ]);

    await _trySecureDelete(_accessTokenKey);
    await _trySecureDelete(_refreshTokenKey);
    await _trySecureDelete(_accessTokenExpiresAtKey);
  }

  Future<String?> _readToken(String key) async {
    try {
      final secureValue = await _storage.read(key: key);

      if (secureValue != null && secureValue.isNotEmpty) {
        return secureValue;
      }
    } catch (_) {
      // Some web/browser contexts can reject secure storage reads after reload.
    }

    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(key);
  }

  Future<void> _trySecureWrite(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      // SharedPreferences is the durable fallback for web reload sessions.
    }
  }

  Future<void> _trySecureDelete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {
      // The preference copy has already been cleared.
    }
  }
}
