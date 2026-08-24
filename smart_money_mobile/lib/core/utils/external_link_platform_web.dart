import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Opens a blank tab synchronously. Must be called as the very first
/// statement in a tap handler, before any `await` — browsers only allow
/// `window.open` without popup-blocking while still inside the synchronous
/// call stack of a genuine user gesture. The blank tab is navigated later,
/// once the real URL is known, which browsers permit freely (navigating an
/// already-open window is not restricted the way opening a new one is).
///
/// Signatures use plain `Object?`, matching external_link_platform_stub.dart
/// (the conditional-import contract requires identical signatures, and the
/// stub must compile under `flutter test`'s VM runner, where
/// `dart:js_interop` types don't exist). This file only ever loads on a
/// genuine web/js_interop-capable target, so the `Object?` -> JSAny handoff
/// below is safe despite the analyzer's static caution about it.
Object? reserveTab() => web.window.open('', '_blank');

Future<bool> navigateReservedTab(Object? handle, Uri uri) async {
  final win = _asWindow(handle);
  if (win == null) return false;

  // The tab may have been closed by the user while the network call was in
  // flight; `closed` reports that instead of throwing on a dead reference.
  if (win.closed) return false;

  win.location.href = uri.toString();
  return true;
}

void closeReservedTab(Object? handle) {
  final win = _asWindow(handle);
  if (win != null && !win.closed) {
    win.close();
  }
}

web.Window? _asWindow(Object? handle) {
  if (handle == null) return null;

  // `as JSAny` is a cast (an assertion), not a runtime `is` check on an
  // interop type, so it doesn't trigger the platform-consistency lint the
  // way `is`/`is!` would; `isA<T>()` is then the actual, lint-recommended
  // safe check. Always a genuine JS object here — the only producer of a
  // non-null handle is this file's own reserveTab().
  final jsHandle = handle as JSAny;
  if (!jsHandle.isA<web.Window>()) return null;

  return jsHandle as web.Window;
}
