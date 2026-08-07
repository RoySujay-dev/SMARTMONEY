class ProfileResponse {
  const ProfileResponse({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.isEmailVerified,
    required this.status,
  });

  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String profileImageUrl;
  final bool isEmailVerified;
  final String status;

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String? ?? '',
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      status: json['status'] as String? ?? '',
    );
  }
}
