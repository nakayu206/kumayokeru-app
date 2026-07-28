import 'package:flutter/material.dart';

/// デザイントークン: カラー(仕様書セクション15)。
///
/// 「不安を煽らない、落ち着いた登山の相棒」というトーンを守るため、
/// warning/dangerの使い分けを厳守すること。dangerは緊急連絡(SOS)ボタンのみに限定使用する。
class AppColors {
  AppColors._();

  static const primary = Color(0xFF2E5339);
  static const primaryLight = Color(0xFFA8C3AE);
  static const primaryDark = Color(0xFF1B3A22);

  /// 出没情報の警告表示に使用。赤は過度に不安を煽るため避ける。
  static const warning = Color(0xFFD97706);

  /// 緊急連絡(SOS)ボタンのみに限定使用。
  static const danger = Color(0xFFC0392B);

  static const success = Color(0xFF2E7D32);

  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textDisabled = Color(0xFFBDBDBD);
}
