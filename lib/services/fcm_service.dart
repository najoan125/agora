import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/utils/secure_storage_manager.dart';
import '../data/services/notification_service.dart';

/// FCM 푸시 알림 서비스
class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final NotificationService _notificationService = NotificationService();

  final _messageController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onMessage => _messageController.stream;

  bool _initialized = false;

  /// FCM 초기화
  Future<void> initialize() async {
    if (_initialized) return;

    // 권한 요청
    await _requestPermission();

    // 로컬 알림 초기화
    await _initializeLocalNotifications();

    // FCM 메시지 핸들러 설정
    _setupMessageHandlers();

    // 토큰 가져오기 및 등록
    await _registerToken();

    // 토큰 갱신 리스너
    _messaging.onTokenRefresh.listen(_onTokenRefresh);

    _initialized = true;
  }

  /// 권한 요청
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    print('FCM Permission: ${settings.authorizationStatus}');
  }

  /// 로컬 알림 초기화
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Android 알림 채널 생성
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'agora_messages',
        'Agora Messages',
        description: 'Agora 메시지 알림',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// 메시지 핸들러 설정
  void _setupMessageHandlers() {
    // 앱이 포그라운드일 때
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 앱이 백그라운드에서 열릴 때
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  /// 포그라운드 메시지 처리
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message: ${message.messageId}');

    // 스트림으로 전달
    _messageController.add(message);

    // 로컬 알림 표시
    await _showLocalNotification(message);
  }

  /// 백그라운드에서 앱이 열릴 때
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.messageId}');
    _messageController.add(message);
    _navigateToScreen(message);
  }

  /// 로컬 알림 표시
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'agora_messages',
      'Agora Messages',
      channelDescription: 'Agora 메시지 알림',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data['type'],
    );
  }

  /// 알림 탭 처리
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // 알림 타입에 따라 라우팅
      print('Notification tapped: $payload');
    }
  }

  /// 알림에 따른 화면 이동
  void _navigateToScreen(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    final relatedId = data['relatedId'];

    // 타입에 따라 적절한 화면으로 이동
    switch (type) {
      case 'MESSAGE':
        // 채팅 화면으로 이동
        break;
      case 'FRIEND_REQUEST':
        // 친구 요청 화면으로 이동
        break;
      case 'TEAM_INVITE':
        // 팀 초대 화면으로 이동
        break;
      default:
        // 알림 목록으로 이동
        break;
    }
  }

  /// FCM 토큰 등록
  Future<void> _registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await SecureStorageManager.saveFcmToken(token);

        // 로그인 상태면 서버에 등록
        final isLoggedIn = await SecureStorageManager.isLoggedIn();
        if (isLoggedIn) {
          await _notificationService.registerFcmToken(
            token: token,
            deviceType: Platform.isIOS ? 'IOS' : 'ANDROID',
            deviceId: await SecureStorageManager.getDeviceId(),
          );
        }
      }
    } catch (e) {
      print('FCM token registration failed: $e');
    }
  }

  /// 토큰 갱신 처리
  Future<void> _onTokenRefresh(String token) async {
    await SecureStorageManager.saveFcmToken(token);

    final isLoggedIn = await SecureStorageManager.isLoggedIn();
    if (isLoggedIn) {
      await _notificationService.registerFcmToken(
        token: token,
        deviceType: Platform.isIOS ? 'IOS' : 'ANDROID',
        deviceId: await SecureStorageManager.getDeviceId(),
      );
    }
  }

  /// 현재 FCM 토큰 가져오기
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  /// FCM 토큰 해제 (로그아웃 시)
  Future<void> unregisterToken() async {
    try {
      await _notificationService.unregisterFcmToken();
    } catch (e) {
      print('FCM token unregistration failed: $e');
    }
  }

  /// 리소스 해제
  void dispose() {
    _messageController.close();
  }
}

/// 백그라운드 메시지 핸들러 (앱 외부에서 정의 필요)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.messageId}');
  // 백그라운드에서의 처리 로직
}
