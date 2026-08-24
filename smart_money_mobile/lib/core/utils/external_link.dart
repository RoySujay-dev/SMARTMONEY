import 'package:url_launcher/url_launcher.dart';

// dart.library.js_interop (not dart.library.html) is the WASM-compatible
// guard: dart:html is unavailable under dart2wasm, so gating on it would
// silently route WASM web builds to the no-op stub instead of the real
// implementation.
import 'external_link_platform_stub.dart'
    if (dart.library.js_interop) 'external_link_platform_web.dart' as platform;

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

  /// Reserves a destination for a URL that isn't known yet — call this as
  /// the FIRST statement of a tap handler, before any `await`.
  ///
  /// On Flutter web, `window.open()` after an `await` (e.g. an API call to
  /// fetch the real URL) falls outside the browser's "user gesture" window
  /// and gets silently popup-blocked; calling it here, synchronously inside
  /// the tap, works because it's still inside that window. On other
  /// platforms this is a no-op — there is no popup blocker to route around.
  /// Pass the returned handle to [openReserved] once the URL is known, and
  /// to [cancelReserved] if the flow is aborted (e.g. an error before a URL
  /// is ever produced) so the blank tab doesn't linger.
  static Object? reserve() => platform.reserveTab();

  /// Navigates the tab opened by [reserve] to [rawUrl]. Falls back to a
  /// normal [open] if there is no reserved tab (non-web) or it could not be
  /// navigated (e.g. the user closed it while the URL was loading).
  static Future<bool> openReserved(Object? handle, String? rawUrl) async {
    final uri = parse(rawUrl);
    if (uri == null) {
      cancelReserved(handle);
      return false;
    }

    try {
      if (await platform.navigateReservedTab(handle, uri)) {
        return true;
      }
    } catch (_) {
      // Falls through to the direct-launch fallback below.
    }

    return open(rawUrl);
  }

  /// Closes a tab from [reserve] that will never be navigated (the flow
  /// errored out, or produced no launchable URL), so it doesn't sit open
  /// and blank.
  static void cancelReserved(Object? handle) => platform.closeReservedTab(handle);

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
