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
  return Stream<WebSocketConnectionState>.multi((controller) {
    controller.add(service.currentState);
    final subscription = service.connectionState.listen(
      controller.add,
      onError: controller.addError,
    );
    controller.onCancel = subscription.cancel;
  });
});

/// 채팅방 목록 Notifier
class ChatListNotifier extends StateNotifier<AsyncValue<List<Chat>>> {
  final ChatService _chatService;
  final WebSocketService _webSocketService;
  final Ref _ref;
  StreamSubscription? _eventSubscription;

  ChatListNotifier(this._chatService, this._webSocketService, this._ref)
      : super(const AsyncLoading()) {
    _init();
    _listenToChatRoomChanges();
  }

  Future<void> _init() async {
    await _fetchInitialChats();
    _subscribeToEvents();
  }

  Future<void> _fetchInitialChats() async {
    state = const AsyncLoading();
    final result = await _chatService.getChats();
    result.when(
      success: (chats) async {
        final updatedChats = await _fetchMissingParticipantDetails(chats);
        state = AsyncData(updatedChats);
      },
      failure: (error) {
        state = AsyncError(error, StackTrace.current);
      },
    );
  }

  Future<List<Chat>> _fetchMissingParticipantDetails(List<Chat> chats) async {
    return await Future.wait(chats.map((chat) async {
      var updatedChat = chat;

      // 1. 참여자 정보가 없는 1:1 채팅방의 상세 정보 조회
      if (chat.type == ChatType.direct &&
          (chat.participants == null || chat.participants!.isEmpty)) {
        final detailResult =
            await _chatService.getChatById(chat.id.toString());
        updatedChat = detailResult.when(
          success: (detailChat) => detailChat,
          failure: (_) => chat, // 실패 시 기존 chat 유지
        );
      }

      // 2. 마지막 메시지 정보가 없는 경우, 메시지 목록 조회하여 채워넣기
      // (목록 API에서 lastMessage가 누락되는 경우를 대비)
      if (updatedChat.lastMessageContent == null) {
        final messagesResult =
            await _chatService.getMessages(updatedChat.id.toString());
        
        updatedChat = messagesResult.when(
          success: (response) {
            if (response.content.isNotEmpty) {
              final lastMsg = response.content.first;
              return updatedChat.copyWith(
                lastMessageContent: lastMsg.toJson(), // 메시지 객체를 Map으로 저장
                lastMessageAt: lastMsg.createdAt,
                lastMessageId: lastMsg.id,
              );
            }
            return updatedChat;
          },
          failure: (_) => updatedChat,
        );
      }

      return updatedChat;
    }));
  }

  void _subscribeToEvents() {
    _eventSubscription =
        _webSocketService.events.listen(_handleWebSocketEvent);
  }

  void _handleWebSocketEvent(WebSocketEvent event) {
    if (event.type == WebSocketEventType.message) {
      final message = ChatMessage.fromJson(event.data as Map<String, dynamic>);
      _updateChatListWithMessage(message);
    }
  }

  void _updateChatListWithMessage(ChatMessage message) {
    state.whenData((chats) {
      final chatIndex = chats.indexWhere((c) => c.id == message.chatId);
      if (chatIndex != -1) {
        final currentChat = chats[chatIndex];
        final isUnread = _ref.read(currentChatIdProvider) != message.chatId;

        final updatedChat = currentChat.copyWith(
          lastMessageContent: message.content,
          lastMessageAt: message.createdAt,
          lastMessageId: message.id, // lastMessageId 저장
          unreadCount: isUnread
              ? (currentChat.unreadCount) + 1
              : currentChat.unreadCount,
        );

        final updatedList = [...chats];
        updatedList.removeAt(chatIndex);
        updatedList.insert(0, updatedChat);
        state = AsyncData(updatedList);
      }
    });
  }

  void _listenToChatRoomChanges() {
    _ref.listen<String?>(currentChatIdProvider, (previous, next) {
      if (next != null) {
        markAsRead(next);
      }
    });
  }

  void markAsRead(String chatId) {
    state.whenData((chats) {
      final chatIndex = chats.indexWhere((c) => c.id == chatId);
      if (chatIndex != -1) {
        final chat = chats[chatIndex];
        if (chat.unreadCount != 0) {
          final updatedChat = chat.copyWith(unreadCount: 0);
          final updatedList = [...chats];
          updatedList[chatIndex] = updatedChat;
          state = AsyncData(updatedList);

          // 서버에 읽음 상태 전송
          final latestMessageId = chat.lastMessageId;
          if (latestMessageId != null) {
            // WebSocketService.markAsRead는 int? messageId를 받으므로,
            // dynamic인 latestMessageId를 int로 변환 시도
            if (latestMessageId is int) {
              _webSocketService.markAsRead(chatId, messageId: latestMessageId);
            } else if (latestMessageId is String) {
              final parsedId = int.tryParse(latestMessageId);
              if (parsedId != null) {
                _webSocketService.markAsRead(chatId, messageId: parsedId);
              }
            }
          }
        }
      }
    });
  }

  void invalidate() {
    _fetchInitialChats();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}

/// 채팅방 목록 Provider
final chatListProvider =
    StateNotifierProvider.autoDispose<ChatListNotifier, AsyncValue<List<Chat>>>(
        (ref) {
  final chatService = ref.watch(chatServiceProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return ChatListNotifier(chatService, webSocketService, ref);
});

/// 친구 그룹 채팅 목록 Provider (팀 그룹 채팅 제외)
final friendGroupChatsProvider =
    FutureProvider.autoDispose<List<Chat>>((ref) async {
  final service = ref.watch(chatServiceProvider);
  final result = await service.getFriendGroupChats();

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

    final latestMessageId = state.messages.isNotEmpty

        ? (state.messages.first.id is int

            ? state.messages.first.id as int

            : int.tryParse(state.messages.first.id.toString()))

        : null;



    if (latestMessageId != null) {

      _webSocketService.markAsRead(chatId, messageId: latestMessageId);

    }

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



  // 메시지 목록 Notifier가 생성될 때 현재 채팅방 ID를 설정

  // ref.read(currentChatIdProvider.notifier).state = chatId;



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
    if (!mounted) return null;
    state = const ChatActionState(isLoading: true);

    final result = await _service.getOrCreateDirectChat(targetAgoraId);

    return result.when(
      success: (chat) {
        if (!mounted) return chat;
        state = const ChatActionState();
        _ref.read(chatListProvider.notifier).invalidate();
        return chat;
      },
      failure: (error) {
        if (!mounted) return null;
        state = ChatActionState(error: error.displayMessage);
        return null;
      },
    );
  }

  /// 메시지 삭제
  Future<bool> deleteMessage(String chatId, String messageId) async {
    if (!mounted) return false;
    state = const ChatActionState(isLoading: true);

    final result = await _service.deleteMessage(chatId, messageId);

    return result.when(
      success: (_) {
        if (!mounted) return true;
        state = const ChatActionState();
        return true;
      },
      failure: (error) {
        if (!mounted) return false;
        state = ChatActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  void clearError() {
    if (!mounted) return;
    state = const ChatActionState();
  }

  // ==========================================
  //               그룹 채팅 관련 기능
  // ==========================================

  /// 그룹 채팅방 생성
  /// [name]: 그룹 이름
  /// [memberIds]: 초대할 멤버 ID 목록 (User ID)
  /// [fileId]: (선택) 프로필 이미지 파일 ID
  Future<Chat?> createGroupChat({
    required String name,
    required List<int> memberIds,
    String? fileId,
  }) async {
    if (!mounted) return null;
    state = const ChatActionState(isLoading: true);

    final result = await _service.createGroupChat(
      name: name,
      memberIds: memberIds,
      fileId: fileId,
    );

    return result.when(
      success: (chat) {
        if (!mounted) return chat;
        state = const ChatActionState();
        // 채팅 목록 새로고침
        _ref.read(chatListProvider.notifier).invalidate();
        return chat;
      },
      failure: (error) {
        if (!mounted) return null;
        state = ChatActionState(error: error.displayMessage);
        return null;
      },
    );
  }

  /// 그룹 채팅방 멤버 초대
  Future<bool> inviteToGroupChat(String chatId, List<int> memberIds) async {
    if (!mounted) return false;
    state = const ChatActionState(isLoading: true);

    final result = await _service.inviteToGroupChat(chatId, memberIds);

    return result.when(
      success: (_) {
        if (!mounted) return true;
        state = const ChatActionState();
        // 채팅 목록 새로고침 (참여자 수 변경 등 반영)
        _ref.read(chatListProvider.notifier).invalidate();
        return true;
      },
      failure: (error) {
        if (!mounted) return false;
        state = ChatActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  /// 그룹 채팅방 나가기
  Future<bool> leaveGroupChat(String chatId) async {
    if (!mounted) return false;
    state = const ChatActionState(isLoading: true);

    final result = await _service.leaveGroupChat(chatId);

    return result.when(
      success: (_) {
        if (!mounted) return true;
        state = const ChatActionState();
        // 채팅 목록 새로고침 (목록에서 제거)
        _ref.read(chatListProvider.notifier).invalidate();
        return true;
      },
      failure: (error) {
        if (!mounted) return false;
        state = ChatActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  /// 그룹 채팅방 멤버 강퇴 (방장 전용)
  Future<bool> removeMemberFromGroupChat(String chatId, String userId) async {
    if (!mounted) return false;
    state = const ChatActionState(isLoading: true);

    final result = await _service.removeMemberFromGroupChat(chatId, userId);

    return result.when(
      success: (_) {
        if (!mounted) return true;
        state = const ChatActionState();
        return true;
      },
      failure: (error) {
        if (!mounted) return false;
        state = ChatActionState(error: error.displayMessage);
        return false;
      },
    );
  }
}

/// 채팅 작업 Provider
final chatActionProvider =
    StateNotifierProvider.autoDispose<ChatActionNotifier, ChatActionState>((ref) {
  final service = ref.watch(chatServiceProvider);
  return ChatActionNotifier(service, ref);
});

