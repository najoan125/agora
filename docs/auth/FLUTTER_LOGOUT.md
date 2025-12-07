# Flutter 로그아웃 처리

## 개요

안전한 로그아웃 및 세션 정리

---

## 로그아웃 흐름

```
로그아웃 버튼 클릭
  ↓
서버에 로그아웃 요청
  ↓
저장된 토큰/정보 삭제
  ↓
관련 리소스 정리 (WebSocket, FCM)
  ↓
로그인 화면으로 이동
```

---

## 1. 로그아웃 서비스

### lib/services/logout_service.dart

```dart
class LogoutService {
  final AuthApi authApi;
  final SecureStorageManager storage;
  final WebSocketService webSocketService;
  final FcmService fcmService;

  LogoutService({
    required this.authApi,
    required this.storage,
    required this.webSocketService,
    required this.fcmService,
  });

  /// 완전한 로그아웃 처리
  Future<void> logout() async {
    AppLogger.info('Starting logout process');

    try {
      // 1단계: 서버에 로그아웃 요청
      await _notifyServerLogout();

      // 2단계: WebSocket 연결 종료
      await _disconnectWebSocket();

      // 3단계: FCM 토큰 등록 해제
      await _unregisterFcmToken();

      // 4단계: 로컬 저장소 정리
      await _clearLocalStorage();

      // 5단계: 캐시 정리
      await _clearCache();

      AppLogger.info('Logout completed successfully');
    } catch (e) {
      AppLogger.error('Error during logout', error: e);
      // 오류 발생해도 로컬 데이터는 정리
      await _clearLocalStorage();
      rethrow;
    }
  }

  /// 서버에 로그아웃 알림
  Future<void> _notifyServerLogout() async {
    try {
      final token = await storage.getAccessToken();
      if (token != null) {
        await authApi.logout(token);
        AppLogger.debug('Server logout notification sent');
      }
    } catch (e) {
      AppLogger.warning('Failed to notify server of logout: $e');
      // 서버 통신 실패해도 계속 진행
    }
  }

  /// WebSocket 연결 종료
  Future<void> _disconnectWebSocket() async {
    try {
      await webSocketService.disconnect();
      AppLogger.debug('WebSocket disconnected');
    } catch (e) {
      AppLogger.warning('Failed to disconnect WebSocket: $e');
    }
  }

  /// FCM 토큰 등록 해제
  Future<void> _unregisterFcmToken() async {
    try {
      await fcmService.unregisterFcmToken();
      AppLogger.debug('FCM token unregistered');
    } catch (e) {
      AppLogger.warning('Failed to unregister FCM token: $e');
    }
  }

  /// 로컬 저장소 정리
  Future<void> _clearLocalStorage() async {
    try {
      await storage.clearSession();
      AppLogger.debug('Local storage cleared');
    } catch (e) {
      AppLogger.error('Failed to clear local storage', error: e);
    }
  }

  /// 캐시 정리
  Future<void> _clearCache() async {
    try {
      // Hive, SharedPreferences 등의 캐시 정리
      final cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
      }
      AppLogger.debug('Cache cleared');
    } catch (e) {
      AppLogger.warning('Failed to clear cache: $e');
    }
  }
}

final logoutServiceProvider = Provider((ref) => LogoutService(
  authApi: ref.watch(authApiProvider),
  storage: SecureStorageManager(),
  webSocketService: ref.watch(webSocketServiceProvider),
  fcmService: ref.watch(fcmServiceProvider),
));
```

---

## 2. 인증 상태 업데이트

### lib/presentation/providers/auth_provider.dart 추가

```dart
class AuthNotifier extends StateNotifier<AuthState> {
  // ... 기존 코드 ...

  /// 로그아웃
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final logoutService = _ref.read(logoutServiceProvider);
      await logoutService.logout();

      state = AuthState(status: AuthStatus.unauthenticated);
      AppLogger.info('User logged out');
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Logout failed: $e',
      );
      AppLogger.error('Logout failed', error: e);
      rethrow;
    }
  }

  /// 네트워크 오류로 인한 강제 로그아웃
  Future<void> forceLogout() async {
    AppLogger.warning('Force logout triggered');

    try {
      final logoutService = _ref.read(logoutServiceProvider);
      await logoutService._clearLocalStorage();
    } finally {
      state = AuthState(status: AuthStatus.unauthenticated);
    }
  }
}
```

---

## 3. 로그아웃 UI

### lib/presentation/screens/settings/logout_dialog.dart

```dart
class LogoutDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text('로그아웃'),
      content: Text('로그아웃하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('취소'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await _performLogout(context, ref);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text('로그아웃'),
        ),
      ],
    );
  }

  Future<void> _performLogout(BuildContext context, WidgetRef ref) async {
    try {
      // 로딩 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃 중...')),
      );

      // 로그아웃 수행
      await ref.read(authProvider.notifier).logout();

      // 로그인 화면으로 이동
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그아웃 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
```

### 설정 화면에서 사용

```dart
class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('설정')),
      body: ListView(
        children: [
          // ... 다른 설정 항목들 ...

          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('로그아웃', style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => LogoutDialog(),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

---

## 4. 조건부 로그아웃 (만료, 권한 변경 등)

### lib/services/auto_logout_manager.dart

```dart
class AutoLogoutManager {
  final AuthApi authApi;
  final LogoutService logoutService;

  Timer? _authCheckTimer;

  /// 자동 로그아웃 모니터링 시작
  void startMonitoring() {
    _authCheckTimer = Timer.periodic(Duration(minutes: 5), (_) async {
      await _checkAuthStatus();
    });
  }

  /// 인증 상태 확인
  Future<void> _checkAuthStatus() async {
    try {
      // 서버에서 현재 권한 확인
      final status = await authApi.checkAuthStatus();

      if (status['isLoggedIn'] == false) {
        AppLogger.warning('User is no longer logged in on server');
        await logoutService.logout();
        // UI 업데이트 (로그인 화면으로 이동)
      }
    } catch (e) {
      AppLogger.debug('Could not verify auth status: $e');
    }
  }

  /// 모니터링 중지
  void stopMonitoring() {
    _authCheckTimer?.cancel();
    _authCheckTimer = null;
  }

  /// 정리
  void dispose() {
    stopMonitoring();
  }
}

final autoLogoutManagerProvider = Provider((ref) {
  final manager = AutoLogoutManager(
    authApi: ref.watch(authApiProvider),
    logoutService: ref.watch(logoutServiceProvider),
  );

  // 앱 시작 시 모니터링 시작
  manager.startMonitoring();

  // 프로바이더 폐기 시 정리
  ref.onDispose(() => manager.dispose());

  return manager;
});
```

---

## 5. 로그아웃 테스트

```dart
test('Complete logout process', () async {
  // 1. 로그인 상태 설정
  await storage.saveAccessToken('test_token');

  // 2. 로그아웃 실행
  final logoutService = LogoutService(...);
  await logoutService.logout();

  // 3. 검증
  final token = await storage.getAccessToken();
  expect(token, null);

  final isLoggedIn = await storage.isLoggedIn();
  expect(isLoggedIn, false);
});

test('Logout with server error', () async {
  // 1. 서버 오류 시뮬레이션
  when(mockAuthApi.logout(any))
      .thenThrow(Exception('Server error'));

  // 2. 로그아웃 실행
  final logoutService = LogoutService(...);
  await logoutService.logout();

  // 3. 로컬 데이터는 여전히 정리됨
  final token = await storage.getAccessToken();
  expect(token, null);
});
```

---

## 6. 모든 기기에서 로그아웃 (선택)

### lib/services/logout_all_devices_service.dart

```dart
class LogoutAllDevicesService {
  final AuthApi authApi;
  final LogoutService logoutService;

  /// 모든 기기에서 로그아웃
  Future<void> logoutAllDevices() async {
    try {
      // 서버에서 모든 세션 무효화
      await authApi.logoutAllDevices();

      // 현재 기기도 로그아웃
      await logoutService.logout();

      AppLogger.info('Logged out from all devices');
    } catch (e) {
      AppLogger.error('Failed to logout from all devices', error: e);
      rethrow;
    }
  }
}
```

---

## 주의사항

1. **순서 중요**: 서버 요청 → WebSocket → FCM → 로컬 정리
2. **에러 처리**: 서버 오류 시에도 로컬 정리 필수
3. **UI 업데이트**: 로그아웃 후 로그인 화면으로 이동
4. **리소스 정리**: WebSocket, Timer 등 모두 정리
5. **보안**: 로그아웃 시 캐시도 함께 정리

---

## 다음 단계

- FLUTTER_AUTH_INTERCEPTOR.md - Dio 인터셉터 설정
- FLUTTER_AUTH_STATE.md - 인증 상태 관리
