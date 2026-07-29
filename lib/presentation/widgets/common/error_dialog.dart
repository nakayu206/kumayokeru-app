import 'package:flutter/material.dart';

import 'package:kumayokeru_app/core/constants/app_colors.dart';

/// 通信エラー等、ユーザーに確実に気づいてほしいエラーをダイアログで表示する。
/// フォームの入力バリデーションのような軽いエラーは[ErrorText]を使う(赤文字・画面内表示)。
Future<void> showErrorDialog(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.error_outline, color: AppColors.danger),
      title: const Text('エラー'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
