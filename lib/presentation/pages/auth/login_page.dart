import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kumayokeru_app/core/constants/app_colors.dart';
import 'package:kumayokeru_app/core/constants/app_sizes.dart';
import 'package:kumayokeru_app/core/constants/app_spacing.dart';
import 'package:kumayokeru_app/presentation/providers/auth_providers.dart';

/// ログイン/新規登録画面。
///
/// TekuShareのEmailAuthPageと同じメール+パスワード認証フローを踏襲する。
/// kumayokeru-backend(JWT + bcrypt、#15)と結合済み。バックエンドはsignup時に
/// メール確認を行わないため、新規登録に成功したら続けて自動でログインする。
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated && previous?.isAuthenticated != true) {
        Navigator.of(context).pop();
      }
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(top: false, child: _buildFormView(authState)),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: true,
      elevation: 0,
      title: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'クマヨケール',
            style: TextStyle(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('登山のお守り', style: TextStyle(fontSize: AppSizes.fontXs)),
        ],
      ),
    );
  }

  Widget _buildFormView(AuthState authState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x3l,
        vertical: AppSpacing.x4l,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isRegisterMode ? '新規登録' : 'ログイン',
            style: TextStyle(
              fontSize: AppSizes.fontX2l,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'メールアドレスとパスワードを入力してください',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.x4l),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'メールアドレス',
              hintText: 'example@mail.com',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.mail_outline),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'パスワード',
              hintText: '8文字以上',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            textInputAction: _isRegisterMode
                ? TextInputAction.next
                : TextInputAction.done,
            onSubmitted: _isRegisterMode ? null : (_) => _submit(),
          ),
          if (_isRegisterMode) ...[
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'パスワード(確認用)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                ),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
          ],
          const SizedBox(height: AppSpacing.x3l),
          SizedBox(
            height: AppSizes.buttonHeight,
            child: FilledButton(
              onPressed: authState.isLoading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
              ),
              child: authState.isLoading
                  ? const SizedBox(
                      width: AppSizes.iconMd,
                      height: AppSizes.iconMd,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_isRegisterMode ? '登録する' : 'ログイン'),
            ),
          ),
          const SizedBox(height: AppSpacing.x2l),
          TextButton(
            onPressed: authState.isLoading ? null : _toggleMode,
            child: Text(
              _isRegisterMode ? 'すでにアカウントをお持ちの方はこちら' : 'アカウントをお持ちでない方はこちら',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) return _showSnack('メールアドレスを入力してください');
    if (!_isValidEmail(email)) return _showSnack('メールアドレスの形式が正しくありません');
    if (password.isEmpty) return _showSnack('パスワードを入力してください');
    if (password.length < 8) return _showSnack('パスワードは8文字以上で入力してください');

    if (_isRegisterMode) {
      if (password != _confirmPasswordController.text) {
        return _showSnack('パスワードが一致しません');
      }
      ref.read(authProvider.notifier).signUp(email, password);
    } else {
      ref.read(authProvider.notifier).login(email, password);
    }
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
