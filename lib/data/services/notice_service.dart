import 'package:dio/dio.dart';
import '../api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/exception/app_exception.dart';
import '../models/team/team.dart';

/// 팀 공지 관리 서비스
class NoticeService {
  final ApiClient _apiClient;

  NoticeService([ApiClient? apiClient]) : _apiClient = apiClient ?? ApiClient();

  /// 공지 목록 조회
  Future<Result<List<Notice>>> getNotices(String teamId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.teamNotices(teamId));
      final List<dynamic> data = response.data['content'] ?? response.data;
      final notices = data.map((json) => Notice.fromJson(json)).toList();
      return Success(notices);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 공지 생성
  Future<Result<Notice>> createNotice(
    String teamId, {
    required String title,
    required String content,
    bool isPinned = false,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.teamNotices(teamId),
        data: {
          'title': title,
          'content': content,
          'isPinned': isPinned,
        },
      );
      return Success(Notice.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 공지 수정
  Future<Result<Notice>> updateNotice(
    String teamId,
    String noticeId, {
    String? title,
    String? content,
    bool? isPinned,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.teamNoticeById(teamId, noticeId),
        data: {
          if (title != null) 'title': title,
          if (content != null) 'content': content,
          if (isPinned != null) 'isPinned': isPinned,
        },
      );
      return Success(Notice.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 공지 삭제
  Future<Result<void>> deleteNotice(String teamId, String noticeId) async {
    try {
      await _apiClient.delete(ApiEndpoints.teamNoticeById(teamId, noticeId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }
}
