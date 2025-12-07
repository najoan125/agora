import 'package:dio/dio.dart';
import '../api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/exception/app_exception.dart';
import '../models/team/team.dart';

/// 팀 프로필 관리 서비스
class TeamProfileService {
  final ApiClient _apiClient;

  TeamProfileService([ApiClient? apiClient]) : _apiClient = apiClient ?? ApiClient();

  /// 팀 프로필 조회
  Future<Result<TeamProfile>> getTeamProfile(String teamId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.teamProfile(teamId));
      return Success(TeamProfile.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 팀 프로필 생성
  Future<Result<TeamProfile>> createTeamProfile(
    String teamId, {
    required String displayName,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.teamProfile(teamId),
        data: {'displayName': displayName},
      );
      return Success(TeamProfile.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 팀 프로필 수정
  Future<Result<TeamProfile>> updateTeamProfile(
    String teamId, {
    String? displayName,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.teamProfile(teamId),
        data: {
          if (displayName != null) 'displayName': displayName,
        },
      );
      return Success(TeamProfile.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 프로필 이미지 변경
  Future<Result<TeamProfile>> updateProfileImage(
    String teamId, {
    required String imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });

      final response = await _apiClient.uploadFile(
        ApiEndpoints.teamProfileImage(teamId),
        formData: formData,
      );
      return Success(TeamProfile.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 특정 멤버의 팀 프로필 조회
  Future<Result<TeamProfile>> getTeamProfileByUserId(
    String teamId,
    String userId,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.teamProfileMember(teamId, userId),
      );
      return Success(TeamProfile.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }
}
