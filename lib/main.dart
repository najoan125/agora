// 앱의 진입점 및 메인 설정 파일
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'features/auth/login_screen.dart';
import 'features/main/main_screen.dart';
import 'core/theme.dart';
import 'data/auth_service.dart';
import 'data/api_client.dart';
import 'data/profile_service.dart';
import 'shared/providers/profile_provider.dart';
import 'features/profile/screens/create_profile_screen.dart';

void main() {
  // API Client 및 서비스 초기화
  final apiClient = ApiClient();
  final profileService = ProfileService(apiClient);

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<ProfileService>.value(value: profileService),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(profileService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agora',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
      home: const SplashScreen(),  // 자동 로그인 체크 화면
      routes: {
        '/create-profile': (context) => const CreateProfileScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

/// 스플래시 화면 (자동 로그인 체크)
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // 약간의 딜레이 (스플래시 효과)
    await Future.delayed(const Duration(milliseconds: 500));

    // 토큰 확인
    final isLoggedIn = await _authService.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      print('✅ Token found, auto login to MainScreen');
      // 토큰 있음 → 메인 화면
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      print('❌ No token, go to LoginScreen');
      // 토큰 없음 → 로그인 화면
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고나 로딩 인디케이터
              CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'Agora',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
