/// Mirrors the backend `CreateAffiliateClickResponse` contract.
class AffiliateClickResponse {
  const AffiliateClickResponse({
    required this.clickId,
    required this.redirectToken,
    required this.redirectPath,
  });

  final String clickId;
  final String redirectToken;

  /// Server-relative tracked link (`/r/{token}`); launch it as
  /// `baseUrl + redirectPath` so the click is recorded before the
  /// browser reaches the merchant.
  final String redirectPath;

  factory AffiliateClickResponse.fromJson(Map<String, dynamic> json) {
    return AffiliateClickResponse(
      clickId: json['clickId'] as String? ?? '',
      redirectToken: json['redirectToken'] as String? ?? '',
      redirectPath: json['redirectPath'] as String? ?? '',
    );
  }
}
