import 'package:dio/dio.dart';
import '../api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/exception/app_exception.dart';
import '../models/team/team.dart';

/// 팀 이벤트 관리 서비스
class EventService {
  final ApiClient _apiClient;

  EventService([ApiClient? apiClient]) : _apiClient = apiClient ?? ApiClient();

  /// 이벤트 목록 조회
  Future<Result<List<Event>>> getEvents(String teamId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.teamEvents(teamId));
      final List<dynamic> data = response.data['content'] ?? response.data;
      final events = data.map((json) => Event.fromJson(json)).toList();
      return Success(events);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 이벤트 생성
  Future<Result<Event>> createEvent(
    String teamId, {
    required String title,
    String? description,
    String? location,
    required DateTime startTime,
    required DateTime endTime,
    bool isAllDay = false,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.teamEvents(teamId),
        data: {
          'title': title,
          if (description != null) 'description': description,
          if (location != null) 'location': location,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'isAllDay': isAllDay,
        },
      );
      return Success(Event.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 이벤트 수정
  Future<Result<Event>> updateEvent(
    String teamId,
    String eventId, {
    String? title,
    String? description,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.teamEventById(teamId, eventId),
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (location != null) 'location': location,
          if (startTime != null) 'startTime': startTime.toIso8601String(),
          if (endTime != null) 'endTime': endTime.toIso8601String(),
          if (isAllDay != null) 'isAllDay': isAllDay,
        },
      );
      return Success(Event.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 이벤트 삭제
  Future<Result<void>> deleteEvent(String teamId, String eventId) async {
    try {
      await _apiClient.delete(ApiEndpoints.teamEventById(teamId, eventId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }
}
