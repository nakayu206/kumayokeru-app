import 'package:flutter/material.dart';

import 'package:kumayokeru_app/core/constants/app_colors.dart';
import 'package:kumayokeru_app/core/constants/app_sizes.dart';
import 'package:kumayokeru_app/core/constants/app_spacing.dart';

/// アプリ全体で共通のエラー表示(赤文字)。バリデーションエラー・通信エラーなどで使う。
class ErrorText extends StatelessWidget {
  const ErrorText(this.message, {super.key, this.textAlign});

  final String message;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(
        message,
        textAlign: textAlign,
        style: TextStyle(color: AppColors.danger, fontSize: AppSizes.fontSm),
      ),
    );
  }
}
