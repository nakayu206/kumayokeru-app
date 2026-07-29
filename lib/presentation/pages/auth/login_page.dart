import 'package:flutter/material.dart';

import 'package:kumayokeru_app/core/constants/app_colors.dart';
import 'package:kumayokeru_app/core/constants/app_sizes.dart';
import 'package:kumayokeru_app/core/constants/app_spacing.dart';

/// ログイン/新規登録画面。
///
/// TekuShareのEmailAuthPageと同じメール+パスワード認証フローを踏襲する。
/// TODO(#15): AWS Cognito(amplify_auth_cognito)による実際の認証呼び出しと結合する。
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _registered = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: _registered ? _buildRegisteredView() : _buildFormView(),
      ),
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
          Text('クマヨケール', style: TextStyle(fontSize: AppSizes.fontLg, fontWeight: FontWeight.bold)),
          Text('登山のお守り', style: TextStyle(fontSize: AppSizes.fontXs)),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3l, vertical: AppSpacing.x4l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isRegisterMode ? '新規登録' : 'ログイン',
            style: TextStyle(fontSize: AppSizes.fontX2l, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _isRegisterMode
                ? 'メールアドレスとパスワードを入力してください。\n登録完了メールをお送りします。'
                : 'メールアドレスとパスワードを入力してください',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.x4l),
          if (_isRegisterMode) ...[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '表示名',
                hintText: '仲間に表示される名前',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
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
              hintText: '6文字以上(英数字を含む)',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            textInputAction: _isRegisterMode ? TextInputAction.next : TextInputAction.done,
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
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
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
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
              ),
              child: Text(_isRegisterMode ? '登録する' : 'ログイン'),
            ),
          ),
          const SizedBox(height: AppSpacing.x2l),
          TextButton(
            onPressed: _toggleMode,
            child: Text(
              _isRegisterMode ? 'すでにアカウントをお持ちの方はこちら' : 'アカウントをお持ちでない方はこちら',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          if (!_isRegisterMode)
            TextButton(
              onPressed: () {},
              child: Text('パスワードをお忘れの方', style: TextStyle(color: AppColors.textDisabled)),
            ),
        ],
      ),
    );
  }

  Widget _buildRegisteredView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3l, vertical: AppSpacing.x4l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.mark_email_unread_outlined, size: 64, color: AppColors.primary),
          const SizedBox(height: AppSpacing.x3l),
          Text('確認メールを送信しました', textAlign: TextAlign.center, style: TextStyle(fontSize: AppSizes.fontX2l, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'メール内のリンクをクリックして登録を完了してください',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.x2l),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.warning),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_outlined, color: AppColors.warning),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text('メールが届かない場合は迷惑メールフォルダもご確認ください', style: TextStyle(color: AppColors.warning)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x4l),
          SizedBox(
            height: AppSizes.buttonHeight,
            child: FilledButton(
              onPressed: () => setState(() {
                _registered = false;
                _isRegisterMode = false;
              }),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
              ),
              child: const Text('ログイン画面に戻る'),
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
      _nameController.clear();
    });
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) return _showSnack('メールアドレスを入力してください');
    if (!_isValidEmail(email)) return _showSnack('メールアドレスの形式が正しくありません');
    if (password.isEmpty) return _showSnack('パスワードを入力してください');
    if (password.length < 6) return _showSnack('パスワードは6文字以上で入力してください');

    if (_isRegisterMode) {
      if (_nameController.text.trim().isEmpty) return _showSnack('表示名を入力してください');
      final hasLetter = password.contains(RegExp(r'[a-zA-Z]'));
      final hasDigit = password.contains(RegExp(r'[0-9]'));
      if (!hasLetter || !hasDigit) return _showSnack('パスワードは英数字を両方含めてください');
      if (password != _confirmPasswordController.text) return _showSnack('パスワードが一致しません');
    }

    // TODO(#15): ここでAWS Cognito(amplify_auth_cognito)への実際のサインアップ/サインインを呼び出す。
    setState(() {
      if (_isRegisterMode) {
        _registered = true;
      }
    });
  }

  bool _isValidEmail(String email) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
