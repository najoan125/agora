import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:ui';
import 'features/auth/login_screen.dart';
import 'features/main/main_screen.dart';
import 'core/theme.dart';
import 'shared/providers/auth_provider.dart';
import 'shared/providers/riverpod_profile_provider.dart';
import 'features/profile/screens/create_profile_screen.dart';
import 'services/oauth_service.dart';
import 'utils/theme_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    // Deep Link 리스너 초기화
    _initializeDeepLinks();
    // ThemeManager 콜백 설정
    ThemeManager.setOnThemeModeChanged(setThemeMode);
  }

  Future<void> _initializeDeepLinks() async {
    final oauthService = ref.read(oauthServiceProvider);
    await oauthService.initializeDeepLinkListener();
  }

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
      // 한국어 로케일 지원
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ko', 'KR'),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
      home: const AuthGate(),
      routes: {
        '/create-profile': (context) => const CreateProfileScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

/// 인증 상태에 따라 화면 분기
class AuthGate extends ConsumerWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    switch (authState.status) {
      case AuthStatus.initial:
      case AuthStatus.checking:
        return const SplashScreen();
      case AuthStatus.authenticated:
        // 인증된 상태에서 프로필 존재 여부 확인
        return const _ProfileGate();
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
      case AuthStatus.authenticating:
        return const LoginScreen();
    }
  }
}

/// 프로필 존재 여부에 따라 화면 분기
class _ProfileGate extends ConsumerWidget {
  const _ProfileGate({Key? key}) : super(key: key);

  /// 프로필이 없는 것으로 간주해야 하는 에러인지 확인
  bool _isProfileNotFoundError(Object error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('404') ||
        errorStr.contains('not found') ||
        errorStr.contains('프로필을 찾을 수 없습니다') ||
        errorStr.contains('profile_not_found');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          // 프로필이 없으면 생성 화면으로
          return const CreateProfileScreen();
        }
        // 프로필이 있으면 메인 화면으로
        return const MainScreen();
      },
      loading: () => const SplashScreen(),
      error: (error, stack) {
        // 프로필 없음 에러는 생성 화면으로
        if (_isProfileNotFoundError(error)) {
          return const CreateProfileScreen();
        }

        // 에러 메시지 추출
        String errorMessage = '프로필 로딩 중 오류가 발생했습니다.';
        if (error.toString().contains('network') ||
            error.toString().contains('connection') ||
            error.toString().contains('timeout')) {
          errorMessage = '네트워크 연결을 확인해주세요.';
        }

        // 디버그용 에러 로그
        print('ProfileGate error: $error');
        print('Stack trace: $stack');

        // 다른 에러는 에러 화면 표시
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.invalidate(myProfileProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('다시 시도'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 스플래시 화면 (자동 로그인 체크)
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

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
