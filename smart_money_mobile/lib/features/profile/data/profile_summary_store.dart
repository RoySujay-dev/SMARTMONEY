import 'package:flutter/foundation.dart';

import 'services/profile_api_service.dart';

/// The handful of profile fields the drawer and dashboard chip display.
@immutable
class ProfileSummary {
  const ProfileSummary({
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.initials,
    required this.isVerified,
  });

  final String name;
  final String email;
  final String imageUrl;
  final String initials;
  final bool isVerified;

  /// Shown before the first load lands, and kept when a load fails so an
  /// expired session degrades to a neutral chip instead of an error.
  static const ProfileSummary placeholder = ProfileSummary(
    name: 'SmartMoney User',
    email: '',
    imageUrl: '',
    initials: 'SM',
    isVerified: false,
  );
}

/// App-wide holder for the signed-in user's profile summary.
///
/// The drawer now appears on several screens, and each one rendering the
/// user's name and photo would otherwise fire its own `GET /api/profile` on
/// first build. This loads once and every listener repaints from the same
/// value. Deliberately a plain [ValueNotifier] — the app has no state
/// management package, and this needs to outlive individual screens.
class ProfileSummaryStore {
  ProfileSummaryStore._();

  static final ProfileSummaryStore instance = ProfileSummaryStore._();

  final ProfileApiService _profileApiService = ProfileApiService();

  final ValueNotifier<ProfileSummary> summary = ValueNotifier<ProfileSummary>(
    ProfileSummary.placeholder,
  );

  Future<void>? _inFlight;

  String get baseUrl => _profileApiService.baseUrl;

  /// Loads once per app run. Repeat callers await the same request.
  Future<void> ensureLoaded() => _inFlight ??= _load();

  /// Forces a re-fetch — call after the profile screen may have changed it.
  Future<void> refresh() {
    _inFlight = null;
    return ensureLoaded();
  }

  Future<void> _load() async {
    try {
      final profile = await _profileApiService.getProfile();
      summary.value = ProfileSummary(
        name: profile.fullName,
        email: profile.email,
        imageUrl: _absoluteImageUrl(profile.profileImageUrl),
        initials: _initialsOf(profile.fullName),
        isVerified: profile.isEmailVerified,
      );
    } catch (_) {
      // Keep the placeholder if the session is missing or expired. Clear the
      // memo so a later call can retry rather than caching the failure.
      _inFlight = null;
    }
  }

  String _initialsOf(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'SM';
    return parts.take(2).map((part) => part[0]).join().toUpperCase();
  }

  String _absoluteImageUrl(String value) {
    final imageUrl = value.trim();
    if (imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    return '$baseUrl$imageUrl';
  }
}
