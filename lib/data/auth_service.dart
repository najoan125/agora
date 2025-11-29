import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// 회원가입
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/register',
        data: {
          'email': email,
          'password': password,
          'username': username,
        },
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': response.data['message'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['error'] ?? '회원가입 실패',
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return {
          'success': false,
          'message': '이미 존재하는 이메일입니다.',
        };
      }
      return {
        'success': false,
        'message': '서버 연결 실패: ${e.message}',
      };
    }
  }

  /// 로그인
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        // 토큰 저장
        await _apiClient.saveTokens(
          accessToken: response.data['accessToken'],
          refreshToken: response.data['refreshToken'],
        );

        return {
          'success': true,
          'message': response.data['message'] ?? '로그인 성공',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? '로그인 실패',
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return {
          'success': false,
          'message': '이메일 또는 비밀번호를 확인해주세요.',
        };
      }
      if (e.response?.statusCode == 404) {
        return {
          'success': false,
          'message': '존재하지 않는 계정입니다.',
        };
      }
      return {
        'success': false,
        'message': '서버 연결 실패: ${e.message}',
      };
    }
  }

  /// 토큰 저장 (내부용 - 회원가입 후 자동 로그인 등)
  Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _apiClient.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// Access Token 가져오기
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// Refresh Token 가져오기
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  /// 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }

  /// 로그아웃
  Future<void> logout() async {
    await _apiClient.clearTokens();
  }

  /// 보호된 API 호출 예시 (GET /first)
  /// 이제 토큰이 자동으로 추가되고, 만료 시 자동 갱신됨!
  Future<Map<String, dynamic>> getProtectedData() async {
    try {
      final response = await _apiClient.get('/first');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'API 호출 실패: ${response.statusCode}',
        };
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return {
          'success': false,
          'message': '인증 실패. 다시 로그인하세요',
          'requireAuth': true,
        };
      }
      return {
        'success': false,
        'message': '서버 연결 실패: ${e.message}',
      };
    }
  }

  /// 수동 토큰 갱신 (필요 시)
  Future<Map<String, dynamic>> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      
      if (refreshToken == null) {
        return {
          'success': false,
          'message': '다시 로그인하세요',
        };
      }

      final response = await _apiClient.post(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        await _saveTokens(
          accessToken: response.data['accessToken'],
          refreshToken: response.data['refreshToken'],
        );

        return {
          'success': true,
          'message': '토큰 갱신 성공',
        };
      } else {
        return {
          'success': false,
          'message': '토큰 갱신 실패',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': '서버 연결 실패: ${e.message}',
      };
    }
  }
}
