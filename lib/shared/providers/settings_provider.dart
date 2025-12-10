import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/settings_service.dart';
import '../../data/services/account_service.dart';
import '../../data/models/settings/settings.dart';

/// Settings 서비스 Provider
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

/// Account 서비스 Provider
final accountServiceProvider = Provider<AccountService>((ref) {
  return AccountService();
});

/// 알림 설정 Provider
final notificationSettingsProvider =
    FutureProvider.autoDispose<NotificationSettings?>((ref) async {
  final service = ref.watch(settingsServiceProvider);
  final result = await service.getNotificationSettings();

  return result.when(
    success: (settings) => settings,
    failure: (error) => throw error,
  );
});

/// 개인정보 설정 Provider
final privacySettingsProvider =
    FutureProvider.autoDispose<PrivacySettings?>((ref) async {
  final service = ref.watch(settingsServiceProvider);
  final result = await service.getPrivacySettings();

  return result.when(
    success: (settings) => settings,
    failure: (error) => throw error,
  );
});

/// 설정 작업 상태
class SettingsActionState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const SettingsActionState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });
}

/// 설정 작업 Notifier
class SettingsActionNotifier extends StateNotifier<SettingsActionState> {
  final SettingsService _settingsService;
  final AccountService _accountService;
  final Ref _ref;

  SettingsActionNotifier(this._settingsService, this._accountService, this._ref)
      : super(const SettingsActionState());

  /// 알림 설정 업데이트
  Future<bool> updateNotificationSettings(
      NotificationSettings settings) async {
    state = const SettingsActionState(isLoading: true);

    final result = await _settingsService.updateNotificationSettings(settings);

    return result.when(
      success: (_) {
        state = const SettingsActionState(
            successMessage: '알림 설정이 변경되었습니다.');
        _ref.invalidate(notificationSettingsProvider);
        return true;
      },
      failure: (error) {
        state = SettingsActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  /// 개인정보 설정 업데이트
  Future<bool> updatePrivacySettings(PrivacySettings settings) async {
    state = const SettingsActionState(isLoading: true);

    final result = await _settingsService.updatePrivacySettings(settings);

    return result.when(
      success: (_) {
        state = const SettingsActionState(
            successMessage: '개인정보 설정이 변경되었습니다.');
        _ref.invalidate(privacySettingsProvider);
        return true;
      },
      failure: (error) {
        state = SettingsActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  /// 생일 알림 설정 업데이트
  Future<bool> updateBirthdayReminder(
      BirthdayReminderSettings settings) async {
    state = const SettingsActionState(isLoading: true);

    final result = await _settingsService.updateBirthdayReminder(settings);

    return result.when(
      success: (_) {
        state = const SettingsActionState(
            successMessage: '생일 알림 설정이 변경되었습니다.');
        return true;
      },
      failure: (error) {
        state = SettingsActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  /// 비밀번호 변경
  Future<bool> changePassword(
      String currentPassword, String newPassword, String confirmPassword) async {
    state = const SettingsActionState(isLoading: true);

    final result = await _accountService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    return result.when(
      success: (_) {
        state = const SettingsActionState(
            successMessage: '비밀번호가 변경되었습니다.');
        return true;
      },
      failure: (error) {
        state = SettingsActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  /// 계정 비활성화
  Future<bool> deactivateAccount() async {
    state = const SettingsActionState(isLoading: true);

    final result = await _accountService.deactivateAccount();

    return result.when(
      success: (_) {
        state = const SettingsActionState(
            successMessage: '계정이 비활성화되었습니다. 30일 이내에 복구할 수 있습니다.');
        return true;
      },
      failure: (error) {
        state = SettingsActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  /// 계정 삭제
  Future<bool> deleteAccount() async {
    state = const SettingsActionState(isLoading: true);

    final result = await _accountService.deleteAccount();

    return result.when(
      success: (_) {
        state = const SettingsActionState(
            successMessage: '계정이 영구 삭제되었습니다.');
        return true;
      },
      failure: (error) {
        state = SettingsActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  /// 계정 복구
  Future<bool> restoreAccount() async {
    state = const SettingsActionState(isLoading: true);

    final result = await _accountService.restoreAccount();

    return result.when(
      success: (_) {
        state = const SettingsActionState(successMessage: '계정이 복구되었습니다.');
        return true;
      },
      failure: (error) {
        state = SettingsActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  void clearError() {
    state = const SettingsActionState();
  }

  void clearSuccessMessage() {
    state = const SettingsActionState();
  }
}

/// 설정 작업 Provider
final settingsActionProvider =
    StateNotifierProvider<SettingsActionNotifier, SettingsActionState>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  final accountService = ref.watch(accountServiceProvider);
  return SettingsActionNotifier(settingsService, accountService, ref);
});
