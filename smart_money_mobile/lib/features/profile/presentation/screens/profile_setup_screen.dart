import 'package:flutter/material.dart';

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

  final _profileApiService = ProfileApiService();
  final _tokenStorageService = const TokenStorageService();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  ProfileResponse? _profile;
  bool _isLoading = true;
  bool _isSavingName = false;
  bool _isChangingPassword = false;
  bool _isPasswordHidden = true;

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

  Future<void> _logout() async {
    await _tokenStorageService.clearTokens();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, RouteNames.login, (_) => false);
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
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                RouteNames.dashboard,
                              );
                            },
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Back To Dashboard'),
                          ),
                          const SizedBox(height: 10),
                          _buildHeader(profile),
                          const SizedBox(height: 16),
                          _buildAccountCard(profile),
                          const SizedBox(height: 16),
                          _buildEditNameCard(),
                          const SizedBox(height: 16),
                          _buildPasswordCard(),
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

  Widget _buildHeader(ProfileResponse? profile) {
    final fullName = profile?.fullName ?? 'Profile';
    final email = profile?.email ?? '';

    return LoginDemoGlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Text(
              _initials(fullName),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
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
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMid,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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
          _ReadOnlyField(
            label: 'Full Name',
            value: profile?.fullName ?? '',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          _ReadOnlyField(
            label: 'Email Address',
            value: profile?.email ?? '',
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 12),
          _ReadOnlyField(
            label: 'Phone Number',
            value: profile?.phoneNumber ?? '',
            icon: Icons.phone_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildEditNameCard() {
    return LoginDemoGlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            title: 'Edit Profile',
            subtitle: 'Update the name shown on your account',
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration(
              hintText: 'Name',
              icon: Icons.badge_outlined,
            ),
          ),
          const SizedBox(height: 16),
          LoginDemoGradientButton(
            label: 'Update Name',
            icon: Icons.save_outlined,
            isLoading: _isSavingName,
            onPressed: _isSavingName ? null : _updateName,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordCard() {
    return LoginDemoGlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            title: 'Change Password',
            subtitle: 'Set a new password for your account',
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
            onPressed: _isChangingPassword ? null : _changePassword,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutCard() {
    return LoginDemoGlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      child: SizedBox(
        height: 50,
        child: FilledButton.icon(
          onPressed: _logout,
          style: FilledButton.styleFrom(
            backgroundColor: _danger,
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

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
      ),
    );
  }
}
