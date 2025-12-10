# Flutter OAuth 2.0 + PKCE 인증 구현

## 개요

OAuth 2.0 + PKCE를 사용한 안전한 모바일 인증 구현

---

## 인증 흐름 (PKCE)

```
┌─────────────┐                                    ┌─────────────┐
│   Flutter   │                                    │   Server    │
│     App     │                                    │  (OAuth)    │
└──────┬──────┘                                    └──────┬──────┘
       │                                                   │
       │ 1. code_verifier 생성 (43-128 chars)             │
       │    code_challenge = BASE64URL(SHA256(verifier))  │
       │                                                   │
       │ 2. /oauth/authorize?code_challenge              │
       ├──────────────────────────────────────────────────>│
       │                                                   │
       │ 3. 사용자 로그인                                 │
       │<──────────────────────────────────────────────────┤
       │                                                   │
       │ 4. Authorization Code 발급                       │
       │<──────────────────────────────────────────────────┤
       │                                                   │
       │ 5. /oauth/token (code + code_verifier)          │
       ├──────────────────────────────────────────────────>│
       │                                                   │
       │ 6. Access Token + Refresh Token                 │
       │<──────────────────────────────────────────────────┤
```

---

## 1. PKCE 유틸리티

### lib/core/utils/pkce_util.dart

```dart
import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class PkceUtil {
  /// 43-128 자 길이의 code_verifier 생성
  static String generateCodeVerifier() {
    const characters =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    final values = List<int>.generate(128, (i) => random.nextInt(256));

    final verifier = List<int>.generate(
      43 + random.nextInt(128 - 43 + 1),
      (i) => characters.codeUnitAt(random.nextInt(characters.length)),
    );

    return String.fromCharCodes(verifier);
  }

  /// code_verifier에서 code_challenge 생성 (S256)
  static String generateCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);

    // BASE64URL 인코딩 (표준 Base64에서 +, /, = 제거)
    return base64Url
        .encode(digest.bytes)
        .toString()
        .replaceAll('=', '');
  }

  /// 다른 기기에서도 동일하게 계산되도록 (테스트용)
  static String generateCodeChallengeFixed(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64Url
        .encode(digest.bytes)
        .toString()
        .replaceAll('=', '');
  }
}
```

---

## 2. 인증 저장소 (Secure Storage)

### lib/core/utils/secure_storage.dart

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _agoraIdKey = 'agora_id';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      keyEncryptionAlgorithm: KeyEncryptionAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_available_when_unlocked_this_device_only,
    ),
  );

  // Access Token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // Refresh Token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // 사용자 정보
  Future<void> saveUserInfo(String userId, String email, String agoraId) async {
    await Future.wait([
      _storage.write(key: _userIdKey, value: userId),
      _storage.write(key: _userEmailKey, value: email),
      _storage.write(key: _agoraIdKey, value: agoraId),
    ]);
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  Future<String?> getAgoraId() async {
    return await _storage.read(key: _agoraIdKey);
  }

  // 모든 데이터 삭제 (로그아웃)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // 토큰만 삭제
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }
}
```

---

## 3. 인증 API (Data Source)

### lib/data/datasources/remote/auth_api.dart

```dart
import 'package:dio/dio.dart';
import 'package:agora_app/data/models/auth_response.dart';
import 'package:agora_app/core/constants/api_endpoints.dart';

class AuthApi {
  final Dio dio;

  AuthApi(this.dio);

  /// OAuth 로그인 페이지로 리다이렉트
  /// 사용자가 로그인 후 Authorization Code를 얻음
  String getLoginUrl(String codeChallenge) {
    return '${ApiEndpoints.baseUrl}/oauth/authorize'
        '?client_id=flutter_mobile'
        '&response_type=code'
        '&redirect_uri=com.hyfata.agora://oauth/callback'
        '&code_challenge=$codeChallenge'
        '&code_challenge_method=S256';
  }

  /// Authorization Code를 Access Token으로 교환
  Future<AuthResponse> tokenExchange({
    required String code,
    required String codeVerifier,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.tokenEndpoint,
        data: {
          'grant_type': 'authorization_code',
          'code': code,
          'code_verifier': codeVerifier,
          'client_id': 'flutter_mobile',
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Access Token 갱신
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        ApiEndpoints.tokenEndpoint,
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': 'flutter_mobile',
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 로그아웃
  Future<void> logout(String accessToken) async {
    try {
      await dio.post(
        ApiEndpoints.logoutEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
    } on DioException catch (e) {
      // 로그아웃 실패해도 로컬 토큰은 삭제
      print('로그아웃 API 실패: $e');
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response?.statusCode == 401) {
      return Exception('인증 실패: 이메일 또는 비밀번호가 올바르지 않습니다');
    } else if (e.response?.statusCode == 400) {
      final message = e.response?.data['message'] ?? 'Invalid request';
      return Exception('요청 오류: $message');
    } else {
      return Exception('네트워크 오류: ${e.message}');
    }
  }
}

final authApiProvider = Provider((ref) => AuthApi(ref.watch(apiClientProvider).dio));
```

---

## 4. 인증 Repository (비즈니스 로직)

### lib/data/repositories/auth_repository.dart

```dart
import 'package:agora_app/core/utils/pkce_util.dart';
import 'package:agora_app/core/utils/secure_storage.dart';
import 'package:agora_app/data/datasources/remote/auth_api.dart';
import 'package:agora_app/data/models/auth_response.dart';

class AuthRepository {
  final AuthApi authApi;
  final SecureStorageManager storage;

  AuthRepository({required this.authApi, required this.storage});

  /// 1단계: 로그인 URL 생성
  /// code_verifier 생성 및 저장 → code_challenge 계산 → 로그인 URL 반환
  Future<Map<String, String>> generateLoginUrl() async {
    final codeVerifier = PkceUtil.generateCodeVerifier();
    final codeChallenge = PkceUtil.generateCodeChallenge(codeVerifier);

    // code_verifier를 메모리에 저장 (임시)
    // 또는 앱이 백그라운드로 가지 않으면 메모리만 사용
    _codeVerifier = codeVerifier;

    return {
      'loginUrl': authApi.getLoginUrl(codeChallenge),
      'codeVerifier': codeVerifier,
    };
  }

  /// 2단계: Authorization Code로 로그인
  Future<void> loginWithAuthCode({
    required String authCode,
    required String codeVerifier,
  }) async {
    final response = await authApi.tokenExchange(
      code: authCode,
      codeVerifier: codeVerifier,
    );

    // 토큰 저장
    await storage.saveAccessToken(response.accessToken);
    await storage.saveRefreshToken(response.refreshToken);
    await storage.saveUserInfo(
      response.userId.toString(),
      response.email,
      response.agoraId,
    );
  }

  /// Access Token 갱신
  Future<void> refreshAccessToken() async {
    final currentRefreshToken = await storage.getRefreshToken();
    if (currentRefreshToken == null) {
      throw Exception('Refresh token not found');
    }

    final response = await authApi.refreshToken(currentRefreshToken);

    // 새 토큰 저장
    await storage.saveAccessToken(response.accessToken);
    await storage.saveRefreshToken(response.refreshToken);
  }

  /// 로그아웃
  Future<void> logout() async {
    final accessToken = await storage.getAccessToken();
    if (accessToken != null) {
      await authApi.logout(accessToken);
    }

    // 로컬 데이터 삭제
    await storage.clearAll();
  }

  /// 현재 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    final token = await storage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // 메모리에 code_verifier 임시 저장 (앱 실행 중만)
  String? _codeVerifier;
}

final authRepositoryProvider = Provider((ref) => AuthRepository(
  authApi: ref.watch(authApiProvider),
  storage: SecureStorageManager(),
));
```

---

## 5. 인증 상태 관리 (Provider)

### lib/presentation/providers/auth_provider.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_app/data/repositories/auth_repository.dart';

enum AuthState {
  initial,       // 초기 상태
  loading,       // 로그인 중
  authenticated, // 로그인됨
  unauthenticated, // 로그아웃
  error,         // 에러
}

class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  final AuthRepository authRepository;

  AuthNotifier(this.authRepository) : super(const AsyncValue.data(AuthState.initial)) {
    _checkAuthStatus();
  }

  /// 초기 상태 확인
  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await authRepository.isLoggedIn();
      state = AsyncValue.data(
        isLoggedIn ? AuthState.authenticated : AuthState.unauthenticated,
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// 로그인 URL 생성
  Future<Map<String, String>> generateLoginUrl() async {
    return await authRepository.generateLoginUrl();
  }

  /// Authorization Code로 로그인
  Future<void> loginWithAuthCode({
    required String authCode,
    required String codeVerifier,
  }) async {
    state = const AsyncValue.loading();
    try {
      await authRepository.loginWithAuthCode(
        authCode: authCode,
        codeVerifier: codeVerifier,
      );
      state = const AsyncValue.data(AuthState.authenticated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// 토큰 갱신
  Future<void> refreshToken() async {
    try {
      await authRepository.refreshAccessToken();
    } catch (e) {
      // 토큰 갱신 실패 → 로그아웃
      await logout();
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      await authRepository.logout();
      state = const AsyncValue.data(AuthState.unauthenticated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

// 편의용 Provider: 로그인 여부
final isAuthenticatedProvider = Provider((ref) {
  return ref.watch(authProvider).whenData((state) => state == AuthState.authenticated);
});

// 편의용 Provider: 현재 Access Token
final accessTokenProvider = FutureProvider((ref) async {
  final storage = SecureStorageManager();
  return await storage.getAccessToken();
});
```

---

## 6. 로그인 화면 (UI)

### lib/presentation/screens/auth/login_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agora_app/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  StreamSubscription? _deepLinkSubscription;
  String? _codeVerifier;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeDeepLinkListener();
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  /// Deep Link 리스너 설정
  void _initializeDeepLinkListener() {
    _deepLinkSubscription = uriLinkStream.listen(
      (String? link) {
        if (link != null) {
          _handleDeepLink(link);
        }
      },
      onError: (err) {
        print('Deep link error: $err');
      },
    );
  }

  /// Deep Link 처리 (Callback URI)
  /// 예: com.hyfata.agora://oauth/callback?code=abc123
  void _handleDeepLink(String link) {
    final uri = Uri.parse(link);
    final authCode = uri.queryParameters['code'];

    if (authCode != null && _codeVerifier != null) {
      _loginWithAuthCode(authCode);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: 인증 코드를 받을 수 없습니다')),
      );
    }
  }

  /// OAuth 로그인 시작
  Future<void> _startOAuthLogin() async {
    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final result = await authNotifier.generateLoginUrl();

      _codeVerifier = result['codeVerifier'];
      final loginUrl = result['loginUrl']!;

      // 브라우저에서 로그인 URL 열기
      if (await canLaunchUrl(Uri.parse(loginUrl))) {
        await launchUrl(
          Uri.parse(loginUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw Exception('Cannot launch login URL');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 시작 실패: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Authorization Code로 로그인
  Future<void> _loginWithAuthCode(String authCode) async {
    if (_codeVerifier == null) return;

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.loginWithAuthCode(
        authCode: authCode,
        codeVerifier: _codeVerifier!,
      );

      // 로그인 성공 → 홈 화면으로 이동
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agora - 로그인')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Agora에 로그인하세요', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _startOAuthLogin,
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    )
                  : Text('OAuth로 로그인'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 7. 토큰 인터셉터 (자동 갱신)

### lib/data/datasources/remote/token_interceptor.dart

```dart
import 'package:dio/dio.dart';
import 'package:agora_app/core/utils/secure_storage.dart';
import 'package:agora_app/data/repositories/auth_repository.dart';

class TokenInterceptor extends Interceptor {
  final SecureStorageManager storage;
  final AuthRepository authRepository;

  TokenInterceptor({
    required this.storage,
    required this.authRepository,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 모든 요청에 Access Token 추가
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
    // 401 (Unauthorized) 응답 처리
    if (err.response?.statusCode == 401) {
      try {
        // 토큰 갱신 시도
        await authRepository.refreshAccessToken();

        // 원래 요청 재시도
        final newToken = await storage.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

        return handler.resolve(await dio.request(err.requestOptions.path));
      } catch (e) {
        // 토큰 갱신 실패 → 로그아웃
        await storage.clearAll();
        return handler.reject(err);
      }
    }

    return handler.next(err);
  }
}
```

---

## 8. Deep Link 설정

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

## 주의사항

1. **code_verifier 저장**: 메모리에 임시 저장 (앱 재시작 시 재생성)
2. **Refresh Token 갱신**: 자동으로 처리되도록 인터셉터 설정
3. **Deep Link**: Android/iOS 설정 필수
4. **HTTPS**: 프로덕션 환경에서 HTTPS 사용 필수

---

## 다음 단계

- FLUTTER_TOKEN_MANAGEMENT.md - 토큰 관리 심화
- FLUTTER_API_CLIENT.md - API 클라이언트 고급 설정
