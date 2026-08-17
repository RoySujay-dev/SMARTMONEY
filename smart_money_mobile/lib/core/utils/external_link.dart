import 'package:url_launcher/url_launcher.dart';

/// Opens http(s) destinations in the device browser.
///
/// Callers pass either a plain merchant URL or a backend tracked-redirect
/// link (`ApiConfig.baseUrl + '/r/{token}'`). This class only validates and
/// launches the URL — click tracking happens server-side on the redirect.
class ExternalLink {
  ExternalLink._();

  /// Returns true when [rawUrl] was handed off to the browser.
  ///
  /// Only http/https URLs are launched, so a malformed or unexpected scheme
  /// coming from the API can never trigger an arbitrary intent.
  static Future<bool> open(String? rawUrl) async {
    final uri = parse(rawUrl);
    if (uri == null) return false;

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// Parses [rawUrl] into a launchable http(s) [Uri], or null when unusable.
  static Uri? parse(String? rawUrl) {
    final trimmed = rawUrl?.trim() ?? '';
    if (trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed);
    if (uri == null) return null;
    // `hasAuthority` is true for 'https://' (empty authority), so check the
    // host itself before treating the URL as launchable.
    if (uri.host.isEmpty) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;

    return uri;
  }
}
