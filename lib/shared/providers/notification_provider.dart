import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/notification_service.dart';
import '../../data/models/notification/notification.dart';

/// Notification 서비스 Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// 알림 목록 Provider
final notificationListProvider =
    FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  final result = await service.getNotifications();

  return result.when(
    success: (response) => response.content,
    failure: (error) => throw error,
  );
});

/// 읽지 않은 알림 수 Provider
final unreadNotificationCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  final result = await service.getUnreadCount();

  return result.when(
    success: (count) => count,
    failure: (error) => throw error,
  );
});

/// 알림 작업 상태
class NotificationActionState {
  final bool isLoading;
  final String? error;

  const NotificationActionState({
    this.isLoading = false,
    this.error,
  });
}

/// 알림 작업 Notifier
class NotificationActionNotifier extends StateNotifier<NotificationActionState> {
  final NotificationService _service;
  final Ref _ref;

  NotificationActionNotifier(this._service, this._ref)
      : super(const NotificationActionState());

  /// 알림 읽음 처리
  Future<bool> markAsRead(String notificationId) async {
    state = const NotificationActionState(isLoading: true);

    final result = await _service.markAsRead(notificationId);

    return result.when(
      success: (_) {
        state = const NotificationActionState();
        _ref.invalidate(notificationListProvider);
        _ref.invalidate(unreadNotificationCountProvider);
        return true;
      },
      failure: (error) {
        state = NotificationActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  /// 모든 알림 읽음 처리
  Future<bool> markAllAsRead() async {
    state = const NotificationActionState(isLoading: true);

    final result = await _service.markAllAsRead();

    return result.when(
      success: (_) {
        state = const NotificationActionState();
        _ref.invalidate(notificationListProvider);
        _ref.invalidate(unreadNotificationCountProvider);
        return true;
      },
      failure: (error) {
        state = NotificationActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  /// 알림 삭제
  Future<bool> deleteNotification(String notificationId) async {
    state = const NotificationActionState(isLoading: true);

    final result = await _service.deleteNotification(notificationId);

    return result.when(
      success: (_) {
        state = const NotificationActionState();
        _ref.invalidate(notificationListProvider);
        _ref.invalidate(unreadNotificationCountProvider);
        return true;
      },
      failure: (error) {
        state = NotificationActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  void clearError() {
    state = const NotificationActionState();
  }
}

/// 알림 작업 Provider
final notificationActionProvider =
    StateNotifierProvider<NotificationActionNotifier, NotificationActionState>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationActionNotifier(service, ref);
});
