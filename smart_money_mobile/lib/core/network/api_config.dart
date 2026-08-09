/// Central place for the backend base URL used by the public browsing layer.
///
/// The existing auth/profile services hardcode this same value in their own
/// constructors; this constant is shared by the newer browsing feature so the
/// value is defined once. It is intentionally not wired into the auth/profile
/// services to avoid touching those existing flows.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://localhost:5256';
}
