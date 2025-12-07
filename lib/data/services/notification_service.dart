import 'package:dio/dio.dart';
import '../api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/exception/app_exception.dart';
import '../models/notification/notification.dart';

/// 알림 서비스
class NotificationService {
  final ApiClient _apiClient;

  NotificationService([ApiClient? apiClient])
      : _apiClient = apiClient ?? ApiClient();

  /// 알림 목록 조회
  Future<Result<NotificationListResponse>> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.notifications,
        queryParameters: {'page': page, 'size': size},
      );
      return Success(NotificationListResponse.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 읽지 않은 알림 수 조회
  Future<Result<int>> getUnreadCount() async {
    try {
      final response =
          await _apiClient.get(ApiEndpoints.notificationsUnreadCount);
      final data = UnreadCountResponse.fromJson(response.data);
      return Success(data.count);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 알림 읽음 처리
  Future<Result<void>> markAsRead(String notificationId) async {
    try {
      await _apiClient.put(ApiEndpoints.notificationRead(notificationId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 모든 알림 읽음 처리
  Future<Result<void>> markAllAsRead() async {
    try {
      await _apiClient.put(ApiEndpoints.notificationsReadAll);
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 알림 삭제
  Future<Result<void>> deleteNotification(String notificationId) async {
    try {
      await _apiClient.delete(ApiEndpoints.notificationDelete(notificationId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// FCM 토큰 등록
  Future<Result<void>> registerFcmToken({
    required String token,
    required String deviceType,
    String? deviceId,
  }) async {
    try {
      await _apiClient.post(
        ApiEndpoints.fcmToken,
        data: {
          'token': token,
          'deviceType': deviceType,
          if (deviceId != null) 'deviceId': deviceId,
        },
      );
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// FCM 토큰 해제
  Future<Result<void>> unregisterFcmToken() async {
    try {
      await _apiClient.delete(ApiEndpoints.fcmToken);
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }
}
