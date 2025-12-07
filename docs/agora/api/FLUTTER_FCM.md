# Flutter Firebase Cloud Messaging (FCM)

## 개요

Firebase Cloud Messaging으로 푸시 알림 수신 및 처리

---

## 1. Firebase 설정

### Firebase Console 설정

1. [Firebase Console](https://console.firebase.google.com) 접속
2. 프로젝트 선택
3. Cloud Messaging 탭에서 서버 API 키 복사
4. iOS: APNs 인증서 업로드
5. Android: Google Play Services 설정

---

## 2. FCM 서비스

### lib/services/fcm_service.dart

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_app/core/utils/logger.dart';
import 'package:agora_app/core/utils/secure_storage.dart';
import 'package:agora_app/data/datasources/remote/notification_api.dart';

class FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final _storage = SecureStorageManager();
  final NotificationApi _notificationApi;

  Function(String title, String body, Map<String, dynamic> data)?
      _onNotificationReceived;

  FcmService(this._notificationApi);

  /// FCM 초기화
  Future<void> initialize({
    Function(String title, String body, Map<String, dynamic> data)?
        onNotificationReceived,
  }) async {
    _onNotificationReceived = onNotificationReceived;

    // 알림 권한 요청
    await _requestPermission();

    // 포그라운드 메시지 처리
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 백그라운드 메시지 처리 (사용자가 탭했을 때)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // 앱 종료 상태에서 열린 경우
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }

    // FCM 토큰 등록
    await _registerFcmToken();

    // 토큰 갱신 리스너
    _firebaseMessaging.onTokenRefresh.listen(_handleTokenRefresh);

    AppLogger.info('FCM initialized');
  }

  /// 알림 권한 요청
  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      carPlay: false,
      criticalAlert: false,
      announcement: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.info('Notification permission granted');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      AppLogger.info('Notification permission granted (provisional)');
    } else {
      AppLogger.warning('Notification permission denied');
    }
  }

  /// FCM 토큰 등록
  Future<void> _registerFcmToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _notificationApi.registerFcmToken(
          token,
          deviceType: 'mobile',
        );
        AppLogger.debug('FCM token registered: $token');
      }
    } catch (e) {
      AppLogger.error('Failed to register FCM token', error: e);
    }
  }

  /// 토큰 갱신 처리
  Future<void> _handleTokenRefresh(String newToken) async {
    AppLogger.info('FCM token refreshed: $newToken');
    await _registerFcmToken();
  }

  /// 포그라운드 메시지 처리 (앱이 열려있을 때)
  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info('Foreground message received');

    final notification = message.notification;
    if (notification != null) {
      _onNotificationReceived?.call(
        notification.title ?? '',
        notification.body ?? '',
        message.data,
      );

      // 로컬 알림 표시 (선택적)
      _showLocalNotification(
        notification.title ?? '',
        notification.body ?? '',
      );
    }
  }

  /// 백그라운드 메시지 처리 (사용자가 알림을 탭했을 때)
  void _handleBackgroundMessage(RemoteMessage message) {
    AppLogger.info('Background message received');

    final data = message.data;
    final notificationType = data['type'];

    // 알림 타입에 따라 처리
    _routeToScreen(notificationType, data);
  }

  /// 알림 타입별 라우팅
  void _routeToScreen(String? type, Map<String, dynamic> data) {
    switch (type) {
      case 'FRIEND_REQUEST':
        _routeToFriendRequest(data);
        break;
      case 'MESSAGE':
        _routeToChat(data);
        break;
      case 'GROUP_INVITE':
        _routeToGroupInvite(data);
        break;
      case 'TEAM_INVITE':
        _routeToTeamInvite(data);
        break;
      default:
        AppLogger.warning('Unknown notification type: $type');
    }
  }

  void _routeToFriendRequest(Map<String, dynamic> data) {
    final fromAgoraId = data['fromAgoraId'];
    AppLogger.debug('Routing to friend request from: $fromAgoraId');
    // Navigator.of(context).pushNamed('/friends/requests');
  }

  void _routeToChat(Map<String, dynamic> data) {
    final chatId = int.tryParse(data['chatId'] ?? '0') ?? 0;
    AppLogger.debug('Routing to chat: $chatId');
    // Navigator.of(context).pushNamed('/chat/$chatId');
  }

  void _routeToGroupInvite(Map<String, dynamic> data) {
    AppLogger.debug('Routing to group invites');
  }

  void _routeToTeamInvite(Map<String, dynamic> data) {
    final teamId = data['teamId'];
    AppLogger.debug('Routing to team invite: $teamId');
  }

  /// 로컬 알림 표시 (선택적)
  void _showLocalNotification(String title, String body) {
    // flutter_local_notifications 패키지 사용
    // 또는 OS 기본 알림 사용
    AppLogger.debug('Local notification: $title - $body');
  }

  /// FCM 토큰 등록 해제 (로그아웃 시)
  Future<void> unregisterFcmToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _notificationApi.unregisterFcmToken(token);
        AppLogger.info('FCM token unregistered');
      }
    } catch (e) {
      AppLogger.error('Failed to unregister FCM token', error: e);
    }
  }

  /// 푸시 알림 비활성화
  Future<void> disablePushNotifications() async {
    try {
      await _firebaseMessaging.deleteToken();
      AppLogger.info('Push notifications disabled');
    } catch (e) {
      AppLogger.error('Failed to disable push notifications', error: e);
    }
  }
}

final fcmServiceProvider = Provider((ref) {
  final notificationApi = ref.watch(notificationApiProvider);
  return FcmService(notificationApi);
});
```

---

## 3. 알림 API

### lib/data/datasources/remote/notification_api.dart

```dart
import 'package:dio/dio.dart';
import 'package:agora_app/core/constants/api_endpoints.dart';
import 'package:agora_app/data/datasources/remote/api_client.dart';

class NotificationApi {
  final ApiClient apiClient;

  NotificationApi(this.apiClient);

  /// FCM 토큰 등록
  Future<void> registerFcmToken(
    String token, {
    String deviceType = 'mobile',
    String? deviceName,
  }) async {
    await apiClient.post(
      '/api/agora/notifications/fcm-token',
      data: {
        'token': token,
        'deviceType': deviceType,
        'deviceName': deviceName ?? 'Flutter Mobile',
      },
    );
  }

  /// FCM 토큰 등록 해제
  Future<void> unregisterFcmToken(String token) async {
    await apiClient.delete(
      '/api/agora/notifications/fcm-token',
      data: {'token': token},
    );
  }

  /// 알림 목록 조회
  Future<List<Map<String, dynamic>>> getNotifications({
    int limit = 100,
  }) async {
    final response = await apiClient.get(
      '/api/agora/notifications',
      queryParameters: {'limit': limit},
    );
    return (response as List).cast<Map<String, dynamic>>();
  }

  /// 읽지 않은 알림 수
  Future<int> getUnreadCount() async {
    final response = await apiClient.get(
      '/api/agora/notifications/unread-count',
    );
    return response['unreadCount'] ?? 0;
  }

  /// 알림 읽음 처리
  Future<void> markAsRead(int notificationId) async {
    await apiClient.put(
      '/api/agora/notifications/$notificationId/read',
    );
  }

  /// 모든 알림 읽음
  Future<void> markAllAsRead() async {
    await apiClient.put(
      '/api/agora/notifications/read-all',
    );
  }

  /// 알림 삭제
  Future<void> deleteNotification(int notificationId) async {
    await apiClient.delete(
      '/api/agora/notifications/$notificationId',
    );
  }
}

final notificationApiProvider = Provider((ref) => NotificationApi(
  ref.watch(apiClientProvider),
));
```

---

## 4. 알림 상태 관리

### lib/presentation/providers/notification_provider.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_app/data/datasources/remote/notification_api.dart';

class NotificationNotifier extends StateNotifier<Map<String, dynamic>> {
  final NotificationApi notificationApi;

  NotificationNotifier(this.notificationApi)
      : super({'unreadCount': 0, 'notifications': []}) {
    _initialize();
  }

  Future<void> _initialize() async {
    await refreshNotifications();
  }

  /// 알림 목록 갱신
  Future<void> refreshNotifications() async {
    try {
      final notifications = await notificationApi.getNotifications();
      final unreadCount = await notificationApi.getUnreadCount();

      state = {
        'unreadCount': unreadCount,
        'notifications': notifications,
      };
    } catch (e) {
      print('Failed to refresh notifications: $e');
    }
  }

  /// 알림 읽음 처리
  Future<void> markAsRead(int notificationId) async {
    try {
      await notificationApi.markAsRead(notificationId);
      await refreshNotifications();
    } catch (e) {
      print('Failed to mark notification as read: $e');
    }
  }

  /// 모든 알림 읽음
  Future<void> markAllAsRead() async {
    try {
      await notificationApi.markAllAsRead();
      await refreshNotifications();
    } catch (e) {
      print('Failed to mark all as read: $e');
    }
  }

  /// 알림 삭제
  Future<void> deleteNotification(int notificationId) async {
    try {
      await notificationApi.deleteNotification(notificationId);
      await refreshNotifications();
    } catch (e) {
      print('Failed to delete notification: $e');
    }
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, Map<String, dynamic>>((ref) {
  return NotificationNotifier(ref.watch(notificationApiProvider));
});

// 읽지 않은 알림 수
final unreadCountProvider = Provider((ref) {
  final notifications = ref.watch(notificationProvider);
  return notifications['unreadCount'] as int;
});

// 알림 목록
final notificationsListProvider = Provider((ref) {
  final notifications = ref.watch(notificationProvider);
  return (notifications['notifications'] as List).cast<Map<String, dynamic>>();
});
```

---

## 5. 알림 화면 예제

### lib/presentation/screens/notification_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_app/presentation/providers/notification_provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 알림 목록 갱신
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).refreshNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsListProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('알림 ($unreadCount)'),
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: Icon(Icons.done_all),
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
              },
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text('알림이 없습니다'),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationTile(notification);
              },
            ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool? ?? false;
    final title = notification['title'] as String? ?? '';
    final content = notification['content'] as String? ?? '';
    final notificationId = notification['notificationId'] as int? ?? 0;
    final type = notification['type'] as String? ?? '';

    return Container(
      color: isRead ? Colors.white : Colors.blue[50],
      child: ListTile(
        leading: _getTypeIcon(type),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(content, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Text('삭제'),
              value: 'delete',
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') {
              ref.read(notificationProvider.notifier)
                  .deleteNotification(notificationId);
            }
          },
        ),
        onTap: () {
          if (!isRead) {
            ref.read(notificationProvider.notifier).markAsRead(notificationId);
          }
          // 알림 타입에 따라 화면 이동
          _handleNotificationTap(type, notification);
        },
      ),
    );
  }

  Widget _getTypeIcon(String type) {
    switch (type) {
      case 'FRIEND_REQUEST':
        return Icon(Icons.person_add);
      case 'MESSAGE':
        return Icon(Icons.message);
      case 'GROUP_INVITE':
        return Icon(Icons.group);
      case 'TEAM_INVITE':
        return Icon(Icons.business);
      default:
        return Icon(Icons.notifications);
    }
  }

  void _handleNotificationTap(String type, Map<String, dynamic> notification) {
    switch (type) {
      case 'FRIEND_REQUEST':
        Navigator.pushNamed(context, '/friends/requests');
        break;
      case 'MESSAGE':
        final chatId = notification['chatId'];
        Navigator.pushNamed(context, '/chat/$chatId');
        break;
      case 'GROUP_INVITE':
        Navigator.pushNamed(context, '/chats/groups');
        break;
      case 'TEAM_INVITE':
        final teamId = notification['teamId'];
        Navigator.pushNamed(context, '/teams/$teamId');
        break;
    }
  }
}
```

---

## 6. 앱 시작 시 FCM 초기화

### lib/main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // flutterfire configure 실행 후 생성

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FCM 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final fcmService = ref.read(fcmServiceProvider);
      await fcmService.initialize(
        onNotificationReceived: (title, body, data) {
          print('Notification received: $title - $body');
          // UI 업데이트 또는 알림 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title: $body')),
          );
        },
      );
    });

    return MaterialApp(
      title: 'Agora',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}
```

---

## 7. 로그아웃 시 FCM 토큰 정리

```dart
// AuthProvider에 추가

Future<void> logout() async {
  try {
    // FCM 토큰 등록 해제
    final fcmService = ref.read(fcmServiceProvider);
    await fcmService.unregisterFcmToken();

    // 기존 로그아웃 로직
    await authRepository.logout();
    state = const AsyncValue.data(AuthState.unauthenticated);
  } catch (e, st) {
    state = AsyncValue.error(e, st);
  }
}
```

---

## 8. 테스트 (Firebase Console)

1. **Firebase Console** → **Cloud Messaging** → **새 캠페인**
2. **앱 선택**: Flutter 앱
3. **메시지 제목**: 테스트
4. **메시지 본문**: 테스트 메시지
5. **대상 선택**: 테스트 기기 또는 사용자 세그먼트
6. **일정**: 즉시 발송
7. **검토 및 게시**

---

## 주의사항

1. **권한**: 앱 설정에서 알림 권한 요청 필수
2. **백그라운드**: 앱 종료 상태에서도 알림 수신 가능
3. **토큰 갱신**: 주기적으로 토큰 갱신
4. **보안**: 민감한 정보는 알림에 포함하지 말 것
5. **테스트**: 개발 환경에서 충분히 테스트 후 배포

---

## 다음 단계

- FLUTTER_FILE_UPLOAD.md - 파일 업로드 구현
- FLUTTER_STATE_MANAGEMENT.md - 상태 관리 패턴
