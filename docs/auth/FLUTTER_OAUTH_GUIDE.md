# Flutter OAuth 2.0 + PKCE 전체 구현 가이드

## 개요

보안이 강화된 OAuth 2.0 PKCE 흐름을 Flutter에서 구현하는 완벽한 가이드

---

## OAuth 2.0 + PKCE 인증 흐름

```
┌──────────────┐                                    ┌──────────────┐
│ Flutter App  │                                    │   Server     │
└──────┬───────┘                                    └──────┬───────┘
       │                                                   │
       │ 1. code_verifier 생성                             │
       │    SHA256(code_verifier) → code_challenge        │
       │                                                   │
       │ 2. 로그인 페이지 URL 생성 + code_challenge       │
       ├──────────────────────────────────────────────────>│
       │    /oauth/authorize?code_challenge               │
       │                                                   │
       │ 3. 사용자 로그인 (WebView 또는 브라우저)          │
       │<──────────────────────────────────────────────────┤
       │                                                   │
       │ 4. Authorization Code 발급 + Deep Link           │
       │<──────────────────────────────────────────────────┤
       │    com.hyfata.agora://oauth/callback?code=...    │
       │                                                   │
       │ 5. code + code_verifier로 Token 교환             │
       ├──────────────────────────────────────────────────>│
       │    /oauth/token                                  │
       │                                                   │
       │ 6. Access Token + Refresh Token 반환             │
       │<──────────────────────────────────────────────────┤
       │    {                                             │
       │      "accessToken": "...",                       │
       │      "refreshToken": "...",                      │
       │      "expiresIn": 3600                           │
       │    }                                             │
```

---

## 1단계: 프로젝트 설정

### pubspec.yaml 의존성

```yaml
dependencies:
  flutter:
    sdk: flutter

  # OAuth 및 보안
  uni_links: ^0.0.2
  url_launcher: ^6.2.0
  flutter_secure_storage: ^9.1.0

  # HTTP 통신
  dio: ^5.4.0

  # 상태 관리
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0

  # 암호화
  crypto: ^3.0.0
```

---

## 2단계: PKCE 코드 생성

### lib/utils/pkce_util.dart

```dart
import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class PkceUtil {
  /// 43-128 자 길이의 난수 생성
  static String generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(128, (i) => random.nextInt(256));

    return base64Url
        .encode(values)
        .replaceAll('=', '')
        .substring(0, 128);
  }

  /// SHA256 해싱 + Base64URL 인코딩
  static String generateCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);

    return base64Url
        .encode(digest.bytes)
        .replaceAll('=', '');
  }

  /// 검증 (테스트용)
  static bool verifyCodeChallenge(String codeVerifier, String codeChallenge) {
    return generateCodeChallenge(codeVerifier) == codeChallenge;
  }
}
```

---

## 2단계: Deep Link 설정

### Android (android/app/AndroidManifest.xml)

```xml
<activity
    android:name=".MainActivity"
    android:launchMode="singleTop">

    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
            android:scheme="com.hyfata.agora"
            android:host="oauth"
            android:pathPrefix="/callback" />
    </intent-filter>
</activity>
```

### iOS (ios/Runner/Info.plist)

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.hyfata.agora</string>
        </array>
    </dict>
</array>
```

---

## 3단계: 로그인 서비스 구현

### lib/services/oauth_service.dart

```dart
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agora_app/utils/pkce_util.dart';
import 'package:agora_app/core/utils/secure_storage.dart';

class OAuthService {
  static const String _baseUrl = 'https://api.hyfata.com';
  static const String _redirectUri = 'com.hyfata.agora://oauth/callback';
  static const String _clientId = 'flutter_mobile';

  final _storage = SecureStorageManager();
  StreamSubscription? _deepLinkSubscription;

  String? _codeVerifier;
  Function(String)? _onAuthSuccess;
  Function(String)? _onAuthError;

  /// Deep Link 리스너 초기화
  void initializeDeepLinkListener({
    Function(String)? onAuthSuccess,
    Function(String)? onAuthError,
  }) {
    _onAuthSuccess = onAuthSuccess;
    _onAuthError = onAuthError;

    _deepLinkSubscription = uriLinkStream.listen(
      (String? link) {
        if (link != null) {
          _handleDeepLink(link);
        }
      },
      onError: (err) {
        _onAuthError?.call('Deep link error: $err');
      },
    );

    // 앱 실행 중 Deep Link 처리
    uriLinkStream.listen((String? link) {
      if (link != null) {
        _handleDeepLink(link);
      }
    });
  }

  /// Deep Link 처리 (Authorization Code 추출)
  void _handleDeepLink(String link) {
    try {
      final uri = Uri.parse(link);
      final authCode = uri.queryParameters['code'];
      final error = uri.queryParameters['error'];

      if (error != null) {
        _onAuthError?.call('Authorization failed: $error');
        return;
      }

      if (authCode != null && _codeVerifier != null) {
        _onAuthSuccess?.call(authCode);
      } else {
        _onAuthError?.call('Invalid callback: code or verifier missing');
      }
    } catch (e) {
      _onAuthError?.call('Failed to parse deep link: $e');
    }
  }

  /// 1단계: 로그인 페이지로 리다이렉트
  Future<void> startOAuthLogin() async {
    try {
      // PKCE 코드 생성
      _codeVerifier = PkceUtil.generateCodeVerifier();
      final codeChallenge = PkceUtil.generateCodeChallenge(_codeVerifier!);

      // 로그인 URL 구성
      final loginUrl = Uri(
        scheme: 'https',
        host: 'api.hyfata.com',
        path: '/oauth/authorize',
        queryParameters: {
          'client_id': _clientId,
          'response_type': 'code',
          'redirect_uri': _redirectUri,
          'code_challenge': codeChallenge,
          'code_challenge_method': 'S256',
          'state': _generateState(),
        },
      ).toString();

      // 브라우저에서 로그인 페이지 열기
      if (await canLaunchUrl(Uri.parse(loginUrl))) {
        await launchUrl(
          Uri.parse(loginUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        _onAuthError?.call('Cannot launch login URL');
      }
    } catch (e) {
      _onAuthError?.call('OAuth login failed: $e');
    }
  }

  /// 2단계: Authorization Code로 Token 교환
  Future<Map<String, dynamic>> exchangeCodeForToken(String authCode) async {
    try {
      if (_codeVerifier == null) {
        throw Exception('code_verifier is null');
      }

      final dio = Dio();
      final response = await dio.post(
        '$_baseUrl/oauth/token',
        data: {
          'grant_type': 'authorization_code',
          'code': authCode,
          'code_verifier': _codeVerifier,
          'client_id': _clientId,
        },
        options: Options(
          contentType: 'application/json',
        ),
      );

      return response.data;
    } catch (e) {
      _onAuthError?.call('Token exchange failed: $e');
      rethrow;
    }
  }

  /// State 생성 (CSRF 방지)
  String _generateState() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values).replaceAll('=', '');
  }

  /// 정리
  void dispose() {
    _deepLinkSubscription?.cancel();
    _codeVerifier = null;
  }
}

final oauthServiceProvider = Provider((ref) => OAuthService());
```

---

## 4단계: 토큰 저장 및 관리

### lib/utils/secure_storage.dart

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _expiresAtKey = 'token_expires_at';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      keyEncryptionAlgorithm: KeyEncryptionAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_available_when_unlocked_this_device_only,
    ),
  );

  /// Access Token 저장
  Future<void> saveAccessToken(String token, int expiresIn) async {
    await _storage.write(key: _accessTokenKey, value: token);

    // 만료 시간 저장
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
    await _storage.write(
      key: _expiresAtKey,
      value: expiresAt.toIso8601String(),
    );
  }

  /// Refresh Token 저장
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// 토큰 쌍 저장
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken, expiresIn),
      saveRefreshToken(refreshToken),
    ]);
  }

  /// Access Token 조회
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Refresh Token 조회
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Access Token 유효성 확인
  Future<bool> isAccessTokenValid() async {
    final expiresAtStr = await _storage.read(key: _expiresAtKey);
    if (expiresAtStr == null) return false;

    final expiresAt = DateTime.parse(expiresAtStr);
    return DateTime.now().isBefore(expiresAt);
  }

  /// 사용자 정보 저장
  Future<void> saveUserInfo({
    required String userId,
    required String email,
  }) async {
    await Future.wait([
      _storage.write(key: _userIdKey, value: userId),
      _storage.write(key: _userEmailKey, value: email),
    ]);
  }

  /// 모든 데이터 삭제 (로그아웃)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
```

---

## 5단계: 인증 API 클라이언트

### lib/api/auth_api.dart

```dart
import 'package:dio/dio.dart';

class AuthApi {
  final Dio dio;
  static const String _baseUrl = 'https://api.hyfata.com';

  AuthApi({Dio? dio}) : dio = dio ?? Dio(BaseOptions(baseUrl: _baseUrl));

  /// Access Token 갱신
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '/oauth/token',
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': 'flutter_mobile',
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 로그아웃
  Future<void> logout(String accessToken) async {
    try {
      await dio.post(
        '/oauth/logout',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
    } on DioException {
      // 로그아웃 API 실패해도 로컬 토큰은 삭제
      rethrow;
    }
  }

  Exception _handleError(DioException e) {
    if (e.response?.statusCode == 401) {
      return Exception('Token expired or invalid');
    } else if (e.response?.statusCode == 400) {
      return Exception('Invalid request');
    } else {
      return Exception('Network error: ${e.message}');
    }
  }
}

final authApiProvider = Provider((ref) => AuthApi());
```

---

## 6단계: 인증 상태 관리

### lib/providers/auth_provider.dart

```dart
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? accessToken;
  final String? error;

  AuthState({
    required this.status,
    this.userId,
    this.email,
    this.accessToken,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    String? accessToken,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      accessToken: accessToken ?? this.accessToken,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApi authApi;
  final SecureStorageManager storage;
  final OAuthService oauthService;

  AuthNotifier({
    required this.authApi,
    required this.storage,
    required this.oauthService,
  }) : super(AuthState(status: AuthStatus.initial)) {
    _initializeAuth();
  }

  /// 앱 시작 시 기존 토큰 확인
  Future<void> _initializeAuth() async {
    try {
      final token = await storage.getAccessToken();
      final isValid = await storage.isAccessTokenValid();

      if (token != null && isValid) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          accessToken: token,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  /// 로그인 시작
  Future<void> startLogin() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      oauthService.initializeDeepLinkListener(
        onAuthSuccess: (authCode) async {
          await _handleAuthCode(authCode);
        },
        onAuthError: (error) {
          state = state.copyWith(
            status: AuthStatus.error,
            error: error,
          );
        },
      );

      await oauthService.startOAuthLogin();
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Authorization Code 처리
  Future<void> _handleAuthCode(String authCode) async {
    try {
      final tokenResponse = await oauthService.exchangeCodeForToken(authCode);

      await storage.saveTokens(
        accessToken: tokenResponse['accessToken'],
        refreshToken: tokenResponse['refreshToken'],
        expiresIn: tokenResponse['expiresIn'] ?? 3600,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        accessToken: tokenResponse['accessToken'],
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  /// 토큰 갱신
  Future<void> refreshAccessToken() async {
    try {
      final refreshToken = await storage.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token');
      }

      final response = await authApi.refreshToken(refreshToken);

      await storage.saveTokens(
        accessToken: response['accessToken'],
        refreshToken: response['refreshToken'],
        expiresIn: response['expiresIn'] ?? 3600,
      );

      state = state.copyWith(
        accessToken: response['accessToken'],
      );
    } catch (e) {
      // 토큰 갱신 실패 → 로그아웃
      await logout();
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      final token = await storage.getAccessToken();
      if (token != null) {
        await authApi.logout(token);
      }
    } catch (e) {
      // 로그아웃 API 실패해도 계속 진행
    } finally {
      await storage.clearAll();
      state = AuthState(status: AuthStatus.unauthenticated);
      oauthService.dispose();
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    authApi: ref.watch(authApiProvider),
    storage: SecureStorageManager(),
    oauthService: ref.watch(oauthServiceProvider),
  );
});
```

---

## 7단계: 로그인 화면 구현

### lib/screens/login_screen.dart

```dart
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Agora - 로그인')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Agora에 로그인하세요',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 40),
            if (authState.status == AuthStatus.loading)
              Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('로그인 중...'),
                ],
              )
            else if (authState.status == AuthStatus.error)
              Column(
                children: [
                  Icon(Icons.error, color: Colors.red, size: 40),
                  SizedBox(height: 16),
                  Text('오류: ${authState.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).startLogin();
                    },
                    child: Text('다시 시도'),
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                icon: Icon(Icons.login),
                label: Text('OAuth로 로그인'),
                onPressed: () {
                  ref.read(authProvider.notifier).startLogin();
                },
              ),
          ],
        ),
      ),
    );
  }
}
```

---

## 8단계: HTTP 인터셉터 (자동 토큰 갱신)

### lib/api/token_interceptor.dart

```dart
class TokenInterceptor extends Interceptor {
  final SecureStorageManager storage;
  final AuthApi authApi;

  TokenInterceptor({
    required this.storage,
    required this.authApi,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      try {
        final refreshToken = await storage.getRefreshToken();
        if (refreshToken != null) {
          // 토큰 갱신
          final response = await authApi.refreshToken(refreshToken);
          await storage.saveTokens(
            accessToken: response['accessToken'],
            refreshToken: response['refreshToken'],
            expiresIn: response['expiresIn'] ?? 3600,
          );

          // 원래 요청 재시도
          err.requestOptions.headers['Authorization'] =
              'Bearer ${response['accessToken']}';

          return handler.resolve(
            await Dio().request(err.requestOptions.path),
          );
        }
      } catch (e) {
        // 토큰 갱신 실패 → 로그아웃
        await storage.clearAll();
      }
    }
    return handler.next(err);
  }
}
```

---

## 주의사항

1. **PKCE 필수**: 모바일 앱에서는 반드시 PKCE 사용
2. **Secure Storage**: 토큰은 암호화된 저장소에만 저장
3. **HTTPS**: 프로덕션 환경에서는 반드시 HTTPS 사용
4. **토큰 갱신**: 401 에러 시 자동으로 토큰 갱신
5. **Deep Link**: 각 플랫폼별로 정확히 설정
6. **State 값**: CSRF 방지를 위해 State 값 검증

---

## 다음 단계

- FLUTTER_TOKEN_MANAGEMENT.md - 고급 토큰 관리
- FLUTTER_AUTO_LOGIN.md - 자동 로그인 구현
