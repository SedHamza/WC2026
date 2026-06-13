import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import 'package:wc2026/l10n/app_localizations.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;
  int _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    setState(() => _passwordStrength = strength);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await ref.read(authProvider.notifier).signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result != null) {
      setState(() => _errorMessage = result);
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.register),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.createAccount,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(l10n.joinCompetition,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(child: _buildFirstName(l10n)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildLastName(l10n)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildEmail(l10n),
                const SizedBox(height: 16),
                _buildPassword(l10n),
                const SizedBox(height: 8),
                _buildStrengthBar(),
                const SizedBox(height: 16),
                _buildConfirmPassword(l10n),
                const SizedBox(height: 16),
                if (_errorMessage != null) ...[
                  _buildError(),
                  const SizedBox(height: 16),
                ],
                _buildRegisterButton(l10n),
                const SizedBox(height: 20),
                _buildLoginLink(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFirstName(AppLocalizations l10n) {
    return TextFormField(
      controller: _firstNameController,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(labelText: l10n.firstName),
      validator: (v) => v == null || v.isEmpty ? l10n.fieldRequired : null,
    );
  }

  Widget _buildLastName(AppLocalizations l10n) {
    return TextFormField(
      controller: _lastNameController,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(labelText: l10n.lastName),
      validator: (v) => v == null || v.isEmpty ? l10n.fieldRequired : null,
    );
  }

  Widget _buildEmail(AppLocalizations l10n) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: l10n.email,
        prefixIcon: const Icon(Icons.email_outlined, size: 20),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return l10n.fieldRequired;
        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return l10n.invalidEmail;
        }
        return null;
      },
    );
  }

  Widget _buildPassword(AppLocalizations l10n) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: l10n.password,
        prefixIcon: const Icon(Icons.lock_outline, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return l10n.fieldRequired;
        if (value.length < 6) return l10n.weakPassword;
        return null;
      },
    );
  }

  Widget _buildStrengthBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = [
      AppColors.error,
      AppColors.warning,
      AppColors.info,
      AppColors.success,
    ];
    final labels = ['Faible', 'Moyen', 'Bon', 'Fort'];

    return Row(
      children: [
        ...List.generate(
            4,
            (i) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    height: 3,
                    decoration: BoxDecoration(
                      color: i < _passwordStrength
                          ? colors[_passwordStrength - 1]
                          : AppColors.bgSurface(isDark),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
        const SizedBox(width: 8),
        if (_passwordStrength > 0)
          Text(
            labels[_passwordStrength - 1],
            style: TextStyle(
              color: colors[_passwordStrength - 1],
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildConfirmPassword(AppLocalizations l10n) {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirm,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _register(),
      decoration: InputDecoration(
        labelText: l10n.confirmPassword,
        prefixIcon: const Icon(Icons.lock_outline, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirm
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 20,
          ),
          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return l10n.fieldRequired;
        if (value != _passwordController.text) return l10n.passwordMismatch;
        return null;
      },
    );
  }

  Widget _buildError() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorBg(isDark),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(l10n.createAccount),
      ),
    );
  }

  Widget _buildLoginLink(AppLocalizations l10n) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: l10n.alreadyAccount,
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Text(
                  l10n.login,
                  style: TextStyle(
                    color: AppColors.infoText(
                        Theme.of(context).brightness == Brightness.dark),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
