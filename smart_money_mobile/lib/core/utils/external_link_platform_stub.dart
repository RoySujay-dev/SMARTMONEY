/// Non-web fallback: there is no browser popup blocker to work around, so
/// reserving a tab ahead of time is meaningless. Callers just launch
/// normally once the real URL is known.
///
/// Plain `Object?` here (not a `dart:js_interop` type) is deliberate: this
/// file is also loaded by `flutter test`'s default VM runner, where
/// `dart:js_interop`'s marker types don't resolve at all.
Object? reserveTab() => null;

Future<bool> navigateReservedTab(Object? handle, Uri uri) async => false;

void closeReservedTab(Object? handle) {}
