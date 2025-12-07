# Flutter 인증 상태 관리 (Riverpod)

## 개요

Riverpod을 사용한 체계적인 인증 상태 관리

---

## 상태 정의

### lib/presentation/providers/auth_state.dart

```dart
enum AuthStatus {
  initial,           // 초기 상태
  checking,          // 토큰 확인 중
  authenticating,    // 로그인 중
  authenticated,     // 로그인됨
  unauthenticated,   // 로그아웃
  error,             // 오류
}

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? agoraId;
  final String? accessToken;
  final DateTime? expiresAt;
  final String? errorMessage;

  AuthState({
    required this.status,
    this.userId,
    this.email,
    this.agoraId,
    this.accessToken,
    this.expiresAt,
    this.errorMessage,
  });

  /// 사본 생성 (immutable update)
  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    String? agoraId,
    String? accessToken,
    DateTime? expiresAt,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      agoraId: agoraId ?? this.agoraId,
      accessToken: accessToken ?? this.accessToken,
      expiresAt: expiresAt ?? this.expiresAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// 로그인되었는지 확인
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// 로그인 중인지 확인
  bool get isAuthenticating => status == AuthStatus.authenticating;

  /// 토큰이 유효한지 확인
  bool get isTokenValid {
    if (expiresAt == null) return false;
    return DateTime.now().isBefore(expiresAt!);
  }

  /// 토큰 만료까지 남은 시간
  Duration? get timeUntilExpiration {
    if (expiresAt == null) return null;
    return expiresAt!.difference(DateTime.now());
  }
}
```

---

## 인증 Notifier

### lib/presentation/providers/auth_notifier.dart

```dart
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApi authApi;
  final TokenStorage tokenStorage;
  final TokenRefreshService tokenRefreshService;
  final LogoutService logoutService;

  AuthNotifier({
    required this.authApi,
    required this.tokenStorage,
    required this.tokenRefreshService,
    required this.logoutService,
  }) : super(AuthState(status: AuthStatus.initial)) {
    _initialize();
  }

  /// 초기화: 저장된 토큰 확인
  Future<void> _initialize() async {
    try {
      state = state.copyWith(status: AuthStatus.checking);

      final isLoggedIn = await tokenStorage.isLoggedIn();

      if (!isLoggedIn) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }

      // 토큰 유효성 확인
      final expiresAt = await tokenStorage.getExpiresAt();
      final token = await tokenStorage.getAccessToken();
      final email = await tokenStorage.getUserEmail();
      final agoraId = await tokenStorage.getAgoraId();

      state = state.copyWith(
        status: AuthStatus.authenticated,
        accessToken: token,
        email: email,
        agoraId: agoraId,
        expiresAt: expiresAt,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Initialization failed: $e',
      );
    }
  }

  /// OAuth 로그인 시작
  Future<void> startOAuthLogin({
    required String loginUrl,
    required String codeVerifier,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating);

    try {
      // Deep Link 리스너 설정 (별도 구현)
      // 사용자가 브라우저에서 인증 후 돌아옴
      // → onAuthorizationCodeReceived() 호출
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Login failed: $e',
      );
    }
  }

  /// Authorization Code로 토큰 교환
  Future<void> exchangeCodeForToken({
    required String code,
    required String codeVerifier,
  }) async {
    try {
      final response = await authApi.tokenExchange(
        code: code,
        codeVerifier: codeVerifier,
      );

      // 토큰 저장
      await tokenStorage.saveTokens(
        accessToken: response['accessToken'],
        refreshToken: response['refreshToken'],
        expiresIn: response['expiresIn'] ?? 3600,
      );

      // 사용자 정보 저장
      await tokenStorage.saveUserInfo(
        userId: response['userId']?.toString() ?? '',
        email: response['email'] ?? '',
        agoraId: response['agoraId'] ?? '',
      );

      // 상태 업데이트
      final expiresAt = DateTime.now()
          .add(Duration(seconds: response['expiresIn'] ?? 3600));

      state = state.copyWith(
        status: AuthStatus.authenticated,
        accessToken: response['accessToken'],
        email: response['email'],
        agoraId: response['agoraId'],
        expiresAt: expiresAt,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Token exchange failed: $e',
      );
      rethrow;
    }
  }

  /// 토큰 갱신
  Future<bool> refreshToken() async {
    try {
      final success = await tokenRefreshService.refreshAccessToken();

      if (success) {
        // 새 토큰 정보 로드
        final token = await tokenStorage.getAccessToken();
        final expiresAt = await tokenStorage.getExpiresAt();

        state = state.copyWith(
          accessToken: token,
          expiresAt: expiresAt,
        );

        return true;
      }

      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Token refresh failed: $e',
      );
      return false;
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      state = state.copyWith(status: AuthStatus.checking);
      await logoutService.logout();

      state = AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Logout failed: $e',
      );
      rethrow;
    }
  }

  /// 강제 로그아웃 (네트워크 오류 등)
  Future<void> forceLogout() async {
    try {
      await tokenStorage.clearSession();
      state = AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      // 무시하고 진행
    }
  }

  /// 에러 메시지 클리어
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
```

---

## 프로바이더 정의

### lib/presentation/providers/auth_provider.dart

```dart
// 인증 상태 프로바이더
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    authApi: ref.watch(authApiProvider),
    tokenStorage: TokenStorage(),
    tokenRefreshService: ref.watch(tokenRefreshServiceProvider),
    logoutService: ref.watch(logoutServiceProvider),
  );
});

// 편의용 프로바이더들
final isAuthenticatedProvider = Provider((ref) {
  return ref.watch(authProvider.select((state) => state.isAuthenticated));
});

final isAuthenticatingProvider = Provider((ref) {
  return ref.watch(authProvider.select((state) => state.isAuthenticating));
});

final currentUserEmailProvider = Provider<String?>((ref) {
  return ref.watch(authProvider.select((state) => state.email));
});

final currentAgoraIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider.select((state) => state.agoraId));
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider.select((state) => state.errorMessage));
});

final tokenValidityProvider = Provider((ref) {
  final auth = ref.watch(authProvider);
  if (auth.expiresAt == null) return false;
  return DateTime.now().isBefore(auth.expiresAt!);
});

final timeUntilTokenExpirationProvider = Provider<Duration?>((ref) {
  final auth = ref.watch(authProvider);
  return auth.timeUntilExpiration;
});
```

---

## 사용 예제

### 로그인 위젯

```dart
class LoginButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return ElevatedButton.icon(
      onPressed: authState.isAuthenticating
          ? null
          : () => _handleLogin(context, ref),
      icon: authState.isAuthenticating
          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator())
          : Icon(Icons.login),
      label: Text(authState.isAuthenticating ? '로그인 중...' : '로그인'),
    );
  }

  Future<void> _handleLogin(BuildContext context, WidgetRef ref) async {
    try {
      final authNotifier = ref.read(authProvider.notifier);
      // 로그인 로직...
      await authNotifier.exchangeCodeForToken(
        code: 'auth_code',
        codeVerifier: 'code_verifier',
      );

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: $e')),
      );
    }
  }
}
```

### 프로필 표시

```dart
class ProfileHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(currentUserEmailProvider);
    final agoraId = ref.watch(currentAgoraIdProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      return Text('로그인하지 않음');
    }

    return Column(
      children: [
        Text('이메일: $email'),
        Text('Agora ID: $agoraId'),
      ],
    );
  }
}
```

### 토큰 만료 모니터링

```dart
class TokenExpirationMonitor extends ConsumerStatefulWidget {
  @override
  ConsumerState<TokenExpirationMonitor> createState() =>
      _TokenExpirationMonitorState();
}

class _TokenExpirationMonitorState
    extends ConsumerState<TokenExpirationMonitor> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  void _startMonitoring() {
    _timer = Timer.periodic(Duration(minutes: 1), (_) {
      final duration = ref.read(timeUntilTokenExpirationProvider);

      if (duration != null && duration.inMinutes < 5) {
        // 토큰 갱신
        ref.read(authProvider.notifier).refreshToken();

        // 사용자 알림
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('토큰이 갱신되었습니다')),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
```

### 에러 표시

```dart
class AuthErrorDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(authErrorProvider);

    if (error == null) return SizedBox.shrink();

    return Container(
      color: Colors.red[100],
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red),
          SizedBox(width: 12),
          Expanded(child: Text(error)),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              ref.read(authProvider.notifier).clearError();
            },
          ),
        ],
      ),
    );
  }
}
```

---

## 라우팅 가드

```dart
class AuthenticatedRoute extends ConsumerWidget {
  final Widget child;

  const AuthenticatedRoute({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('인증이 필요합니다'),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                ),
                child: Text('로그인'),
              ),
            ],
          ),
        ),
      );
    }

    return child;
  }
}
```

---

## 테스트

```dart
test('AuthState initialization', () async {
  final state = AuthState(status: AuthStatus.initial);

  expect(state.isAuthenticated, false);
  expect(state.isAuthenticating, false);
});

test('AuthNotifier login flow', () async {
  final container = ProviderContainer(
    overrides: [
      authApiProvider.overrideWithValue(mockAuthApi),
      tokenStorageProvider.overrideWithValue(mockTokenStorage),
    ],
  );

  final notifier = container.read(authProvider.notifier);

  await notifier.exchangeCodeForToken(
    code: 'test_code',
    codeVerifier: 'test_verifier',
  );

  expect(
    container.read(authProvider).status,
    AuthStatus.authenticated,
  );
});
```

---

## 주의사항

1. **불변성**: copyWith로 상태 업데이트
2. **Select**: 특정 필드만 감시하여 리빌드 최적화
3. **에러 처리**: 모든 async 작업에서 에러 처리
4. **메모리**: 자동 정리는 아니므로, 필요 시 dispose 구현

---

## 다음 단계

- FLUTTER_LOGIN_UI_FLOW.md - 로그인 UI 흐름
