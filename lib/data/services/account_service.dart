import 'package:dio/dio.dart';
import '../api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/exception/app_exception.dart';

/// 계정 관리 서비스
class AccountService {
  final ApiClient _apiClient;

  AccountService([ApiClient? apiClient]) : _apiClient = apiClient ?? ApiClient();

  /// 비밀번호 변경
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _apiClient.put(
        ApiEndpoints.accountPassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
      return const Success(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return Failure(AppException.validation(
          message: 'Invalid password',
          userMessage: '현재 비밀번호가 올바르지 않습니다.',
          error: e,
        ));
      }
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 계정 비활성화 (30일 유예 기간)
  Future<Result<void>> deactivateAccount() async {
    try {
      await _apiClient.post(ApiEndpoints.accountDeactivate);
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 계정 영구 삭제
  Future<Result<void>> deleteAccount() async {
    try {
      await _apiClient.delete(ApiEndpoints.account);
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 비활성화된 계정 복구
  Future<Result<void>> restoreAccount() async {
    try {
      await _apiClient.post(ApiEndpoints.accountRestore);
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }
}
