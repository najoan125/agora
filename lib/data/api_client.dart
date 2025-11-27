import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:8080';
  
  // 안드로이드 에뮬레이터: http://10.0.2.2:8080
  // 웹 브라우저: http://localhost:8080
  // 실제 기기: http://192.168.x.x:8080 (PC IP 주소)
  
  late Dio dio;

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // 요청/응답 인터셉터 추가
    dio.interceptors.add(
      InterceptorsWrapper(
        // 모든 요청에 자동으로 토큰 추가
        onRequest: (options, handler) async {
          final token = await _getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print('🔑 Token added to request: ${options.path}');
          }
          return handler.next(options);
        },
        
        // 401/403 에러 시 자동 토큰 갱신
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 || 
              error.response?.statusCode == 403) {
            
            print('🔒 Token expired (${error.response?.statusCode}), refreshing...');
            final refreshed = await _refreshToken();
            
            if (refreshed) {
              print('✅ Token refreshed successfully!');
              
              // 갱신 성공 시 원래 요청 재시도
              final options = error.requestOptions;
              final token = await _getAccessToken();
              options.headers['Authorization'] = 'Bearer $token';
              
              try {
                print('🔄 Retrying original request...');
                final response = await dio.fetch(options);
                return handler.resolve(response);
              } catch (e) {
                print('❌ Retry failed: $e');
                return handler.next(error);
              }
            } else {
              print('❌ Token refresh failed, please login again');
              // 갱신 실패 시 로그아웃 처리
              await _clearTokens();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Access Token 가져오기
  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// Refresh Token 가져오기
  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  /// 토큰 갱신
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null) {
        print('⚠️ No refresh token found');
        return false;
      }

      // 새로운 Dio 인스턴스로 갱신 요청 (인터셉터 무한루프 방지)
      final response = await Dio().post(
        '$baseUrl/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', response.data['accessToken']);
        await prefs.setString('refresh_token', response.data['refreshToken']);
        print('💾 New tokens saved');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Token refresh error: $e');
      return false;
    }
  }

  /// 토큰 삭제 (내부용)
  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    print('🗑️ Tokens cleared');
  }

  /// 토큰 저장 (public - AuthService에서 사용)
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    print('💾 Tokens saved successfully');
  }

  /// 토큰 삭제 (public - 로그아웃 시 사용)
  Future<void> clearTokens() async {
    await _clearTokens();
  }

  /// GET 요청
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  /// POST 요청
  Future<Response> post(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }

  /// PUT 요청
  Future<Response> put(String path, {dynamic data}) async {
    return await dio.put(path, data: data);
  }

  /// DELETE 요청
  Future<Response> delete(String path) async {
    return await dio.delete(path);
  }
}
