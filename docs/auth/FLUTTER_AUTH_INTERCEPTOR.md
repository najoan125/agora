# Flutter Dio 인터셉터 - 토큰 자동 관리

## 개요

Dio HTTP 클라이언트에서 자동으로 토큰을 관리하는 인터셉터 구현

---

## 인터셉터 흐름

```
요청 생성
  ↓
[RequestInterceptor]
  ├─ 토큰 유효성 확인
  ├─ 필요시 토큰 갱신
  └─ Authorization Header 추가
  ↓
HTTP 요청 전송
  ↓
응답 수신
  ↓
[ResponseInterceptor]
  └─ 상태 코드 확인
  ↓
[ErrorInterceptor]
  ├─ 401 에러 → 토큰 갱신 + 재시도
  └─ 기타 에러 → 처리
```

---

## 1. Request 인터셉터 (토큰 추가)

### lib/api/interceptors/request_interceptor.dart

```dart
import 'package:dio/dio.dart';
import 'package:agora_app/core/utils/token_storage.dart';
import 'package:agora_app/core/utils/logger.dart';

class RequestInterceptor extends Interceptor {
  final TokenStorage tokenStorage;

  RequestInterceptor({required this.tokenStorage});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // 토큰 유효성 확인
      final isValid = await tokenStorage.isAccessTokenValid();

      if (!isValid) {
        AppLogger.warning('Access token is expiring, will need refresh');
      }

      // Access Token 추가
      final token = await tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        AppLogger.debug('Authorization header added');
      } else {
        AppLogger.warning('No access token found');
      }

      // 요청 정보 로깅
      AppLogger.debug(
        'HTTP ${options.method} ${options.path}',
      );

      return handler.next(options);
    } catch (e) {
      AppLogger.error('RequestInterceptor error', error: e);
      return handler.next(options);
    }
  }
}
```

---

## 2. Error 인터셉터 (토큰 갱신)

### lib/api/interceptors/error_interceptor.dart

```dart
import 'package:dio/dio.dart';
import 'package:agora_app/api/auth_api.dart';
import 'package:agora_app/core/utils/token_storage.dart';
import 'package:agora_app/core/exception/app_exception.dart';
import 'package:agora_app/core/utils/logger.dart';

class TokenErrorInterceptor extends Interceptor {
  final AuthApi authApi;
  final TokenStorage tokenStorage;

  TokenErrorInterceptor({
    required this.authApi,
    required this.tokenStorage,
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 401 Unauthorized - 토큰 갱신 시도
    if (err.response?.statusCode == 401) {
      AppLogger.warning('Received 401 Unauthorized');

      try {
        // 토큰 갱신
        if (await _refreshToken()) {
          AppLogger.info('Token refreshed, retrying request');

          // 원래 요청 재시도
          final retryResponse = await _retryRequest(err);
          return handler.resolve(retryResponse);
        } else {
          AppLogger.error('Token refresh failed');
          // 갱신 실패 → 로그아웃 처리 필요
          return handler.reject(err);
        }
      } catch (e) {
        AppLogger.error('Error during token refresh', error: e);
        return handler.reject(err);
      }
    }

    // 기타 에러는 그대로 처리
    return handler.next(err);
  }

  /// 토큰 갱신
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
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
      AppLogger.error('Failed to refresh token', error: e);
      return false;
    }
  }

  /// 요청 재시도
  Future<Response> _retryRequest(DioException err) async {
    final token = await tokenStorage.getAccessToken();

    if (token != null) {
      err.requestOptions.headers['Authorization'] = 'Bearer $token';
    }

    return await Dio().request(
      err.requestOptions.path,
      options: Options(
        method: err.requestOptions.method,
        headers: err.requestOptions.headers,
      ),
      data: err.requestOptions.data,
      queryParameters: err.requestOptions.queryParameters,
    );
  }
}
```

---

## 3. Response 인터셉터 (응답 처리)

### lib/api/interceptors/response_interceptor.dart

```dart
import 'package:dio/dio.dart';
import 'package:agora_app/core/utils/logger.dart';

class ResponseInterceptor extends Interceptor {
  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    // 응답 코드에 따른 처리
    if (response.statusCode == 200 || response.statusCode == 201) {
      AppLogger.debug('HTTP ${response.statusCode} ${response.requestOptions.path}');
      return handler.next(response);
    }

    if (response.statusCode == 204) {
      // No Content - 성공
      AppLogger.debug('HTTP 204 No Content');
      return handler.next(response);
    }

    // 예상치 못한 상태 코드
    AppLogger.warning('Unexpected HTTP ${response.statusCode}');
    return handler.next(response);
  }
}
```

---

## 4. 로깅 인터셉터

### lib/api/interceptors/logging_interceptor.dart

```dart
import 'package:dio/dio.dart';
import 'package:agora_app/core/utils/logger.dart';

class LoggingInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    AppLogger.debug(
      '>>> [${options.method}] ${options.path}',
    );

    if (options.data != null) {
      AppLogger.debug('Request data: ${options.data}');
    }

    if (options.headers.containsKey('Authorization')) {
      AppLogger.debug('Authorization: [TOKEN]'); // 민감 정보 숨김
    }

    return handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    AppLogger.debug(
      '<<< [${response.statusCode}] ${response.requestOptions.path}',
    );

    return handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    AppLogger.error(
      'ERROR [${err.response?.statusCode}] ${err.requestOptions.path}',
      error: err,
    );

    return handler.next(err);
  }
}
```

---

## 5. API 클라이언트 통합

### lib/api/api_client.dart

```dart
import 'package:dio/dio.dart';
import 'package:agora_app/api/auth_api.dart';
import 'package:agora_app/core/utils/token_storage.dart';
import 'package:agora_app/api/interceptors/request_interceptor.dart';
import 'package:agora_app/api/interceptors/token_error_interceptor.dart';
import 'package:agora_app/api/interceptors/response_interceptor.dart';
import 'package:agora_app/api/interceptors/logging_interceptor.dart';

class ApiClient {
  late Dio _dio;

  ApiClient({
    String? baseUrl = 'https://api.hyfata.com',
    required AuthApi authApi,
    required TokenStorage tokenStorage,
  }) {
    _initializeDio(baseUrl!, authApi, tokenStorage);
  }

  void _initializeDio(
    String baseUrl,
    AuthApi authApi,
    TokenStorage tokenStorage,
  ) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        validateStatus: (status) {
          // 모든 상태를 처리 가능하게 설정
          return status != null;
        },
      ),
    );

    // 인터셉터 순서가 중요함
    // 1. 요청 전 토큰 추가
    _dio.interceptors.add(RequestInterceptor(tokenStorage: tokenStorage));

    // 2. 응답 처리
    _dio.interceptors.add(ResponseInterceptor());

    // 3. 에러 처리 (토큰 갱신)
    _dio.interceptors.add(
      TokenErrorInterceptor(
        authApi: authApi,
        tokenStorage: tokenStorage,
      ),
    );

    // 4. 로깅 (마지막에 추가)
    if (kDebugMode) {
      _dio.interceptors.add(LoggingInterceptor());
    }
  }

  Dio get dio => _dio;

  /// HTTP GET
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await _dio.get(
      path,
      queryParameters: queryParameters,
    );

    return _handleResponse(response, fromJson);
  }

  /// HTTP POST
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
    );

    return _handleResponse(response, fromJson);
  }

  /// HTTP PUT
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
    );

    return _handleResponse(response, fromJson);
  }

  /// HTTP DELETE
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    final response = await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
    );

    return _handleResponse(response, fromJson);
  }

  T _handleResponse<T>(Response response, T Function(dynamic)? fromJson) {
    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data as T;
    } else {
      throw AppException(
        code: response.statusCode?.toString() ?? 'UNKNOWN',
        message: response.data['message'] ?? 'Error occurred',
        statusCode: response.statusCode,
      );
    }
  }
}

final apiClientProvider = Provider((ref) => ApiClient(
  authApi: ref.watch(authApiProvider),
  tokenStorage: TokenStorage(),
));
```

---

## 6. 사용 예제

### API 호출

```dart
class UserApi {
  final Dio dio;

  UserApi(this.dio);

  /// 프로필 조회
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await dio.get('/api/agora/profile');
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // 토큰이 갱신되거나 로그아웃 처리됨
      }
      rethrow;
    }
  }

  /// 프로필 수정
  Future<Map<String, dynamic>> updateProfile(String displayName) async {
    final response = await dio.put(
      '/api/agora/profile',
      data: {'displayName': displayName},
    );
    return response.data;
  }
}
```

---

## 7. 테스트

```dart
test('Request adds authorization header', () async {
  final mockTokenStorage = MockTokenStorage();
  when(mockTokenStorage.getAccessToken())
      .thenAnswer((_) async => 'test_token');

  final interceptor = RequestInterceptor(tokenStorage: mockTokenStorage);
  final options = RequestOptions(path: '/test');

  await interceptor.onRequest(options, MockHandler());

  expect(options.headers['Authorization'], 'Bearer test_token');
});

test('Error interceptor refreshes token on 401', () async {
  final mockAuthApi = MockAuthApi();
  final mockTokenStorage = MockTokenStorage();

  when(mockAuthApi.refreshToken(any)).thenAnswer((_) async => {
    'accessToken': 'new_token',
    'refreshToken': 'new_refresh',
    'expiresIn': 3600,
  });

  final interceptor = TokenErrorInterceptor(
    authApi: mockAuthApi,
    tokenStorage: mockTokenStorage,
  );

  // 테스트 구현...
});
```

---

## 주의사항

1. **인터셉터 순서**: Request → Response → Error → Logging
2. **토큰 갱신**: 동시 요청 시 중복 갱신 방지
3. **민감 정보**: 로그에서 토큰 숨기기
4. **재시도 로직**: 무한 루프 방지
5. **캐싱**: 요청/응답 캐싱 (선택적)

---

## 다음 단계

- FLUTTER_AUTH_STATE.md - 인증 상태 관리
- FLUTTER_LOGIN_UI_FLOW.md - 로그인 UI 흐름
