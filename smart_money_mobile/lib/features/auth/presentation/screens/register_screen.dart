import 'package:flutter/material.dart';

import '../../../../app/routes/route_names.dart';
import '../../data/models/register_request.dart';
import '../../data/services/auth_api_service.dart';
import '../widgets/otp_verification_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const _purple = Color(0xFF6334D8);
  static const _green = Color(0xFF16A765);
  static const _darkText = Color(0xFF172033);
  static const _mutedText = Color(0xFF687086);

  final _formKey = GlobalKey<FormState>();
  final _authApiService = AuthApiService();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _referralCodeController = TextEditingController();

  String? _emailApiError;
  String? _phoneApiError;
  String? _passwordApiError;
  String? _generalApiError;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralCodeController.dispose();
    _authApiService.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Full name is required';
    }

    if (name.length < 3) {
      return 'Full name must contain at least 3 characters';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    final emailPattern = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return _emailApiError;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return 'Phone number is required';
    }

    final phonePattern = RegExp(r'^[0-9]{10}$');

    if (!phonePattern.hasMatch(phone)) {
      return 'Enter a valid 10-digit phone number';
    }

    return _phoneApiError;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain an uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain a lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain a number';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain a special character';
    }

    return _passwordApiError;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  Future<void> _submitRegistration() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _emailApiError = null;
      _phoneApiError = null;
      _passwordApiError = null;
      _generalApiError = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = RegisterRequest(
        fullName: _fullNameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
        referralCode: _referralCodeController.text,
      );

      final response = await _authApiService.register(request);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      final isVerified = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return OtpVerificationDialog(email: response.email);
        },
      );

      if (!mounted || isVerified != true) {
        return;
      }

      Navigator.pushReplacementNamed(context, RouteNames.dashboard);
    } catch (error) {
      if (!mounted) return;

      final errorText = error.toString().toLowerCase();

      setState(() {
        _isLoading = false;

        if (errorText.contains('phone')) {
          _phoneApiError = 'This phone number is already registered.';
        } else if (errorText.contains('email')) {
          _emailApiError = 'This email address is already registered.';
        } else if (errorText.contains('password')) {
          _passwordApiError = 'Password does not meet the requirements.';
        } else {
          _generalApiError = 'Unable to create your account. Please try again.';
        }
      });

      _formKey.currentState?.validate();
    }
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon, color: _purple),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFFCFCFF),
      hintStyle: const TextStyle(color: Color(0xFF8A90A2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE8E4F2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _green, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF1EAFF), Color(0xFFFEFCFF), Color(0xFFF0FFF7)],
            stops: [0.0, 0.50, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: SizedBox(
                          height: 150,
                          child: Image.asset(
                            'assets/images/smartmoney_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -18),
                        child: SizedBox(
                          height: 120,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                right: -10,
                                top: -68,
                                child: Opacity(
                                  opacity: 0.44,
                                  child: Image.asset(
                                    'assets/images/register_growth_chart.png',
                                    width: 220,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        children: const [
                                          TextSpan(text: 'Create '),
                                          TextSpan(
                                            text: 'SmartMoney',
                                            style: TextStyle(color: _purple),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: _darkText,
                                            height: 1.08,
                                          ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Start tracking rewards and cashback\n'
                                      'with a secure account.',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            height: 1.45,
                                            color: _mutedText,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.70),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _purple.withValues(alpha: 0.10),
                              blurRadius: 32,
                              offset: const Offset(0, 14),
                            ),
                            BoxShadow(
                              color: _green.withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _fullNameController,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              validator: _validateFullName,
                              decoration: _inputDecoration(
                                hintText: 'Full Name',
                                icon: Icons.person_outline,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: _validateEmail,
                              decoration: _inputDecoration(
                                hintText: 'Email',
                                icon: Icons.email_outlined,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              validator: _validatePhone,
                              decoration: _inputDecoration(
                                hintText: 'Phone Number',
                                icon: Icons.phone_outlined,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.next,
                              validator: _validatePassword,
                              decoration: _inputDecoration(
                                hintText: 'Password',
                                icon: Icons.lock_outline,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFF7A8191),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              textInputAction: TextInputAction.next,
                              validator: _validateConfirmPassword,
                              decoration: _inputDecoration(
                                hintText: 'Confirm Password',
                                icon: Icons.lock_reset_outlined,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFF7A8191),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _referralCodeController,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) {
                                _submitRegistration();
                              },
                              decoration: _inputDecoration(
                                hintText: 'Referral Code (Optional)',
                                icon: Icons.card_giftcard_outlined,
                              ),
                            ),
                            if (_generalApiError != null) ...[
                              const SizedBox(height: 14),
                              Text(
                                _generalApiError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
                            _SmartMoneyRegisterButton(
                              isLoading: _isLoading,
                              onPressed: _isLoading
                                  ? null
                                  : _submitRegistration,
                            ),
                            const SizedBox(height: 16),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 18,
                                  color: _green,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Your information is encrypted and secure',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _mutedText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: _purple.withValues(alpha: 0.14),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'or',
                              style: TextStyle(
                                color: Color(0xFF7A8191),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: _green.withValues(alpha: 0.18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(
                              color: Color(0xFF394056),
                              fontSize: 15,
                            ),
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      RouteNames.login,
                                    );
                                  },
                            child: const Text(
                              'Log in',
                              style: TextStyle(
                                color: _purple,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SmartMoneyRegisterButton extends StatelessWidget {
  const _SmartMoneyRegisterButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isEnabled
              ? const [Color(0xFF17B765), Color(0xFF0C9F56)]
              : const [Color(0xFF9ED7B8), Color(0xFF9ED7B8)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: const Color(0xFF10A85F).withValues(alpha: 0.30),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : const [],
      ),
      child: FilledButton(
        onPressed: isEnabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_add_alt_1_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
