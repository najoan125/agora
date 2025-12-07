import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:stomp_dart_client/stomp_handler.dart';
import '../core/utils/secure_storage_manager.dart';
import '../core/constants/api_endpoints.dart';
import '../data/models/chat/chat.dart';

/// WebSocket 연결 상태
enum WebSocketConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

/// WebSocket 이벤트 타입
enum WebSocketEventType {
  message,
  read,
  typing,
  userJoin,
  userLeave,
  error,
}

/// WebSocket 이벤트
class WebSocketEvent {
  final WebSocketEventType type;
  final String chatId;
  final dynamic data;
  final DateTime timestamp;

  const WebSocketEvent({
    required this.type,
    required this.chatId,
    required this.data,
    required this.timestamp,
  });

  factory WebSocketEvent.fromFrame(String chatId, Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'MESSAGE';
    final type = WebSocketEventType.values.firstWhere(
      (e) => e.name.toUpperCase() == typeStr.toUpperCase(),
      orElse: () => WebSocketEventType.message,
    );

    return WebSocketEvent(
      type: type,
      chatId: chatId,
      data: json['data'] ?? json,
      timestamp: DateTime.now(),
    );
  }
}

/// WebSocket 서비스 (STOMP 프로토콜)
class WebSocketService {
  StompClient? _client;
  final Map<String, StompUnsubscribe> _subscriptions = {};

  final _connectionStateController =
      StreamController<WebSocketConnectionState>.broadcast();
  final _eventController = StreamController<WebSocketEvent>.broadcast();

  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  /// 연결 상태 스트림
  Stream<WebSocketConnectionState> get connectionState =>
      _connectionStateController.stream;

  /// 이벤트 스트림
  Stream<WebSocketEvent> get events => _eventController.stream;

  /// 현재 연결 상태
  WebSocketConnectionState _currentState = WebSocketConnectionState.disconnected;
  WebSocketConnectionState get currentState => _currentState;

  /// WebSocket 연결
  Future<void> connect() async {
    if (_currentState == WebSocketConnectionState.connecting ||
        _currentState == WebSocketConnectionState.connected) {
      return;
    }

    _updateState(WebSocketConnectionState.connecting);

    try {
      final token = await SecureStorageManager.getAccessToken();
      if (token == null) {
        _updateState(WebSocketConnectionState.error);
        return;
      }

      _client = StompClient(
        config: StompConfig(
          url: ApiEndpoints.wsChat,
          stompConnectHeaders: {
            'Authorization': 'Bearer $token',
          },
          webSocketConnectHeaders: {
            'Authorization': 'Bearer $token',
          },
          onConnect: _onConnect,
          onDisconnect: _onDisconnect,
          onStompError: _onStompError,
          onWebSocketError: _onWebSocketError,
          heartbeatIncoming: const Duration(seconds: 10),
          heartbeatOutgoing: const Duration(seconds: 10),
          reconnectDelay: const Duration(seconds: 0), // 수동 재연결 사용
        ),
      );

      _client!.activate();
    } catch (e) {
      _updateState(WebSocketConnectionState.error);
      _scheduleReconnect();
    }
  }

  /// 연결 해제
  void disconnect() {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _reconnectAttempts = 0;

    // 모든 구독 해제
    for (final unsubscribe in _subscriptions.values) {
      unsubscribe();
    }
    _subscriptions.clear();

    _client?.deactivate();
    _client = null;
    _updateState(WebSocketConnectionState.disconnected);
  }

  /// 채팅방 구독
  void subscribeToChatRoom(String chatId) {
    if (_client == null || _currentState != WebSocketConnectionState.connected) {
      return;
    }

    // 이미 구독 중이면 무시
    if (_subscriptions.containsKey(chatId)) {
      return;
    }

    final unsubscribe = _client!.subscribe(
      destination: ApiEndpoints.wsChatTopic(chatId),
      callback: (frame) => _handleMessage(chatId, frame),
    );

    _subscriptions[chatId] = unsubscribe;
  }

  /// 채팅방 구독 해제
  void unsubscribeFromChatRoom(String chatId) {
    final unsubscribe = _subscriptions.remove(chatId);
    unsubscribe?.call();
  }

  /// 메시지 전송
  void sendMessage(
    String chatId, {
    required String content,
    MessageType type = MessageType.text,
    String? replyToId,
    List<String>? fileIds,
  }) {
    if (_client == null || _currentState != WebSocketConnectionState.connected) {
      return;
    }

    final body = jsonEncode({
      'content': content,
      'type': type.name.toUpperCase(),
      if (replyToId != null) 'replyToId': replyToId,
      if (fileIds != null) 'fileIds': fileIds,
    });

    _client!.send(
      destination: ApiEndpoints.wsChatSend(chatId),
      body: body,
    );
  }

  /// 읽음 처리
  void markAsRead(String chatId) {
    if (_client == null || _currentState != WebSocketConnectionState.connected) {
      return;
    }

    _client!.send(
      destination: ApiEndpoints.wsChatRead(chatId),
      body: '',
    );
  }

  /// 타이핑 표시 (옵션)
  void sendTypingIndicator(String chatId, bool isTyping) {
    // 타이핑 인디케이터 구현 (서버 지원 시)
  }

  // ============ Private Methods ============

  void _onConnect(StompFrame frame) {
    _reconnectAttempts = 0;
    _updateState(WebSocketConnectionState.connected);

    // 에러 큐 구독
    _client!.subscribe(
      destination: ApiEndpoints.wsUserErrors,
      callback: _handleError,
    );

    // 하트비트 시작
    _startHeartbeat();
  }

  void _onDisconnect(StompFrame frame) {
    _updateState(WebSocketConnectionState.disconnected);
    _heartbeatTimer?.cancel();
    _scheduleReconnect();
  }

  void _onStompError(StompFrame frame) {
    _eventController.add(WebSocketEvent(
      type: WebSocketEventType.error,
      chatId: '',
      data: frame.body ?? 'STOMP error',
      timestamp: DateTime.now(),
    ));
    _updateState(WebSocketConnectionState.error);
    _scheduleReconnect();
  }

  void _onWebSocketError(dynamic error) {
    _updateState(WebSocketConnectionState.error);
    _scheduleReconnect();
  }

  void _handleMessage(String chatId, StompFrame frame) {
    if (frame.body == null) return;

    try {
      final json = jsonDecode(frame.body!) as Map<String, dynamic>;
      final event = WebSocketEvent.fromFrame(chatId, json);
      _eventController.add(event);
    } catch (e) {
      // JSON 파싱 에러 무시
    }
  }

  void _handleError(StompFrame frame) {
    _eventController.add(WebSocketEvent(
      type: WebSocketEventType.error,
      chatId: '',
      data: frame.body ?? 'Unknown error',
      timestamp: DateTime.now(),
    ));
  }

  void _updateState(WebSocketConnectionState state) {
    _currentState = state;
    _connectionStateController.add(state);
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      return;
    }

    _reconnectTimer?.cancel();

    // 지수 백오프: 1s, 2s, 4s, 8s, ... max 60s
    final delay = Duration(
      seconds: (1 << _reconnectAttempts).clamp(1, 60),
    );
    _reconnectAttempts++;

    _reconnectTimer = Timer(delay, () {
      if (_currentState != WebSocketConnectionState.connected) {
        connect();
      }
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      // STOMP 라이브러리가 자동으로 heartbeat 처리
      // 추가 로직이 필요하면 여기에 구현
    });
  }

  /// 리소스 해제
  void dispose() {
    disconnect();
    _connectionStateController.close();
    _eventController.close();
  }
}
