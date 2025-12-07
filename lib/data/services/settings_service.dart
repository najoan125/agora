import 'package:dio/dio.dart';
import '../api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/exception/app_exception.dart';
import '../models/settings/settings.dart';

/// 설정 서비스
class SettingsService {
  final ApiClient _apiClient;

  SettingsService([ApiClient? apiClient]) : _apiClient = apiClient ?? ApiClient();

  // ============ Notification Settings ============

  /// 알림 설정 조회
  Future<Result<NotificationSettings>> getNotificationSettings() async {
    try {
      final response =
          await _apiClient.get(ApiEndpoints.settingsNotifications);
      return Success(NotificationSettings.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 알림 설정 수정
  Future<Result<NotificationSettings>> updateNotificationSettings(
    NotificationSettings settings,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.settingsNotifications,
        data: settings.toJson(),
      );
      return Success(NotificationSettings.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  // ============ Privacy Settings ============

  /// 개인정보 설정 조회
  Future<Result<PrivacySettings>> getPrivacySettings() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.settingsPrivacy);
      return Success(PrivacySettings.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 개인정보 설정 수정
  Future<Result<PrivacySettings>> updatePrivacySettings(
    PrivacySettings settings,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.settingsPrivacy,
        data: settings.toJson(),
      );
      return Success(PrivacySettings.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  // ============ Birthday Reminder ============

  /// 생일 알림 설정 수정
  Future<Result<void>> updateBirthdayReminder(
    BirthdayReminderSettings settings,
  ) async {
    try {
      await _apiClient.put(
        ApiEndpoints.settingsBirthdayReminder,
        data: settings.toJson(),
      );
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }
}
