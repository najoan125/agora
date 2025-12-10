import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/chat_service.dart';
import '../../data/models/chat/chat.dart';
import '../../services/websocket_service.dart';

/// Chat 서비스 Provider
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

/// WebSocket 서비스 Provider
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// WebSocket 연결 상태 Provider
final webSocketConnectionStateProvider =
    StreamProvider.autoDispose<WebSocketConnectionState>((ref) {
  final service = ref.watch(webSocketServiceProvider);
  return service.connectionState;
});

/// 채팅방 목록 Provider
final chatListProvider = FutureProvider.autoDispose<List<Chat>>((ref) async {
  final service = ref.watch(chatServiceProvider);
  final result = await service.getChats();

  return result.when(
    success: (chats) => chats,
    failure: (error) => throw error,
  );
});

/// 특정 채팅방 Provider
final chatByIdProvider =
    FutureProvider.autoDispose.family<Chat, String>((ref, chatId) async {
  final service = ref.watch(chatServiceProvider);
  final result = await service.getChatById(chatId);

  return result.when(
    success: (chat) => chat,
    failure: (error) => throw error,
  );
});

/// 메시지 목록 상태
class MessageListState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool hasMore;
  final String? nextCursor;
  final String? error;

  const MessageListState({
    this.messages = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.nextCursor,
    this.error,
  });

  MessageListState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? hasMore,
    String? nextCursor,
    String? error,
  }) {
    return MessageListState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      error: error,
    );
  }
}

/// 메시지 목록 Notifier
class MessageListNotifier extends StateNotifier<MessageListState> {
  final ChatService _chatService;
  final WebSocketService _webSocketService;
  final String chatId;
  StreamSubscription? _eventSubscription;

  MessageListNotifier(
    this._chatService,
    this._webSocketService,
    this.chatId,
  ) : super(const MessageListState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadMessages();
    _subscribeToChat();
  }

  void _subscribeToChat() {
    _webSocketService.subscribeToChatRoom(chatId);

    _eventSubscription = _webSocketService.events
        .where((event) => event.chatId == chatId)
        .listen(_handleWebSocketEvent);
  }

  void _handleWebSocketEvent(WebSocketEvent event) {
    switch (event.type) {
      case WebSocketEventType.message:
        final message = ChatMessage.fromJson(event.data as Map<String, dynamic>);
        state = state.copyWith(
          messages: [message, ...state.messages],
        );
        break;
      case WebSocketEventType.read:
        // 읽음 처리 UI 업데이트
        break;
      default:
        break;
    }
  }

  /// 메시지 로드
  Future<void> loadMessages({bool loadMore = false}) async {
    if (state.isLoading) return;
    if (loadMore && !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _chatService.getMessages(
      chatId,
      cursorId: loadMore ? state.nextCursor : null,
    );

    result.when(
      success: (response) {
        final newMessages = loadMore
            ? [...state.messages, ...response.content]
            : response.content;

        state = state.copyWith(
          messages: newMessages,
          isLoading: false,
          hasMore: response.hasNext,
          nextCursor: response.nextCursor,
        );
      },
      failure: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.displayMessage,
        );
      },
    );
  }

  /// 메시지 전송 (WebSocket)
  void sendMessage({
    required String content,
    MessageType type = MessageType.text,
    String? replyToId,
    List<String>? fileIds,
  }) {
    _webSocketService.sendMessage(
      chatId,
      content: content,
      type: type,
      replyToId: replyToId,
      fileIds: fileIds,
    );
  }

  /// 읽음 처리
  void markAsRead() {
    _webSocketService.markAsRead(chatId);
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _webSocketService.unsubscribeFromChatRoom(chatId);
    super.dispose();
  }
}

/// 특정 채팅방 메시지 Provider
final messageListProvider = StateNotifierProvider.autoDispose
    .family<MessageListNotifier, MessageListState, String>((ref, chatId) {
  final chatService = ref.watch(chatServiceProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return MessageListNotifier(chatService, webSocketService, chatId);
});

/// 현재 채팅방 ID Provider
final currentChatIdProvider = StateProvider<String?>((ref) => null);

/// 채팅 작업 상태
class ChatActionState {
  final bool isLoading;
  final String? error;

  const ChatActionState({
    this.isLoading = false,
    this.error,
  });
}

/// 채팅 작업 Notifier
class ChatActionNotifier extends StateNotifier<ChatActionState> {
  final ChatService _service;
  final Ref _ref;

  ChatActionNotifier(this._service, this._ref)
      : super(const ChatActionState());

  /// 1:1 채팅 시작
  Future<Chat?> startDirectChat(String targetAgoraId) async {
    state = const ChatActionState(isLoading: true);

    final result = await _service.getOrCreateDirectChat(targetAgoraId);

    return result.when(
      success: (chat) {
        state = const ChatActionState();
        _ref.invalidate(chatListProvider);
        return chat;
      },
      failure: (error) {
        state = ChatActionState(error: error.displayMessage);
        return null;
      },
    );
  }

  /// 메시지 삭제
  Future<bool> deleteMessage(String chatId, String messageId) async {
    state = const ChatActionState(isLoading: true);

    final result = await _service.deleteMessage(chatId, messageId);

    return result.when(
      success: (_) {
        state = const ChatActionState();
        return true;
      },
      failure: (error) {
        state = ChatActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  void clearError() {
    state = const ChatActionState();
  }
}

/// 채팅 작업 Provider
final chatActionProvider =
    StateNotifierProvider<ChatActionNotifier, ChatActionState>((ref) {
  final service = ref.watch(chatServiceProvider);
  return ChatActionNotifier(service, ref);
});
