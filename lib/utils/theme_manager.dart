import 'package:flutter/material.dart';

class ThemeManager {
  static ThemeMode _currentMode = ThemeMode.system;

  static ThemeMode get currentMode => _currentMode;

  // Theme mode change callback - to be set by MyApp
  static void Function(ThemeMode)? _onThemeModeChanged;

  static void setOnThemeModeChanged(void Function(ThemeMode) callback) {
    _onThemeModeChanged = callback;
  }

  static void setThemeMode(BuildContext context, ThemeMode mode) {
    _currentMode = mode;
    // 콜백을 통해 테마 변경 알림
    _onThemeModeChanged?.call(mode);
  }

  static String getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '라이트 모드';
      case ThemeMode.dark:
        return '다크 모드';
      case ThemeMode.system:
        return '시스템 설정';
    }
  }
}
