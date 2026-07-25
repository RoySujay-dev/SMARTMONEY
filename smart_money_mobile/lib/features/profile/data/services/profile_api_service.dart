// ignore_for_file: prefer_initializing_formals

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../auth/data/services/token_storage_service.dart';
import '../models/profile_response.dart';

class ProfileApiService {
  ProfileApiService({
    http.Client? client,
    TokenStorageService tokenStorageService = const TokenStorageService(),
    this.baseUrl = 'http://localhost:5256',
  }) : _client = client ?? http.Client(),
       _tokenStorageService = tokenStorageService;

  final http.Client _client;
  final TokenStorageService _tokenStorageService;
  final String baseUrl;

  Future<ProfileResponse> getProfile() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/profile'),
      headers: await _authorizedHeaders(),
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
    final response = await _client.put(
      Uri.parse('$baseUrl/api/profile/update-name'),
      headers: await _authorizedHeaders(),
      body: jsonEncode({'name': name}),
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
    final response = await _client.put(
      Uri.parse('$baseUrl/api/profile/change-password'),
      headers: await _authorizedHeaders(),
      body: jsonEncode({'newPassword': newPassword}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Password update failed with status ${response.statusCode}: '
        '${response.body}',
      );
    }
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

  void dispose() {
    _client.close();
  }
}
