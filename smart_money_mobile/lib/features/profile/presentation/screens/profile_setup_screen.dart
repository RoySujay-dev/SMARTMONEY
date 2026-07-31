import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/login_demo_widgets.dart';
import '../../../auth/data/services/token_storage_service.dart';
import '../../data/models/profile_response.dart';
import '../../data/services/profile_api_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  static const _danger = Color(0xFFEF4444);
  static const _cashbackMetrics = [
    {
      'label': 'Available',
      'value': 'Rs 3,450',
      'icon': Icons.account_balance_wallet_outlined,
      'color': AppColors.primary,
    },
    {
      'label': 'Pending',
      'value': 'Rs 780',
      'icon': Icons.schedule_rounded,
      'color': AppColors.warning,
    },
    {
      'label': 'Lifetime',
      'value': 'Rs 12,840',
      'icon': Icons.trending_up_rounded,
      'color': AppColors.success,
    },
  ];

  final _profileApiService = ProfileApiService();
  final _tokenStorageService = const TokenStorageService();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _imagePicker = ImagePicker();

  ProfileResponse? _profile;
  bool _isLoading = true;
  bool _isSavingName = false;
  bool _isChangingPassword = false;
  bool _isPasswordHidden = true;
  bool _isUploadingProfilePhoto = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _profileApiService.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await _profileApiService.getProfile();

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _nameController.text = profile.fullName;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to load profile')));
    }
  }

  Future<void> _updateName() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }

    setState(() {
      _isSavingName = true;
    });

    try {
      final profile = await _profileApiService.updateName(name);

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _nameController.text = profile.fullName;
        _isSavingName = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name updated successfully')),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSavingName = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to update name')));
    }
  }

  Future<void> _changePassword() async {
    final password = _passwordController.text;

    if (password.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password is required')));
      return;
    }

    setState(() {
      _isChangingPassword = true;
    });

    try {
      await _profileApiService.changePassword(password);

      if (!mounted) return;

      _passwordController.clear();

      setState(() {
        _isChangingPassword = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isChangingPassword = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update password')),
      );
    }
  }

  Future<void> _pickProfilePhoto() async {
    if (_isUploadingProfilePhoto) {
      return;
    }

    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );

      if (photo == null || !mounted) {
        return;
      }

      setState(() {
        _isUploadingProfilePhoto = true;
      });

      final updatedProfile = await _profileApiService.uploadProfilePhoto(
        bytes: await photo.readAsBytes(),
        fileName: photo.name,
        contentType: _profilePhotoContentType(photo.name, photo.mimeType),
      );

      if (!mounted) return;

      setState(() {
        _profile = updatedProfile;
        _isUploadingProfilePhoto = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated')),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isUploadingProfilePhoto = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update profile photo')),
      );
    }
  }

  String _profilePhotoContentType(String fileName, String? mimeType) {
    if (mimeType != null && mimeType.trim().isNotEmpty) {
      return mimeType;
    }

    final lowerName = fileName.toLowerCase();

    if (lowerName.endsWith('.png')) {
      return 'image/png';
    }

    if (lowerName.endsWith('.webp')) {
      return 'image/webp';
    }

    return 'image/jpeg';
  }

  Future<void> _logout() async {
    await _tokenStorageService.clearTokens();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, RouteNames.login, (_) => false);
  }

  void _showMvpMessage(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label will be available soon')),
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'SM';
    }

    return parts
        .map((part) => part[0])
        .join()
        .substring(0, parts.length > 1 ? 2 : 1)
        .toUpperCase();
  }

  String _profileImageUrl(String value) {
    final imageUrl = value.trim();

    if (imageUrl.isEmpty) {
      return '';
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    return '${_profileApiService.baseUrl}$imageUrl';
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon, color: AppColors.primary),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;

    return Scaffold(
      body: LoginDemoBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTopNavigation(),
                          const SizedBox(height: 14),
                          _buildHeader(profile),
                          const SizedBox(height: 16),
                          _buildCashbackSummary(),
                          const SizedBox(height: 16),
                          _buildAccountCard(profile),
                          const SizedBox(height: 16),
                          _buildSecurityCard(),
                          const SizedBox(height: 16),
                          _buildSupportCard(),
                          const SizedBox(height: 16),
                          _buildLogoutCard(),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTopNavigation() {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: () {
            Navigator.pushReplacementNamed(context, RouteNames.dashboard);
          },
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to dashboard',
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.74),
            foregroundColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Profile',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ProfileResponse? profile) {
    final fullName = profile?.fullName ?? 'Profile';
    final email = profile?.email ?? '';
    final profilePhotoUrl = _profileImageUrl(profile?.profileImageUrl ?? '');
    final status = (profile?.status.isNotEmpty ?? false)
        ? profile!.status
        : 'Active';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradientExtended,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [AppColors.buttonShadow],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 480;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ProfileAvatar(
                initials: _initials(fullName),
                imageUrl: profilePhotoUrl,
                size: isCompact ? 70 : 82,
                onPickPhoto: _pickProfilePhoto,
                isUploading: _isUploadingProfilePhoto,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isCompact ? 22 : 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusPill(
                          label: status,
                          icon: Icons.verified_user_outlined,
                        ),
                        if (profile?.isEmailVerified ?? false)
                          const _StatusPill(
                            label: 'Verified',
                            icon: Icons.check_circle_outline_rounded,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCashbackSummary() {
    return LoginDemoGlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            title: 'Cashback Summary',
            subtitle: 'Your SmartMoney rewards at a glance',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 560;
              final tiles = _cashbackMetrics
                  .map(
                    (metric) => _MetricTile(
                      label: metric['label']! as String,
                      value: metric['value']! as String,
                      icon: metric['icon']! as IconData,
                      color: metric['color']! as Color,
                    ),
                  )
                  .toList();

              if (isCompact) {
                return Column(
                  children: [
                    for (var index = 0; index < tiles.length; index++) ...[
                      tiles[index],
                      if (index != tiles.length - 1) const SizedBox(height: 10),
                    ],
                  ],
                );
              }

              return Row(
                children: [
                  for (var index = 0; index < tiles.length; index++) ...[
                    Expanded(child: tiles[index]),
                    if (index != tiles.length - 1) const SizedBox(width: 12),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(ProfileResponse? profile) {
    return LoginDemoGlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            title: 'Account Information',
            subtitle: 'Your registered SmartMoney details',
          ),
          const SizedBox(height: 18),
          _InfoRow(
            label: 'Full Name',
            value: profile?.fullName ?? '',
            icon: Icons.person_outline,
          ),
          const _InfoDivider(),
          _InfoRow(
            label: 'Email Address',
            value: profile?.email ?? '',
            icon: Icons.email_outlined,
          ),
          const _InfoDivider(),
          _InfoRow(
            label: 'Phone Number',
            value: profile?.phoneNumber ?? '',
            icon: Icons.phone_outlined,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration(
              hintText: 'Name',
              icon: Icons.badge_outlined,
            ),
          ),
          const SizedBox(height: 14),
          LoginDemoGradientButton(
            label: 'Update Name',
            icon: Icons.save_outlined,
            isLoading: _isSavingName,
            height: 48,
            onPressed: _isSavingName ? null : _updateName,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return LoginDemoGlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            title: 'Security',
            subtitle: 'Manage access to your SmartMoney account',
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _passwordController,
            obscureText: _isPasswordHidden,
            decoration: _inputDecoration(
              hintText: 'New Password',
              icon: Icons.lock_outline,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _isPasswordHidden = !_isPasswordHidden;
                  });
                },
                icon: Icon(
                  _isPasswordHidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSoft,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          LoginDemoGradientButton(
            label: 'Update Password',
            icon: Icons.lock_reset_rounded,
            isLoading: _isChangingPassword,
            height: 48,
            onPressed: _isChangingPassword ? null : _changePassword,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard() {
    return LoginDemoGlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            title: 'Support & Legal',
            subtitle: 'Get help and review account policies',
          ),
          const SizedBox(height: 8),
          _ActionRow(
            title: 'Help & Support',
            subtitle: 'Get assistance with cashback or account issues',
            icon: Icons.support_agent_rounded,
            onTap: () => _showMvpMessage('Help & Support'),
          ),
          const _InfoDivider(),
          _ActionRow(
            title: 'Terms & Conditions',
            subtitle: 'Review SmartMoney usage terms',
            icon: Icons.description_outlined,
            onTap: () => _showMvpMessage('Terms & Conditions'),
          ),
          const _InfoDivider(),
          _ActionRow(
            title: 'Privacy Policy',
            subtitle: 'See how account data is handled',
            icon: Icons.privacy_tip_outlined,
            onTap: () => _showMvpMessage('Privacy Policy'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutCard() {
    return LoginDemoGlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(16),
      child: OutlinedButton.icon(
        onPressed: _logout,
        style: OutlinedButton.styleFrom(
          foregroundColor: _danger,
          side: BorderSide(color: _danger.withValues(alpha: 0.42)),
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.logout_rounded),
        label: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSoft,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final displayValue = value.isEmpty ? 'Not available' : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  displayValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSoft,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSoft,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoDivider extends StatelessWidget {
  const _InfoDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 22,
      thickness: 1,
      color: AppColors.inputBorder.withValues(alpha: 0.72),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.initials,
    required this.imageUrl,
    required this.size,
    required this.onPickPhoto,
    required this.isUploading,
  });

  final String initials;
  final String imageUrl;
  final double size;
  final VoidCallback onPickPhoto;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.trim().isNotEmpty;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.58),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: hasImage
                  ? Image.network(
                      imageUrl,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _InitialsAvatarLabel(
                          initials: initials,
                          fontSize: size < 76 ? 24 : 28,
                        );
                      },
                    )
                  : _InitialsAvatarLabel(
                      initials: initials,
                      fontSize: size < 76 ? 24 : 28,
                    ),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Tooltip(
              message: 'Add profile photo',
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkResponse(
                  onTap: isUploading ? null : onPickPhoto,
                  radius: 18,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textDark.withValues(alpha: 0.16),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: isUploading
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : const Icon(
                            Icons.photo_camera_outlined,
                            color: AppColors.primary,
                            size: 15,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialsAvatarLabel extends StatelessWidget {
  const _InitialsAvatarLabel({
    required this.initials,
    required this.fontSize,
  });

  final String initials;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      initials,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
