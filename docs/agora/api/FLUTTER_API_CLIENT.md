# Flutter API 클라이언트 설계

## 개요

Dio 기반 HTTP 클라이언트 - 에러 처리, 로깅, 인터셉터 포함

---

## 1. API 클라이언트 고급 설정

### lib/data/datasources/remote/api_client.dart

```dart
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:agora_app/core/config/api_config.dart';
import 'package:agora_app/core/exception/app_exception.dart';

class ApiClient {
  late Dio _dio;

  ApiClient({String? baseUrl}) {
    _initializeDio(baseUrl ?? ApiConfig.baseUrl);
  }

  void _initializeDio(String baseUrl) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          // 4xx, 5xx도 정상으로 취급 (커스텀 처리)
          return status != null && status < 500;
        },
      ),
    );

    // 인터셉터 추가
    _addInterceptors();
  }

  void _addInterceptors() {
    // 로깅 (개발 환경)
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          compact: true,
        ),
      );
    }

    // 토큰 및 에러 처리
    _dio.interceptors.add(TokenInterceptor());
    _dio.interceptors.add(ErrorInterceptor());
  }

  Dio get dio => _dio;

  /// GET 요청
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST 요청
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT 요청
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE 요청
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 파일 업로드
  Future<T> uploadFile<T>(
    String path, {
    required String filePath,
    String? fieldName = 'file',
    Map<String, String>? formFields,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...?formFields,
        fieldName!: await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(
        path,
        data: formData,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 파일 다운로드
  Future<void> downloadFile({
    required String path,
    required String savePath,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      await _dio.download(
        path,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 응답 처리
  T _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data as T;
    } else {
      throw AppException(
        code: response.statusCode?.toString() ?? 'UNKNOWN',
        message: response.data['message'] ?? 'Unknown error',
      );
    }
  }

  /// 에러 처리
  AppException _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      return AppException(
        code: 'CONNECTION_TIMEOUT',
        message: '연결 시간 초과',
      );
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return AppException(
        code: 'RECEIVE_TIMEOUT',
        message: '응답 시간 초과',
      );
    } else if (error.response != null) {
      final statusCode = error.response!.statusCode ?? 0;
      final message = error.response!.data['message'] ?? 'Server error';

      return AppException(
        code: statusCode.toString(),
        message: message,
        statusCode: statusCode,
      );
    } else {
      return AppException(
        code: 'NETWORK_ERROR',
        message: '네트워크 오류: ${error.message}',
      );
    }
  }
}

final apiClientProvider = Provider((ref) => ApiClient());
```

---

## 2. 예외 처리

### lib/core/exception/app_exception.dart

```dart
class AppException implements Exception {
  final String code;
  final String message;
  final int? statusCode;
  final dynamic originalError;

  AppException({
    required this.code,
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'AppException(code: $code, message: $message)';

  /// 사용자 친화적 에러 메시지
  String get userMessage {
    switch (code) {
      case '400':
        return '잘못된 요청입니다';
      case '401':
        return '인증이 필요합니다. 다시 로그인해주세요';
      case '403':
        return '접근 권한이 없습니다';
      case '404':
        return '요청한 정보를 찾을 수 없습니다';
      case '409':
        return '충돌이 발생했습니다. 다시 시도해주세요';
      case '500':
        return '서버 오류가 발생했습니다';
      case 'CONNECTION_TIMEOUT':
        return '서버와의 연결에 시간이 초과되었습니다';
      case 'RECEIVE_TIMEOUT':
        return '서버의 응답을 기다리던 중 시간이 초과되었습니다';
      case 'NETWORK_ERROR':
        return '네트워크 연결을 확인해주세요';
      default:
        return message;
    }
  }

  bool get isNetworkError => code == 'NETWORK_ERROR' || statusCode == null;
  bool get isUnauthorized => statusCode == 401;
  bool get isServerError => statusCode != null && statusCode! >= 500;
}
```

---

## 3. 토큰 인터셉터

### lib/data/datasources/remote/token_interceptor.dart

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_app/core/utils/secure_storage.dart';
import 'package:agora_app/presentation/providers/auth_provider.dart';

class TokenInterceptor extends Interceptor {
  static final _storage = SecureStorageManager();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 모든 요청에 Access Token 추가
    final token = await _storage.getAccessToken();
    if (token != null && !options.headers.containsKey('Authorization')) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }
}
```

---

## 4. 에러 인터셉터

### lib/data/datasources/remote/error_interceptor.dart

```dart
import 'package:dio/dio.dart';
import 'package:agora_app/core/exception/app_exception.dart';
import 'package:agora_app/core/utils/logger.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 에러 로깅
    AppLogger.error(
      'API Error',
      error: err,
      stackTrace: StackTrace.current,
    );

    // 응답 상태 코드별 처리
    if (err.response != null) {
      switch (err.response!.statusCode) {
        case 401:
          // 인증 오류 → 로그아웃 (별도 처리)
          break;
        case 400:
        case 404:
        case 409:
          // 클라이언트 오류
          break;
        case 500:
        case 502:
        case 503:
          // 서버 오류
          break;
      }
    }

    return handler.next(err);
  }
}
```

---

## 5. API 서비스 예제 (Profile API)

### lib/data/datasources/remote/profile_api.dart

```dart
import 'package:dio/dio.dart';
import 'package:agora_app/core/constants/api_endpoints.dart';
import 'package:agora_app/data/datasources/remote/api_client.dart';
import 'package:agora_app/data/models/profile_model.dart';

class ProfileApi {
  final ApiClient apiClient;

  ProfileApi(this.apiClient);

  /// 내 프로필 조회
  Future<ProfileModel> getMyProfile() async {
    return await apiClient.get(
      ApiEndpoints.profile,
      fromJson: (json) => ProfileModel.fromJson(json),
    );
  }

  /// 프로필 생성
  Future<ProfileModel> createProfile({
    required String agoraId,
    required String displayName,
    String? bio,
    String? profileImage,
  }) async {
    return await apiClient.post(
      ApiEndpoints.profile,
      data: {
        'agoraId': agoraId,
        'displayName': displayName,
        'bio': bio,
        'profileImage': profileImage,
      },
      fromJson: (json) => ProfileModel.fromJson(json),
    );
  }

  /// 프로필 수정
  Future<ProfileModel> updateProfile({
    String? displayName,
    String? bio,
  }) async {
    return await apiClient.put(
      ApiEndpoints.profile,
      data: {
        if (displayName != null) 'displayName': displayName,
        if (bio != null) 'bio': bio,
      },
      fromJson: (json) => ProfileModel.fromJson(json),
    );
  }

  /// 프로필 이미지 변경
  Future<ProfileModel> updateProfileImage(String imagePath) async {
    return await apiClient.uploadFile(
      '${ApiEndpoints.profile}/image',
      filePath: imagePath,
      fieldName: 'file',
      fromJson: (json) => ProfileModel.fromJson(json),
    );
  }

  /// 사용자 검색
  Future<List<ProfileModel>> searchProfiles(String keyword) async {
    final response = await apiClient.get(
      ApiEndpoints.profileSearch,
      queryParameters: {'keyword': keyword},
    );

    return (response as List)
        .map((json) => ProfileModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// agoraId 중복 확인
  Future<bool> checkAgoraIdAvailable(String agoraId) async {
    try {
      final response = await apiClient.get(
        '${ApiEndpoints.profile}/check-id',
        queryParameters: {'agoraId': agoraId},
      );
      return response['available'] == true;
    } catch (e) {
      return false;
    }
  }
}

final profileApiProvider = Provider((ref) => ProfileApi(
  ref.watch(apiClientProvider),
));
```

---

## 6. Repository 패턴 (Profile)

### lib/data/repositories/profile_repository.dart

```dart
import 'package:agora_app/data/datasources/remote/profile_api.dart';
import 'package:agora_app/data/models/profile_model.dart';
import 'package:agora_app/core/exception/app_exception.dart';

class ProfileRepository {
  final ProfileApi profileApi;

  ProfileRepository({required this.profileApi});

  /// 내 프로필 조회
  Future<ProfileModel> getMyProfile() async {
    try {
      return await profileApi.getMyProfile();
    } on AppException {
      rethrow;
    }
  }

  /// 프로필 생성
  Future<ProfileModel> createProfile({
    required String agoraId,
    required String displayName,
    String? bio,
    String? profileImage,
  }) async {
    try {
      return await profileApi.createProfile(
        agoraId: agoraId,
        displayName: displayName,
        bio: bio,
        profileImage: profileImage,
      );
    } on AppException catch (e) {
      if (e.statusCode == 409) {
        throw AppException(
          code: 'AGORA_ID_DUPLICATE',
          message: '이미 사용 중인 ID입니다',
          statusCode: 409,
        );
      }
      rethrow;
    }
  }

  /// 사용자 검색
  Future<List<ProfileModel>> searchUsers(String keyword) async {
    try {
      return await profileApi.searchProfiles(keyword);
    } on AppException {
      rethrow;
    }
  }

  /// agoraId 중복 확인
  Future<bool> isAgoraIdAvailable(String agoraId) async {
    try {
      return await profileApi.checkAgoraIdAvailable(agoraId);
    } catch (e) {
      return false;
    }
  }
}

final profileRepositoryProvider = Provider((ref) => ProfileRepository(
  profileApi: ref.watch(profileApiProvider),
));
```

---

## 7. Provider (State Management)

### lib/presentation/providers/profile_provider.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_app/data/models/profile_model.dart';
import 'package:agora_app/data/repositories/profile_repository.dart';

/// 내 프로필 조회
final myProfileProvider = FutureProvider<ProfileModel>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getMyProfile();
});

/// 프로필 수정 (뮤테이션)
final updateProfileProvider = FutureProvider.family<ProfileModel, Map<String, String>>((
  ref,
  params,
) async {
  // 사용되지 않음 - NotifierProvider 사용 권장
  throw UnimplementedError();
});

/// 사용자 검색
final searchProfilesProvider = FutureProvider.family<List<ProfileModel>, String>((
  ref,
  keyword,
) async {
  if (keyword.isEmpty) return [];
  final repository = ref.watch(profileRepositoryProvider);
  return repository.searchUsers(keyword);
});

/// agoraId 중복 확인
final checkAgoraIdProvider = FutureProvider.family<bool, String>((
  ref,
  agoraId,
) async {
  if (agoraId.isEmpty) return true;
  final repository = ref.watch(profileRepositoryProvider);
  return repository.isAgoraIdAvailable(agoraId);
});

/// 프로필 캐시 갱신
final invalidateMyProfileProvider = Provider((ref) {
  return () {
    ref.invalidate(myProfileProvider);
  };
});
```

---

## 8. 에러 처리 유틸

### lib/core/utils/logger.dart

```dart
import 'package:logger/logger.dart';

class AppLogger {
  static final _logger = Logger(
    filter: ProductionFilter(),
    printer: PrettyPrinter(
      colors: true,
      printEmojis: true,
      methodCount: 2,
    ),
  );

  static void debug(String message, {dynamic error}) {
    _logger.d(message);
  }

  static void info(String message) {
    _logger.i(message);
  }

  static void warning(String message) {
    _logger.w(message);
  }

  static void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
```

---

## 9. API 엔드포인트 상수

### lib/core/constants/api_endpoints.dart

```dart
class ApiEndpoints {
  static const String baseUrl = 'https://api.hyfata.com';

  // Auth
  static const String authorize = '/oauth/authorize';
  static const String tokenEndpoint = '/oauth/token';
  static const String logoutEndpoint = '/oauth/logout';

  // Profile
  static const String profile = '/api/agora/profile';
  static const String profileSearch = '/api/agora/profile/search';

  // Friends
  static const String friends = '/api/agora/friends';
  static const String friendRequests = '/api/agora/friends/requests';

  // Chat
  static const String chats = '/api/agora/chats';
  static const String chatMessages = '/api/agora/chats';

  // File
  static const String fileUpload = '/api/agora/files/upload';
  static const String fileUploadImage = '/api/agora/files/upload-image';
  static const String fileDownload = '/api/agora/files';
}
```

---

## 10. 사용 예제

### 프로필 조회

```dart
class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);

    return profileAsync.when(
      data: (profile) => _buildProfile(profile),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => ErrorWidget(
        error: error,
        onRetry: () => ref.refresh(myProfileProvider),
      ),
    );
  }

  Widget _buildProfile(ProfileModel profile) {
    return Scaffold(
      appBar: AppBar(title: Text(profile.displayName)),
      body: ListView(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(profile.profileImage ?? ''),
            radius: 50,
          ),
          Text(profile.agoraId),
          Text(profile.bio ?? ''),
        ],
      ),
    );
  }
}
```

---

## 주의사항

1. **타입 안정성**: `fromJson` 콜백으로 타입 변환
2. **에러 처리**: 모든 요청에서 `AppException` 사용
3. **토큰 갱신**: 401 에러 시 자동 갱신
4. **로깅**: 개발 환경에서만 상세 로깅

---

## 다음 단계

- FLUTTER_WEBSOCKET.md - WebSocket 실시간 연결
- FLUTTER_FCM.md - Firebase Cloud Messaging
