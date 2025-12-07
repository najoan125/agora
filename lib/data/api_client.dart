import 'package:dio/dio.dart';
import '../core/utils/secure_storage_manager.dart';
import '../core/constants/api_endpoints.dart';
import '../core/exception/app_exception.dart';

/// API 클라이언트
/// SecureStorage를 사용하여 토큰을 안전하게 관리
class ApiClient {
  late Dio dio;
  late Dio _refreshDio; // 토큰 갱신 전용 (인터셉터 없음)

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 토큰 갱신 전용 Dio (인터셉터 없음 - 무한루프 방지)
    _refreshDio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // 인터셉터 추가
    dio.interceptors.addAll([
      _TokenInterceptor(this),
      _ErrorInterceptor(),
      _LoggingInterceptor(),
    ]);
  }

  /// 토큰 저장
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    DateTime? expiresAt,
  }) async {
    await SecureStorageManager.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }

  /// 토큰 삭제
  Future<void> clearTokens() async {
    await SecureStorageManager.clearSession();
  }

  /// 토큰 갱신
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await SecureStorageManager.getRefreshToken();
      if (refreshToken == null) {
        print('Token refresh failed: No refresh token available');
        return false;
      }

      print('Attempting to refresh token...');

      // OAuth 표준: application/x-www-form-urlencoded 형식
      final response = await _refreshDio.post(
        ApiEndpoints.oauthToken,
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': OAuthConfig.clientId,
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final expiresIn = data['expires_in'] as int?;
        DateTime? expiresAt;
        if (expiresIn != null) {
          expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
        }

        await saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'] ?? refreshToken,
          expiresAt: expiresAt,
        );
        print('Token refresh successful');
        return true;
      }
      print('Token refresh failed: Status ${response.statusCode}');
      return false;
    } catch (e) {
      print('Token refresh failed: $e');
      return false;
    }
  }

  /// GET 요청
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.get(path, queryParameters: queryParameters, options: options);
  }

  /// POST 요청
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.post(path, data: data, queryParameters: queryParameters, options: options);
  }

  /// PUT 요청
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.put(path, data: data, queryParameters: queryParameters, options: options);
  }

  /// DELETE 요청
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.delete(path, data: data, queryParameters: queryParameters, options: options);
  }

  /// 파일 업로드
  Future<Response> uploadFile(
    String path, {
    required FormData formData,
    void Function(int, int)? onSendProgress,
    Options? options,
  }) async {
    return await dio.post(
      path,
      data: formData,
      onSendProgress: onSendProgress,
      options: options ?? Options(contentType: 'multipart/form-data'),
    );
  }

  /// 파일 다운로드
  Future<Response> downloadFile(
    String path,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
    Options? options,
  }) async {
    return await dio.download(
      path,
      savePath,
      onReceiveProgress: onReceiveProgress,
      options: options,
    );
  }
}

/// 토큰 인터셉터 - 요청에 토큰 추가 및 401 시 자동 갱신
class _TokenInterceptor extends Interceptor {
  final ApiClient _apiClient;

  _TokenInterceptor(this._apiClient);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 토큰이 필요없는 엔드포인트 제외
    final noAuthPaths = [
      ApiEndpoints.oauthAuthorize,
      ApiEndpoints.oauthToken,
      ApiEndpoints.authRegister,
      ApiEndpoints.authLogin,
    ];

    if (noAuthPaths.any((path) => options.path.contains(path))) {
      return handler.next(options);
    }

    // 토큰 만료 임박 시 사전 갱신
    if (await SecureStorageManager.shouldRefreshToken()) {
      await _apiClient.refreshToken();
    }

    // 토큰 추가
    final token = await SecureStorageManager.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;

    // 인증 관련 에러 또는 연결 실패(N/A) 시 토큰 갱신 시도
    final isAuthError = statusCode == 401 || statusCode == 403;
    final isConnectionError = statusCode == null &&
        (err.type == DioExceptionType.connectionError ||
         err.type == DioExceptionType.unknown ||
         err.type == DioExceptionType.connectionTimeout);

    if (isAuthError || isConnectionError) {
      // 이미 재시도한 요청인지 확인
      final retryCount = err.requestOptions.extra['retry_count'] ?? 0;
      if (retryCount >= 1) {
        print('Token refresh already attempted, clearing session');
        await SecureStorageManager.clearSession();
        return handler.next(err);
      }

      print('Auth error or connection error detected, attempting token refresh...');

      // 토큰 갱신 시도
      final refreshed = await _apiClient.refreshToken();
      if (refreshed) {
        // 원래 요청 재시도
        final options = err.requestOptions;
        final token = await SecureStorageManager.getAccessToken();
        options.headers['Authorization'] = 'Bearer $token';
        options.extra['retry_count'] = retryCount + 1;

        try {
          print('Retrying original request with new token...');
          final response = await _apiClient.dio.fetch(options);
          return handler.resolve(response);
        } catch (e) {
          print('Retry failed: $e');
          return handler.next(err);
        }
      } else {
        // 갱신 실패 시 세션 정리
        print('Token refresh failed, clearing session');
        await SecureStorageManager.clearSession();
      }
    }

    return handler.next(err);
  }
}

/// 에러 인터셉터 - 에러를 AppException으로 변환
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // DioException을 AppException으로 변환
    AppException appException;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        appException = AppException.network(
          message: 'Request timeout',
          error: err,
        );
        break;
      case DioExceptionType.connectionError:
        appException = AppException.network(
          message: 'Connection failed',
          error: err,
        );
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        final message = err.response?.data?['message'] ??
            err.response?.data?['error'] ??
            err.message;
        appException = AppException.fromStatusCode(
          statusCode,
          message: message,
          error: err,
        );
        break;
      case DioExceptionType.cancel:
        appException = AppException(
          code: 'REQUEST_CANCELLED',
          message: 'Request was cancelled',
          userMessage: '요청이 취소되었습니다.',
          originalError: err,
        );
        break;
      default:
        appException = AppException.unknown(
          message: err.message,
          error: err,
        );
    }

    // extra에 AppException 저장 (나중에 사용)
    err.requestOptions.extra['appException'] = appException;
    handler.next(err);
  }
}

/// 로깅 인터셉터 - 요청/응답 로깅 (민감 정보 마스킹)
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method;
    final path = options.path;
    print('>>> $method $path');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final statusCode = response.statusCode;
    final path = response.requestOptions.path;
    print('<<< $statusCode $path');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode ?? 'N/A';
    final path = err.requestOptions.path;
    print('!!! $statusCode $path');
    handler.next(err);
  }
}
