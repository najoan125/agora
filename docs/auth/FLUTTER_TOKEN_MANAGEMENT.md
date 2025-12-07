# Flutter 토큰 관리 및 갱신

## 개요

Access Token, Refresh Token의 안전한 관리와 자동 갱신 전략

---

## 토큰 수명 관리

### Access Token

- **유효 시간**: 1시간 (3600초)
- **저장 위치**: Secure Storage (암호화)
- **전송 방식**: Authorization Header (Bearer Token)
- **재발급**: Refresh Token으로 갱신

### Refresh Token

- **유효 시간**: 30일
- **저장 위치**: Secure Storage (암호화)
- **전송 방식**: POST 요청 본문
- **재발급**: 새로운 Refresh Token 발급

---

## 1. 토큰 저장소 (Secure Storage)

### lib/utils/token_storage.dart

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agora_app/core/utils/logger.dart';

class TokenStorage {
  static const String _accessTokenKey = 'oauth_access_token';
  static const String _refreshTokenKey = 'oauth_refresh_token';
  static const String _expiresAtKey = 'oauth_expires_at';
  static const String _tokenTypeKey = 'oauth_token_type';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      keyEncryptionAlgorithm: KeyEncryptionAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_available_when_unlocked_this_device_only,
    ),
  );

  /// 토큰 저장
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    String tokenType = 'Bearer',
  }) async {
    try {
      final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

      await Future.wait([
        _storage.write(key: _accessTokenKey, value: accessToken),
        _storage.write(key: _refreshTokenKey, value: refreshToken),
        _storage.write(key: _expiresAtKey, value: expiresAt.toIso8601String()),
        _storage.write(key: _tokenTypeKey, value: tokenType),
      ]);

      AppLogger.debug('Tokens saved successfully');
    } catch (e) {
      AppLogger.error('Failed to save tokens', error: e);
      rethrow;
    }
  }

  /// Access Token 조회
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      AppLogger.error('Failed to read access token', error: e);
      return null;
    }
  }

  /// Refresh Token 조회
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      AppLogger.error('Failed to read refresh token', error: e);
      return null;
    }
  }

  /// 만료 시간 조회
  Future<DateTime?> getExpiresAt() async {
    try {
      final expiresAtStr = await _storage.read(key: _expiresAtKey);
      if (expiresAtStr == null) return null;
      return DateTime.parse(expiresAtStr);
    } catch (e) {
      AppLogger.error('Failed to read expires at', error: e);
      return null;
    }
  }

  /// Access Token 유효 여부 확인
  Future<bool> isAccessTokenValid() async {
    try {
      final expiresAt = await getExpiresAt();
      if (expiresAt == null) return false;

      // 만료 5분 전에 갱신
      final bufferTime = Duration(minutes: 5);
      return DateTime.now().isBefore(expiresAt.subtract(bufferTime));
    } catch (e) {
      AppLogger.error('Failed to check token validity', error: e);
      return false;
    }
  }

  /// 토큰 갱신 필요 여부
  Future<bool> shouldRefreshToken() async {
    return !(await isAccessTokenValid());
  }

  /// 모든 토큰 삭제
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
        _storage.delete(key: _expiresAtKey),
        _storage.delete(key: _tokenTypeKey),
      ]);

      AppLogger.debug('Tokens cleared successfully');
    } catch (e) {
      AppLogger.error('Failed to clear tokens', error: e);
      rethrow;
    }
  }

  /// 토큰 정보 조회 (디버깅용)
  Future<Map<String, dynamic>> getTokenInfo() async {
    return {
      'hasAccessToken': await getAccessToken() != null,
      'hasRefreshToken': await getRefreshToken() != null,
      'expiresAt': await getExpiresAt(),
      'isValid': await isAccessTokenValid(),
    };
  }
}

final tokenStorageProvider = Provider((ref) => TokenStorage());
```

---

## 2. 토큰 갱신 서비스

### lib/services/token_refresh_service.dart

```dart
import 'package:agora_app/api/auth_api.dart';
import 'package:agora_app/utils/token_storage.dart';
import 'package:agora_app/core/utils/logger.dart';

class TokenRefreshService {
  final AuthApi authApi;
  final TokenStorage tokenStorage;

  TokenRefreshService({
    required this.authApi,
    required this.tokenStorage,
  });

  /// Refresh Token으로 새 Access Token 획득
  Future<bool> refreshAccessToken() async {
    try {
      AppLogger.info('Attempting to refresh access token');

      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        AppLogger.warning('No refresh token available');
        return false;
      }

      final response = await authApi.refreshToken(refreshToken);

      // 새 토큰 저장
      await tokenStorage.saveTokens(
        accessToken: response['accessToken'],
        refreshToken: response['refreshToken'],
        expiresIn: response['expiresIn'] ?? 3600,
      );

      AppLogger.info('Access token refreshed successfully');
      return true;
    } catch (e) {
      AppLogger.error('Failed to refresh access token', error: e);
      return false;
    }
  }

  /// 토큰이 유효하면 유지, 만료 예정이면 갱신
  Future<String?> getValidAccessToken() async {
    final isValid = await tokenStorage.isAccessTokenValid();

    if (!isValid) {
      AppLogger.debug('Access token is expired, attempting refresh');
      final refreshed = await refreshAccessToken();

      if (!refreshed) {
        AppLogger.error('Failed to refresh token');
        return null;
      }
    }

    return await tokenStorage.getAccessToken();
  }

  /// 주기적 토큰 갱신 (5분마다)
  void startPeriodicRefresh() {
    Timer.periodic(Duration(minutes: 5), (timer) async {
      final shouldRefresh = await tokenStorage.shouldRefreshToken();

      if (shouldRefresh) {
        AppLogger.debug('Periodic token refresh triggered');
        await refreshAccessToken();
      }
    });
  }
}

final tokenRefreshServiceProvider = Provider((ref) => TokenRefreshService(
  authApi: ref.watch(authApiProvider),
  tokenStorage: ref.watch(tokenStorageProvider),
));
```

---

## 3. HTTP 인터셉터 (자동 갱신)

### lib/api/auth_interceptor.dart

```dart
import 'package:dio/dio.dart';
import 'package:agora_app/services/token_refresh_service.dart';
import 'package:agora_app/utils/token_storage.dart';
import 'package:agora_app/core/utils/logger.dart';

class AuthInterceptor extends Interceptor {
  final TokenRefreshService tokenRefreshService;

  AuthInterceptor({required this.tokenRefreshService});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 요청 전에 토큰 유효성 확인
    final token = await tokenRefreshService.getValidAccessToken();

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
    // 401 에러 처리
    if (err.response?.statusCode == 401) {
      AppLogger.warning('Received 401 Unauthorized, attempting token refresh');

      // 토큰 갱신 시도
      final refreshed = await tokenRefreshService.refreshAccessToken();

      if (refreshed) {
        // 토큰 갱신 성공 → 원래 요청 재시도
        final token = await tokenRefreshService.getValidAccessToken();
        if (token != null) {
          err.requestOptions.headers['Authorization'] = 'Bearer $token';

          // 요청 재시도
          try {
            final response = await Dio().request(
              err.requestOptions.path,
              options: Options(
                method: err.requestOptions.method,
                headers: err.requestOptions.headers,
              ),
              data: err.requestOptions.data,
              queryParameters: err.requestOptions.queryParameters,
            );

            return handler.resolve(response);
          } catch (e) {
            return handler.reject(err);
          }
        }
      } else {
        // 토큰 갱신 실패 → 로그아웃 처리
        AppLogger.error('Token refresh failed, user should logout');
        // 별도 이벤트 발생 (로그아웃)
      }
    }

    return handler.next(err);
  }
}
```

---

## 4. API 클라이언트 설정

### lib/api/api_client.dart

```dart
class ApiClient {
  late Dio _dio;

  ApiClient({
    required TokenRefreshService tokenRefreshService,
  }) {
    _initializeDio(tokenRefreshService);
  }

  void _initializeDio(TokenRefreshService tokenRefreshService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.hyfata.com',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // 인터셉터 추가
    _dio.interceptors.add(
      AuthInterceptor(tokenRefreshService: tokenRefreshService),
    );

    // 로깅 (개발용)
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          responseBody: true,
          compact: true,
        ),
      );
    }
  }

  Dio get dio => _dio;
}

final apiClientProvider = Provider((ref) => ApiClient(
  tokenRefreshService: ref.watch(tokenRefreshServiceProvider),
));
```

---

## 5. 토큰 상태 관리

### lib/providers/token_provider.dart

```dart
enum TokenStatus {
  valid,
  expiring,
  expired,
  unknown,
}

final tokenStatusProvider = FutureProvider<TokenStatus>((ref) async {
  final tokenStorage = ref.watch(tokenStorageProvider);

  final expiresAt = await tokenStorage.getExpiresAt();
  if (expiresAt == null) return TokenStatus.unknown;

  final now = DateTime.now();
  final difference = expiresAt.difference(now);

  if (difference.isNegative) {
    return TokenStatus.expired;
  } else if (difference.inMinutes < 5) {
    return TokenStatus.expiring;
  } else {
    return TokenStatus.valid;
  }
});

// 토큰이 유효한지 확인
final isTokenValidProvider = FutureProvider<bool>((ref) async {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return await tokenStorage.isAccessTokenValid();
});

// 토큰 정보 (디버깅용)
final tokenInfoProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return await tokenStorage.getTokenInfo();
});
```

---

## 6. 토큰 만료 이벤트 처리

### lib/services/token_listener.dart

```dart
class TokenExpirationListener {
  final TokenStorage tokenStorage;
  Timer? _timer;

  Function()? _onTokenExpiring;
  Function()? _onTokenExpired;

  TokenExpirationListener({required this.tokenStorage});

  /// 토큰 만료 모니터링 시작
  void startMonitoring({
    Function()? onTokenExpiring, // 만료 5분 전
    Function()? onTokenExpired,  // 만료됨
  }) {
    _onTokenExpiring = onTokenExpiring;
    _onTokenExpired = onTokenExpired;

    _timer = Timer.periodic(Duration(minutes: 1), (_) async {
      await _checkTokenStatus();
    });
  }

  Future<void> _checkTokenStatus() async {
    final expiresAt = await tokenStorage.getExpiresAt();
    if (expiresAt == null) return;

    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.isNegative) {
      _onTokenExpired?.call();
    } else if (difference.inMinutes < 5) {
      _onTokenExpiring?.call();
    }
  }

  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stopMonitoring();
  }
}

final tokenExpirationListenerProvider = Provider((ref) {
  return TokenExpirationListener(
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});
```

---

## 7. 앱 시작 시 토큰 갱신

### lib/main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 앱 시작 시 토큰 유효성 확인
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final tokenStorage = ref.read(tokenStorageProvider);
      final isValid = await tokenStorage.isAccessTokenValid();

      if (!isValid) {
        // 토큰이 만료되었으면 갱신 시도
        final tokenRefreshService = ref.read(tokenRefreshServiceProvider);
        await tokenRefreshService.refreshAccessToken();
      }

      // 주기적 갱신 시작
      final tokenRefreshService = ref.read(tokenRefreshServiceProvider);
      tokenRefreshService.startPeriodicRefresh();
    });

    return MaterialApp(
      title: 'Agora',
      home: HomeScreen(),
    );
  }
}
```

---

## 주의사항

1. **토큰 저장**: Secure Storage 반드시 사용
2. **만료 버퍼**: 5분 전에 갱신하여 경합 상태 방지
3. **주기적 갱신**: 5분마다 유효성 확인
4. **에러 처리**: 갱신 실패 시 로그아웃
5. **로그 관리**: 프로덕션에서는 민감한 정보 로깅 제거

---

## 다음 단계

- FLUTTER_SECURE_STORAGE.md - 안전한 저장소 사용법
- FLUTTER_AUTO_LOGIN.md - 자동 로그인 구현
