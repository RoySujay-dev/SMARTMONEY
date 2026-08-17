// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_exception.dart';
import '../../../auth/data/models/refresh_token_request.dart';
import '../../../auth/data/services/auth_api_service.dart';
import '../../../auth/data/services/token_storage_service.dart';
import '../models/affiliate_click_response.dart';

/// Talks to the AUTHENTICATED affiliate endpoints (Bearer JWT required).
///
/// Combines the [ProfileApiService] auth pattern (stored token, refresh and
/// retry once on 401) with the [BrowsingApiService] error convention: every
/// failure is normalized to [ApiException] with a user-safe message, so
/// screens never render raw exception text.
class AffiliateApiService {
  AffiliateApiService({
    http.Client? client,
    TokenStorageService tokenStorageService = const TokenStorageService(),
    AuthApiService? authApiService,
    this.baseUrl = ApiConfig.baseUrl,
    Duration? timeout,
  })  : _client = client ?? http.Client(),
        _tokenStorageService = tokenStorageService,
        _authApiService = authApiService ?? AuthApiService(baseUrl: baseUrl),
        _ownsAuthApiService = authApiService == null,
        _timeout = timeout ?? const Duration(seconds: 15);

  final http.Client _client;
  final TokenStorageService _tokenStorageService;
  final AuthApiService _authApiService;
  final bool _ownsAuthApiService;
  final String baseUrl;
  final Duration _timeout;

  static const String _signInMessage = 'Sign in to earn cashback.';
  static const String _sessionExpiredMessage =
      'Your session has expired. Please sign in again.';
  static const String _unavailableMessage =
      'Cashback is not available for this store or offer.';

  /// POST /api/affiliate/clicks
  ///
  /// Records the outbound journey and returns the tracked redirect link.
  /// [offerId] is omitted from the request when the journey starts from a
  /// store page rather than an offer.
  Future<AffiliateClickResponse> createClick({
    required String storeId,
    String? offerId,
  }) async {
    final response = await _sendAuthorizedRequest(
      (headers) => _client
          .post(
            Uri.parse('$baseUrl/api/affiliate/clicks'),
            headers: headers,
            body: jsonEncode({
              'storeId': storeId,
              if (offerId != null && offerId.trim().isNotEmpty)
                'offerId': offerId,
            }),
          )
          .timeout(_timeout),
    );

    final status = response.statusCode;

    if (status == 401) {
      throw const ApiException(_sessionExpiredMessage, statusCode: 401);
    }

    if (status == 404) {
      throw const ApiException(_unavailableMessage, statusCode: 404);
    }

    if (status < 200 || status >= 300) {
      throw ApiException(
        'The server responded with an error. Please try again shortly.',
        statusCode: status,
      );
    }

    if (response.body.isEmpty) {
      throw const ApiException('The server returned an empty response.');
    }

    late final dynamic body;
    try {
      body = jsonDecode(response.body);
    } on FormatException {
      throw const ApiException(
        'Received an unexpected response from the server.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw const ApiException(
        'Received an unexpected response from the server.',
      );
    }

    return AffiliateClickResponse.fromJson(body);
  }

  Future<Map<String, String>> _authorizedHeaders() async {
    final token = await _tokenStorageService.getAccessToken();

    if (token == null || token.isEmpty) {
      throw const ApiException(_signInMessage, statusCode: 401);
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _sendAuthorizedRequest(
    Future<http.Response> Function(Map<String, String> headers) send,
  ) async {
    late final http.Response response;
    try {
      response = await send(await _authorizedHeaders());

      if (response.statusCode != 401) {
        return response;
      }

      final refreshed = await _refreshAccessToken();

      if (!refreshed) {
        return response;
      }

      return await send(await _authorizedHeaders());
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        'The request timed out. Please check your connection and try again.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Unable to reach the server. Please check your connection and try again.',
      );
    } catch (_) {
      throw const ApiException(
        'Something went wrong while contacting the server. Please try again.',
      );
    }
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
