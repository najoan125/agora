# Flutter WebSocket & STOMP 연결 관리

## 개요

stomp 패키지를 사용한 실시간 채팅 구현

---

## 1. WebSocket 서비스 (STOMP)

### lib/services/websocket_service.dart

```dart
import 'package:stomp/stomp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_app/core/utils/logger.dart';
import 'package:agora_app/core/utils/secure_storage.dart';

class WebSocketService {
  static const String _wsUrl = 'wss://api.hyfata.com/ws/agora/chat';

  late StompClient _client;
  final _storage = SecureStorageManager();

  Function(String, dynamic)? _onMessage;
  Function()? _onConnect;
  Function()? _onDisconnect;

  bool get isConnected => _client.isConnected ?? false;

  /// WebSocket 연결
  Future<void> connect({
    Function(String, dynamic)? onMessage,
    Function()? onConnect,
    Function()? onDisconnect,
  }) async {
    _onMessage = onMessage;
    _onConnect = onConnect;
    _onDisconnect = onDisconnect;

    final token = await _storage.getAccessToken();
    if (token == null) {
      throw Exception('Access token not found');
    }

    _client = StompClient(
      config: StompConfig(
        url: _wsUrl,
        onConnect: _handleConnect,
        onDisconnect: _handleDisconnect,
        onError: _handleError,
        stompConnectHeaders: {
          'Authorization': 'Bearer $token',
          'heart-beat': '10000,10000',
        },
      ),
    );

    try {
      await _client.connect();
    } catch (e) {
      AppLogger.error('WebSocket connection failed', error: e);
      rethrow;
    }
  }

  /// 채팅방 구독
  void subscribeToChatRoom(int chatId) {
    if (!isConnected) {
      AppLogger.warning('WebSocket not connected');
      return;
    }

    final subscription = _client.subscribe(
      destination: '/topic/agora/chat/$chatId',
      callback: (frame) {
        try {
          _onMessage?.call('chat_$chatId', _parseFrame(frame));
        } catch (e) {
          AppLogger.error('Failed to parse message', error: e);
        }
      },
    );

    AppLogger.debug('Subscribed to chat room: $chatId');
  }

  /// 채팅방 구독 해제
  void unsubscribeFromChatRoom(int chatId) {
    _client.unsubscribe(destination: '/topic/agora/chat/$chatId');
    AppLogger.debug('Unsubscribed from chat room: $chatId');
  }

  /// 메시지 전송
  void sendMessage({
    required int chatId,
    required String content,
  }) {
    if (!isConnected) {
      AppLogger.warning('WebSocket not connected');
      return;
    }

    _client.send(
      destination: '/app/agora/chat/$chatId/send',
      body: jsonEncode({
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    AppLogger.debug('Message sent to chat room: $chatId');
  }

  /// 읽음 처리
  void markAsRead({
    required int chatId,
    required List<int> messageIds,
  }) {
    if (!isConnected) {
      AppLogger.warning('WebSocket not connected');
      return;
    }

    _client.send(
      destination: '/app/agora/chat/$chatId/read',
      body: jsonEncode({
        'messageIds': messageIds,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  }

  /// 연결 완료
  void _handleConnect(StompFrame frame) {
    AppLogger.info('WebSocket connected');
    _onConnect?.call();
  }

  /// 연결 해제
  void _handleDisconnect(StompFrame frame) {
    AppLogger.info('WebSocket disconnected');
    _onDisconnect?.call();
  }

  /// 에러 처리
  void _handleError(StompFrame frame) {
    AppLogger.error('WebSocket error: ${frame.body}');
  }

  /// STOMP 프레임 파싱
  dynamic _parseFrame(StompFrame frame) {
    try {
      return jsonDecode(frame.body ?? '{}');
    } catch (e) {
      return {'raw': frame.body};
    }
  }

  /// 연결 해제
  Future<void> disconnect() async {
    if (isConnected) {
      await _client.disconnect();
      AppLogger.info('WebSocket disconnected manually');
    }
  }

  /// 재연결
  Future<void> reconnect() async {
    await disconnect();
    await Future.delayed(Duration(seconds: 2));
    await connect(
      onMessage: _onMessage,
      onConnect: _onConnect,
      onDisconnect: _onDisconnect,
    );
  }
}

final webSocketServiceProvider = Provider((ref) => WebSocketService());
```

---

## 2. 메시지 모델

### lib/data/models/chat_message_model.dart

```dart
import 'package:json_annotation/json_annotation.dart';

part 'chat_message_model.g.dart';

@JsonSerializable()
class ChatMessageModel {
  final int messageId;
  final int chatId;
  final String senderEmail;
  final String content;
  final String messageType; // TEXT, IMAGE, FILE
  final List<String>? attachmentUrls;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ChatMessageModel({
    required this.messageId,
    required this.chatId,
    required this.senderEmail,
    required this.content,
    required this.messageType,
    this.attachmentUrls,
    required this.isDeleted,
    required this.createdAt,
    this.updatedAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);
}
```

---

## 3. 채팅 상태 관리

### lib/presentation/providers/chat_provider.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_app/data/models/chat_message_model.dart';
import 'package:agora_app/services/websocket_service.dart';

class ChatNotifier extends StateNotifier<List<ChatMessageModel>> {
  final WebSocketService webSocketService;
  int? _currentChatId;

  ChatNotifier(this.webSocketService) : super([]);

  /// 채팅방 입장
  void enterChatRoom(int chatId) {
    _currentChatId = chatId;
    webSocketService.subscribeToChatRoom(chatId);
    state = [];
  }

  /// 채팅방 퇴장
  void leaveChatRoom(int chatId) {
    webSocketService.unsubscribeFromChatRoom(chatId);
    _currentChatId = null;
  }

  /// 메시지 수신 (WebSocket 콜백)
  void onMessageReceived(ChatMessageModel message) {
    state = [...state, message];
  }

  /// 메시지 전송
  void sendMessage(String content) {
    if (_currentChatId == null) return;
    webSocketService.sendMessage(
      chatId: _currentChatId!,
      content: content,
    );
  }

  /// 메시지 업데이트 (로컬 상태에만)
  void addMessageLocally(ChatMessageModel message) {
    state = [...state, message];
  }

  /// 메시지 목록 초기화
  void initializeMessages(List<ChatMessageModel> messages) {
    state = messages;
  }

  /// 읽음 처리
  void markMessagesAsRead(List<int> messageIds) {
    if (_currentChatId == null) return;
    webSocketService.markAsRead(
      chatId: _currentChatId!,
      messageIds: messageIds,
    );
  }

  /// 메시지 삭제
  void removeMessage(int messageId) {
    state = state.where((msg) => msg.messageId != messageId).toList();
  }

  /// 메시지 리스트 클리어
  void clearMessages() {
    state = [];
    _currentChatId = null;
  }
}

final chatMessagesProvider = StateNotifierProvider<ChatNotifier, List<ChatMessageModel>>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  return ChatNotifier(webSocketService);
});

// 현재 채팅방 ID
final currentChatIdProvider = StateProvider<int?>((ref) => null);

// 메시지 개수
final messageCountProvider = Provider((ref) {
  final messages = ref.watch(chatMessagesProvider);
  return messages.length;
});
```

---

## 4. 채팅 API (REST)

### lib/data/datasources/remote/chat_api.dart

```dart
import 'package:dio/dio.dart';
import 'package:agora_app/core/constants/api_endpoints.dart';
import 'package:agora_app/data/datasources/remote/api_client.dart';
import 'package:agora_app/data/models/chat_message_model.dart';

class ChatApi {
  final ApiClient apiClient;

  ChatApi(this.apiClient);

  /// 채팅방 목록 조회
  Future<List<Map<String, dynamic>>> getChatList() async {
    final response = await apiClient.get(ApiEndpoints.chats);
    return (response as List).cast<Map<String, dynamic>>();
  }

  /// 채팅방 생성 또는 조회 (1:1)
  Future<Map<String, dynamic>> createOrGetChat(String targetAgoraId) async {
    return await apiClient.post(
      ApiEndpoints.chats,
      data: {'targetAgoraId': targetAgoraId},
    );
  }

  /// 메시지 목록 조회 (커서 페이징)
  Future<List<ChatMessageModel>> getMessages({
    required int chatId,
    String? cursor,
    int limit = 30,
  }) async {
    final response = await apiClient.get(
      '${ApiEndpoints.chatMessages}/$chatId/messages',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
      },
    );

    return (response as List)
        .map((json) => ChatMessageModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// 메시지 전송 (REST API - 저장용)
  Future<ChatMessageModel> sendMessage({
    required int chatId,
    required String content,
  }) async {
    final response = await apiClient.post(
      '${ApiEndpoints.chatMessages}/$chatId/messages',
      data: {'content': content},
    );

    return ChatMessageModel.fromJson(response);
  }

  /// 메시지 삭제
  Future<void> deleteMessage({
    required int chatId,
    required int messageId,
  }) async {
    await apiClient.delete(
      '${ApiEndpoints.chatMessages}/$chatId/messages/$messageId',
    );
  }

  /// 읽음 처리
  Future<void> markAsRead(int chatId) async {
    await apiClient.put(
      '${ApiEndpoints.chatMessages}/$chatId/read',
    );
  }
}

final chatApiProvider = Provider((ref) => ChatApi(ref.watch(apiClientProvider)));
```

---

## 5. 채팅 화면 예제

### lib/presentation/screens/chat/chat_detail_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_app/presentation/providers/chat_provider.dart';
import 'package:agora_app/services/websocket_service.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final int chatId;
  final String chatName;

  const ChatDetailScreen({
    required this.chatId,
    required this.chatName,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _messageController = TextEditingController();
  late final WebSocketService _webSocket;

  @override
  void initState() {
    super.initState();
    _webSocket = ref.read(webSocketServiceProvider);

    // 채팅방 입장
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatMessagesProvider.notifier).enterChatRoom(widget.chatId);

      // WebSocket 메시지 수신 콜백
      _setupWebSocketListeners();
    });
  }

  void _setupWebSocketListeners() {
    _webSocket.connect(
      onMessage: (subscription, data) {
        if (subscription.contains('chat_${widget.chatId}')) {
          final message = ChatMessageModel.fromJson(data);
          ref.read(chatMessagesProvider.notifier).onMessageReceived(message);
        }
      },
      onConnect: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('실시간 채팅 연결됨')),
        );
      },
      onDisconnect: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('연결 해제')),
        );
      },
    );
  }

  @override
  void dispose() {
    ref.read(chatMessagesProvider.notifier).leaveChatRoom(widget.chatId);
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    final content = _messageController.text;
    _messageController.clear();

    // WebSocket으로 전송
    ref.read(chatMessagesProvider.notifier).sendMessage(content);

    // UI 즉시 업데이트 (옵션)
    // ref.read(chatMessagesProvider.notifier).addMessageLocally(...)
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.chatName)),
      body: Column(
        children: [
          // 메시지 목록
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // 메시지 입력창
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '메시지 입력...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: _sendMessage,
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.senderEmail, style: TextStyle(fontSize: 12)),
            SizedBox(height: 4),
            Text(message.content),
            SizedBox(height: 4),
            Text(
              message.createdAt.toString(),
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 6. 연결 상태 모니터링

### lib/services/websocket_connection_manager.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_app/services/websocket_service.dart';
import 'package:agora_app/core/utils/logger.dart';

enum WebSocketStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class WebSocketConnectionManager extends StateNotifier<WebSocketStatus> {
  final WebSocketService webSocketService;

  WebSocketConnectionManager(this.webSocketService)
      : super(WebSocketStatus.disconnected) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      state = WebSocketStatus.connecting;

      await webSocketService.connect(
        onConnect: _onConnected,
        onDisconnect: _onDisconnected,
      );
    } catch (e) {
      AppLogger.error('WebSocket initialization failed', error: e);
      state = WebSocketStatus.error;
      _scheduleReconnect();
    }
  }

  void _onConnected() {
    state = WebSocketStatus.connected;
    AppLogger.info('WebSocket connected');
  }

  void _onDisconnected() {
    state = WebSocketStatus.disconnected;
    AppLogger.info('WebSocket disconnected');
    _scheduleReconnect();
  }

  /// 자동 재연결 (10초 후)
  void _scheduleReconnect() {
    Future.delayed(Duration(seconds: 10), () {
      if (state != WebSocketStatus.connected) {
        _initialize();
      }
    });
  }

  Future<void> disconnect() async {
    await webSocketService.disconnect();
    state = WebSocketStatus.disconnected;
  }
}

final webSocketConnectionProvider = StateNotifierProvider<
    WebSocketConnectionManager,
    WebSocketStatus>((ref) {
  return WebSocketConnectionManager(ref.watch(webSocketServiceProvider));
});
```

---

## 7. 연결 상태 위젯

```dart
class WebSocketConnectionIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(webSocketConnectionProvider);

    Color statusColor;
    String statusText;

    switch (connectionState) {
      case WebSocketStatus.connected:
        statusColor = Colors.green;
        statusText = '연결됨';
        break;
      case WebSocketStatus.connecting:
        statusColor = Colors.orange;
        statusText = '연결 중...';
        break;
      case WebSocketStatus.error:
        statusColor = Colors.red;
        statusText = '연결 오류';
        break;
      default:
        statusColor = Colors.grey;
        statusText = '연결 안 됨';
    }

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Text(statusText, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
```

---

## 주의사항

1. **하트비트**: 10초마다 연결 유지 신호 전송
2. **자동 재연결**: 연결 끊김 시 자동 재시도
3. **메모리 누수**: 채팅방 퇴장 시 구독 해제 필수
4. **토큰 갱신**: WebSocket 재연결 시 새 토큰 사용

---

## 다음 단계

- FLUTTER_FCM.md - Firebase Cloud Messaging
- FLUTTER_FILE_UPLOAD.md - 파일 업로드 구현
