import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'api_client.dart';
import 'models/agora_profile_response.dart';
import 'models/create_agora_profile_request.dart';
import 'models/update_agora_profile_request.dart';

class ProfileService {
  final ApiClient _apiClient;

  ProfileService(this._apiClient);

  /// GET - 내 Agora 프로필 조회
  Future<AgoraProfileResponse> getMyProfile() async {
    try {
      final response = await _apiClient.get('/api/agora/profile');
      return AgoraProfileResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST - Agora 프로필 생성 (최초 설정)
  Future<AgoraProfileResponse> createProfile(CreateAgoraProfileRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/agora/profile',
        data: request.toJson(),
      );
      return AgoraProfileResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT - Agora 프로필 수정
  Future<AgoraProfileResponse> updateProfile(UpdateAgoraProfileRequest request) async {
    try {
      print('🔵 [ProfileService] 프로필 수정 요청 시작');
      print('📤 요청 데이터: ${request.toJson()}');
      
      final response = await _apiClient.put(
        '/api/agora/profile',
        data: request.toJson(),
      );
      
      print('✅ [ProfileService] 프로필 수정 성공');
      print('📥 응답 데이터: ${response.data}');
      
      return AgoraProfileResponse.fromJson(response.data);
    } catch (e) {
      print('❌ [ProfileService] 프로필 수정 실패: $e');
      throw _handleError(e);
    }
  }

  /// PUT - 프로필 이미지 변경
  Future<void> updateProfileImage(File imageFile) async {
    try {
      print('🔵 [ProfileService] 프로필 이미지 업데이트 시작');
      print('📤 이미지 파일: ${imageFile.path}');
      
      String fileName = imageFile.path.split('/').last;
      
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      await _apiClient.dio.put(
        '/api/agora/profile/image',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      
      print('✅ [ProfileService] 프로필 이미지 업데이트 성공');
    } catch (e) {
      print('❌ [ProfileService] 프로필 이미지 업데이트 실패: $e');
      throw _handleError(e);
    }
  }

  /// GET - 다른 사용자 프로필 조회
  Future<AgoraProfileResponse> getUserProfile(String agoraId) async {
    try {
      final response = await _apiClient.get('/api/agora/profile/$agoraId');
      return AgoraProfileResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET - 사용자 검색 (agoraId, displayName)
  Future<List<AgoraProfileResponse>> searchUsers({
    String? agoraId,
    String? displayName,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (agoraId != null) queryParams['agoraId'] = agoraId;
      if (displayName != null) queryParams['displayName'] = displayName;

      final response = await _apiClient.get(
        '/api/agora/profile/search',
        queryParameters: queryParams,
      );

      return (response.data as List)
          .map((json) => AgoraProfileResponse.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET - agoraId 중복 확인
  Future<bool> checkAgoraIdAvailable(String agoraId) async {
    try {
      print('🔵 [ProfileService] agoraId 중복 확인 시작: $agoraId');
      
      final response = await _apiClient.get(
        '/api/agora/profile/check-id',
        queryParameters: {'agoraId': agoraId},
      );
      
      print('✅ [ProfileService] 응답 상태: ${response.statusCode}');
      print('📥 [ProfileService] 응답 데이터: ${response.data}');
      print('📥 [ProfileService] 응답 타입: ${response.data.runtimeType}');
      
      // 서버 응답 구조에 따라 조정 필요
      if (response.data is Map) {
        final available = response.data['available'] ?? false;
        print('✅ [ProfileService] available 값: $available');
        return available;
      }
      
      print('✅ [ProfileService] Map이 아님, statusCode로 판단: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ [ProfileService] agoraId 중복 확인 에러: $e');
      
      if (e is DioException) {
        print('❌ [ProfileService] DioException 상태코드: ${e.response?.statusCode}');
        print('❌ [ProfileService] DioException 응답: ${e.response?.data}');
        
        if (e.response?.statusCode == 409) {
          print('⚠️ [ProfileService] 409 에러 - 이미 존재하는 ID');
          return false; // 이미 존재하는 ID
        }
      }
      
      throw _handleError(e);
    }
  }

  /// 에러 핸들링
  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final statusCode = error.response?.statusCode;
        
        // message 필드를 안전하게 추출
        String? message;
        try {
          final responseData = error.response?.data;
          if (responseData is Map<String, dynamic>) {
            final messageValue = responseData['message'];
            message = messageValue?.toString();
          }
        } catch (e) {
          print('⚠️ Error parsing message: $e');
        }
        
        switch (statusCode) {
          case 400:
            return message ?? '잘못된 요청입니다.';
          case 401:
            return '인증이 필요합니다.';
          case 403:
            return '권한이 없습니다.';
          case 404:
            return '프로필을 찾을 수 없습니다.';
          case 409:
            return message ?? '이미 존재하는 데이터입니다.';
          case 500:
            return '서버 오류가 발생했습니다.';
          default:
            return message ?? '알 수 없는 오류가 발생했습니다.';
        }
      }
      return '네트워크 연결을 확인해주세요.';
    }
    return '알 수 없는 오류가 발생했습니다.';
  }
}
