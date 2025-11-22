import 'package:flutter/material.dart';
import '../main.dart';

class ThemeManager {
  static ThemeMode _currentMode = ThemeMode.system;

  static ThemeMode get currentMode => _currentMode;

  static void setThemeMode(BuildContext context, ThemeMode mode) {
    _currentMode = mode;
    // MaterialApp 강제 재빌드
    final state = context.findAncestorStateOfType<MyAppState>();
    state?.setThemeMode(mode);
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
