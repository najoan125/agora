# Flutter 자동 로그인 및 세션 유지

## 개요

앱 시작 시 저장된 토큰으로 자동 로그인 구현

---

## 자동 로그인 흐름

```
앱 시작
  ↓
Splash Screen 표시
  ↓
저장된 토큰 확인
  ↓
├─ 토큰 있음 → 유효성 검증
│   ├─ 유효 → 홈 화면
│   ├─ 만료 → 토큰 갱신 → 홈 또는 로그인
│   └─ 갱신 불가 → 로그인 화면
└─ 토큰 없음 → 로그인 화면
```

---

## 1. Splash Screen

### lib/presentation/screens/splash_screen.dart

```dart
class SplashScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // 1. 저장된 토큰 확인
      final isLoggedIn = await SecureStorageManager.isLoggedIn();

      if (!isLoggedIn) {
        // 토큰 없음 → 로그인 화면
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      // 2. 토큰 유효성 확인
      final tokenRefreshService = ref.read(tokenRefreshServiceProvider);
      final isValid = await SecureStorageManager.getAccessToken() != null;

      if (!isValid) {
        // 토큰 갱신 시도
        final refreshed = await tokenRefreshService.refreshAccessToken();

        if (!refreshed) {
          // 갱신 실패 → 로그인 화면
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
          return;
        }
      }

      // 3. 프로필 정보 로드
      await ref.read(profileProvider.notifier).refresh();

      // 4. 홈 화면으로 이동
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      // 에러 발생 → 로그인 화면
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 100, height: 100),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('로딩 중...'),
          ],
        ),
      ),
    );
  }
}
```

---

## 2. 앱 초기화 로직

### lib/services/app_initialization_service.dart

```dart
class AppInitializationService {
  final TokenRefreshService tokenRefreshService;
  final SecureStorageManager storage;
  final ProfileRepository profileRepository;

  AppInitializationService({
    required this.tokenRefreshService,
    required this.storage,
    required this.profileRepository,
  });

  /// 앱 시작 시 초기화
  Future<AppInitStatus> initialize() async {
    try {
      AppLogger.info('Starting app initialization');

      // 1단계: 저장된 토큰 확인
      final isLoggedIn = await storage.isLoggedIn();
      if (!isLoggedIn) {
        AppLogger.info('No saved token, user needs to login');
        return AppInitStatus.needsLogin;
      }

      // 2단계: 토큰 유효성 확인 및 갱신
      final isValid = await storage.isAccessTokenValid();
      if (!isValid) {
        AppLogger.info('Token expired, attempting refresh');
        final refreshed = await tokenRefreshService.refreshAccessToken();

        if (!refreshed) {
          AppLogger.warning('Token refresh failed');
          return AppInitStatus.needsLogin;
        }
      }

      // 3단계: 프로필 정보 로드
      try {
        await profileRepository.getMyProfile();
        AppLogger.info('Profile loaded successfully');
      } catch (e) {
        AppLogger.warning('Failed to load profile, but continuing: $e');
        // 프로필 로드 실패해도 진행 (나중에 로드 가능)
      }

      // 4단계: 주기적 토큰 갱신 시작
      tokenRefreshService.startPeriodicRefresh();

      AppLogger.info('App initialization completed');
      return AppInitStatus.authenticated;
    } catch (e) {
      AppLogger.error('App initialization failed', error: e);
      return AppInitStatus.error;
    }
  }
}

enum AppInitStatus {
  authenticated,
  needsLogin,
  error,
}

final appInitServiceProvider = Provider((ref) => AppInitializationService(
  tokenRefreshService: ref.watch(tokenRefreshServiceProvider),
  storage: SecureStorageManager(),
  profileRepository: ref.watch(profileRepositoryProvider),
));
```

---

## 3. 라우팅 설정

### lib/presentation/router/app_router.dart

```dart
class AppRouter {
  static GoRouter createRouter(AppInitStatus initStatus) {
    return GoRouter(
      redirect: (context, state) {
        // 초기 라우트 결정
        if (initStatus == AppInitStatus.authenticated) {
          // 로그인 상태 → 홈으로
          if (state.uri.path == '/login') {
            return '/home';
          }
        } else {
          // 비로그인 상태 → 로그인으로
          if (state.uri.path != '/login' && state.uri.path != '/splash') {
            return '/login';
          }
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => HomeScreen(),
          routes: [
            GoRoute(
              path: 'profile',
              builder: (context, state) => ProfileScreen(),
            ),
            GoRoute(
              path: 'chat/:chatId',
              builder: (context, state) => ChatDetailScreen(
                chatId: int.parse(state.pathParameters['chatId']!),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

final appRouterProvider = FutureProvider<GoRouter>((ref) async {
  final initService = ref.watch(appInitServiceProvider);
  final status = await initService.initialize();
  return AppRouter.createRouter(status);
});
```

---

## 4. 메인 앱

### lib/main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends ConsumerWidget {
  const MyApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 라우터 관찰
    final routerAsync = ref.watch(appRouterProvider);

    return routerAsync.when(
      data: (router) => MaterialApp.router(
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
        title: 'Agora',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
      ),
      loading: () => MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stackTrace) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 48),
                SizedBox(height: 16),
                Text('초기화 오류 발생'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // 앱 재시작
                    exit(0);
                  },
                  child: Text('앱 재시작'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 5. 세션 관리자

### lib/services/session_manager.dart

```dart
class SessionManager {
  final TokenStorage tokenStorage;
  final AuthApi authApi;

  SessionManager({
    required this.tokenStorage,
    required this.authApi,
  });

  /// 활성 세션 정보
  Future<Map<String, dynamic>> getSessionInfo() async {
    return {
      'userId': await tokenStorage.getUserId(),
      'email': await tokenStorage.getUserEmail(),
      'agoraId': await tokenStorage.getAgoraId(),
      'isLoggedIn': await tokenStorage.isAccessTokenValid(),
      'expiresAt': await tokenStorage.getExpiresAt(),
    };
  }

  /// 다른 기기에서 로그인 감지
  Future<bool> hasSessionChanged() async {
    // 서버에서 현재 세션 확인
    try {
      final response = await authApi.getCurrentSession();
      final serverSessionId = response['sessionId'];

      // 로컬 저장 세션ID와 비교
      final localSessionId = await tokenStorage.getSessionId();

      return serverSessionId != localSessionId;
    } catch (e) {
      return false;
    }
  }

  /// 현재 기기 정보 저장
  Future<void> saveDeviceInfo(String deviceId, String deviceName) async {
    // 기기 정보 저장
  }

  /// 세션 만료 시간 확인
  Future<Duration?> getTimeUntilExpiration() async {
    final expiresAt = await tokenStorage.getExpiresAt();
    if (expiresAt == null) return null;

    final diff = expiresAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }
}

final sessionManagerProvider = Provider((ref) => SessionManager(
  tokenStorage: TokenStorage(),
  authApi: ref.watch(authApiProvider),
));
```

---

## 6. 백그라운드에서 토큰 갱신

### lib/services/background_token_refresh.dart

```dart
// ios/Runner/GeneratedPluginRegistrant.m에 추가
// Android: android/app/src/main/AndroidManifest.xml에 권한 추가

class BackgroundTokenRefresh {
  static const platform = MethodChannel('com.hyfata.agora/background');

  /// 백그라운드 토큰 갱신 예약
  static Future<void> scheduleTokenRefresh() async {
    try {
      await platform.invokeMethod('scheduleTokenRefresh');
    } catch (e) {
      AppLogger.error('Failed to schedule background token refresh', error: e);
    }
  }

  /// 백그라운드 작업 취소
  static Future<void> cancelTokenRefresh() async {
    try {
      await platform.invokeMethod('cancelTokenRefresh');
    } catch (e) {
      AppLogger.error('Failed to cancel background token refresh', error: e);
    }
  }
}
```

---

## 7. 자동 로그인 테스트

```dart
test('Auto login with valid token', () async {
  // 1. 유효한 토큰 저장
  await SecureStorageManager.saveAccessToken('valid_token');

  // 2. 앱 초기화
  final service = AppInitializationService(...);
  final status = await service.initialize();

  // 3. 홈 화면으로 이동 확인
  expect(status, AppInitStatus.authenticated);
});

test('Auto login with expired token', () async {
  // 1. 만료된 토큰 저장
  await SecureStorageManager.saveAccessToken('expired_token');

  // 2. Refresh Token으로 갱신
  final refreshed = await mockAuthApi.refreshToken();

  // 3. 새 토큰 저장
  expect(refreshed, true);
});

test('Auto login without token', () async {
  // 1. 토큰 없음
  // 2. 로그인 화면으로 이동
  final status = await appInitService.initialize();
  expect(status, AppInitStatus.needsLogin);
});
```

---

## 주의사항

1. **Splash Screen 필수**: 초기화 중 사용자에게 피드백 제공
2. **에러 처리**: 네트워크 오류 시 재시도 로직
3. **토큰 갱신**: 만료 5분 전에 자동 갱신
4. **프로필 캐싱**: 프로필 로드 실패 시 나중에 로드 가능하도록
5. **백그라운드 갱신**: 장시간 사용 시 토큰 갱신 필요

---

## 다음 단계

- FLUTTER_LOGOUT.md - 로그아웃 처리
- FLUTTER_AUTH_INTERCEPTOR.md - Dio 인터셉터 설정
