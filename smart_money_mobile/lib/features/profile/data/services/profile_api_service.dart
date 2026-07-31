// ignore_for_file: prefer_initializing_formals

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../auth/data/models/refresh_token_request.dart';
import '../../../auth/data/services/auth_api_service.dart';
import '../../../auth/data/services/token_storage_service.dart';
import '../models/profile_response.dart';

class ProfileApiService {
  ProfileApiService({
    http.Client? client,
    TokenStorageService tokenStorageService = const TokenStorageService(),
    AuthApiService? authApiService,
    this.baseUrl = 'http://localhost:5256',
  }) : _client = client ?? http.Client(),
       _tokenStorageService = tokenStorageService,
       _authApiService = authApiService ?? AuthApiService(baseUrl: baseUrl),
       _ownsAuthApiService = authApiService == null;

  final http.Client _client;
  final TokenStorageService _tokenStorageService;
  final AuthApiService _authApiService;
  final bool _ownsAuthApiService;
  final String baseUrl;

  Future<ProfileResponse> getProfile() async {
    final response = await _sendAuthorizedRequest(
      (headers) => _client.get(
        Uri.parse('$baseUrl/api/profile'),
        headers: headers,
      ),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Profile load failed with status ${response.statusCode}: '
        '${response.body}',
      );
    }

    final decodedBody = jsonDecode(response.body);

    if (decodedBody is! Map<String, dynamic>) {
      throw const FormatException('Invalid profile response.');
    }

    return ProfileResponse.fromJson(decodedBody);
  }

  Future<ProfileResponse> updateName(String name) async {
    final response = await _sendAuthorizedRequest(
      (headers) => _client.put(
        Uri.parse('$baseUrl/api/profile/update-name'),
        headers: headers,
        body: jsonEncode({'name': name}),
      ),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Name update failed with status ${response.statusCode}: '
        '${response.body}',
      );
    }

    final decodedBody = jsonDecode(response.body);

    if (decodedBody is! Map<String, dynamic>) {
      throw const FormatException('Invalid profile response.');
    }

    return ProfileResponse.fromJson(decodedBody);
  }

  Future<void> changePassword(String newPassword) async {
    final response = await _sendAuthorizedRequest(
      (headers) => _client.put(
        Uri.parse('$baseUrl/api/profile/change-password'),
        headers: headers,
        body: jsonEncode({'newPassword': newPassword}),
      ),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Password update failed with status ${response.statusCode}: '
        '${response.body}',
      );
    }
  }

  Future<ProfileResponse> uploadProfilePhoto({
    required List<int> bytes,
    required String fileName,
    required String contentType,
  }) async {
    final response = await _sendAuthorizedRequest((headers) async {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/profile/photo'),
      );

      request.headers['Authorization'] = headers['Authorization'] ?? '';
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: fileName,
          contentType: MediaType.parse(contentType),
        ),
      );

      final streamedResponse = await _client.send(request);
      return http.Response.fromStream(streamedResponse);
    });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Profile photo upload failed with status ${response.statusCode}: '
        '${response.body}',
      );
    }

    final decodedBody = jsonDecode(response.body);

    if (decodedBody is! Map<String, dynamic>) {
      throw const FormatException('Invalid profile response.');
    }

    return ProfileResponse.fromJson(decodedBody);
  }

  Future<Map<String, String>> _authorizedHeaders() async {
    final token = await _tokenStorageService.getAccessToken();

    if (token == null || token.isEmpty) {
      throw StateError('No access token is available.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _sendAuthorizedRequest(
    Future<http.Response> Function(Map<String, String> headers) send,
  ) async {
    final response = await send(await _authorizedHeaders());

    if (response.statusCode != 401) {
      return response;
    }

    final refreshed = await _refreshAccessToken();

    if (!refreshed) {
      return response;
    }

    return send(await _authorizedHeaders());
  }

  Future<bool> _refreshAccessToken() async {
    final storedRefreshToken = await _tokenStorageService.getRefreshToken();

    if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await _authApiService.refreshToken(
        RefreshTokenRequest(refreshToken: storedRefreshToken),
      );

      await _tokenStorageService.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        accessTokenExpiresAt: response.accessTokenExpiresAt,
      );

      return true;
    } catch (_) {
      await _tokenStorageService.clearTokens();
      return false;
    }
  }

  void dispose() {
    _client.close();

    if (_ownsAuthApiService) {
      _authApiService.dispose();
    }
  }
}
