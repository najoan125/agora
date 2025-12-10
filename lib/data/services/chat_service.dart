import 'package:dio/dio.dart';
import '../api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/exception/app_exception.dart';
import '../models/chat/chat.dart';

/// 채팅 REST API 서비스
class ChatService {
  final ApiClient _apiClient;

  ChatService([ApiClient? apiClient]) : _apiClient = apiClient ?? ApiClient();

  /// 채팅방 목록 조회
  Future<Result<List<Chat>>> getChats({
    int page = 0,
    int size = 20,
    ChatType? type,
    String? folderId,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.chats,
        queryParameters: {
          'page': page,
          'size': size,
          if (type != null) 'type': type.name.toUpperCase(),
          if (folderId != null) 'folderId': folderId,
        },
      );
      final List<dynamic> data = response.data is List ? response.data : [];
      final chats = data.map((json) => Chat.fromJson(json)).toList();
      return Success(chats);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 1:1 채팅방 생성 또는 조회
  Future<Result<Chat>> getOrCreateDirectChat(String targetAgoraId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.chats,
        data: {'targetAgoraId': targetAgoraId},
      );
      return Success(Chat.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 채팅방 상세 조회
  Future<Result<Chat>> getChatById(String chatId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.chatById(chatId));
      return Success(Chat.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 채팅방 참여자 조회 (채팅 목록에서 정보가 부족할 때 사용)
  Future<Result<List<ParticipantProfile>>> getChatParticipants(String chatId) async {
    try {
      // API 문서에 명시된 참여자 조회 API가 없으므로, 채팅방 상세 조회를 통해 가져옴
      // 만약 별도의 /api/agora/chats/{chatId}/participants API가 있다면 그것을 사용해야 함
      final response = await _apiClient.get(ApiEndpoints.chatById(chatId));
      final chat = Chat.fromJson(response.data);
      return Success(chat.participants ?? []);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 메시지 목록 조회 (커서 페이지네이션)
  Future<Result<MessageListResponse>> getMessages(
    String chatId, {
    String? cursorId,
    int limit = 20,
    String direction = 'before',
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.chatMessages(chatId),
        queryParameters: {
          if (cursorId != null) 'cursorId': cursorId,
          'limit': limit,
          'direction': direction,
        },
      );

      // 서버가 배열을 직접 반환하는 경우 처리
      if (response.data is List) {
        final messages = (response.data as List)
            .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
            .toList();
        return Success(MessageListResponse(
          content: messages,
          hasNext: false,
          nextCursor: null,
        ));
      }

      return Success(MessageListResponse.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 메시지 전송 (REST fallback - WebSocket 사용 권장)
  Future<Result<ChatMessage>> sendMessage(
    String chatId, {
    required String content,
    MessageType type = MessageType.text,
    String? replyToId,
    List<String>? fileIds,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.chatMessages(chatId),
        data: {
          'content': content,
          'type': type.name.toUpperCase(),
          if (replyToId != null) 'replyToId': replyToId,
          if (fileIds != null) 'fileIds': fileIds,
        },
      );
      return Success(ChatMessage.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 메시지 삭제
  Future<Result<void>> deleteMessage(String chatId, String messageId) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.chatMessageDelete(chatId, messageId),
      );
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 메시지 읽음 처리
  Future<Result<void>> markAsRead(String chatId) async {
    try {
      await _apiClient.put(ApiEndpoints.chatRead(chatId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  // ============ Context 기반 1:1 채팅 API (신규) ============

  /// Context 기반 1:1 채팅 생성/조회
  ///
  /// [targetUserId] 대상 사용자 ID
  /// [context] 채팅 컨텍스트 ('FRIEND' 또는 'TEAM')
  /// [teamId] 팀 ID (TEAM 컨텍스트 시 필수)
  Future<Result<Chat>> createDirectChat({
    required int targetUserId,
    required String context,
    int? teamId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.chatsDirect,
        data: {
          'targetUserId': targetUserId,
          'context': context,
          if (teamId != null) 'teamId': teamId,
        },
      );
      return Success(Chat.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// Context별 1:1 채팅 목록 조회
  ///
  /// [context] 채팅 컨텍스트 ('FRIEND' 또는 'TEAM')
  Future<Result<List<Chat>>> getDirectChats(String context) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.chatsDirect,
        queryParameters: {'context': context},
      );
      final List<dynamic> data = response.data is List ? response.data : [];
      final chats = data.map((json) => Chat.fromJson(json)).toList();
      return Success(chats);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  // ============ 그룹 채팅 관리 API (Group Chat) ============

  /// 친구 그룹 채팅 목록 조회 (팀 그룹 채팅 제외)
  ///
  /// GET /api/agora/chats/group
  Future<Result<List<Chat>>> getFriendGroupChats() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.groupChat);
      final List<dynamic> data = response.data is List ? response.data : [];
      final chats = data.map((json) => Chat.fromJson(json)).toList();
      return Success(chats);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 그룹 채팅방 생성
  ///
  /// [name] 채팅방 이름
  /// [memberIds] 초대할 멤버들의 ID (Agora ID 아님, User ID 목록)
  /// [fileId] 프로필 이미지 파일 ID (선택)
  Future<Result<Chat>> createGroupChat({
    required String name,
    required List<int> memberIds,
    String? fileId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.groupChats,
        data: {
          'name': name,
          'memberIds': memberIds,
          if (fileId != null) 'fileId': fileId,
        },
      );
      return Success(Chat.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 그룹 채팅방 멤버 초대
  Future<Result<void>> inviteToGroupChat(String chatId, List<int> memberIds) async {
    try {
      await _apiClient.post(
        ApiEndpoints.groupChatMembers(chatId),
        data: {'memberIds': memberIds},
      );
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 그룹 채팅방 멤버 강퇴 (방장 권한)
  Future<Result<void>> removeMemberFromGroupChat(String chatId, String userId) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.groupChatMemberRemove(chatId, userId),
      );
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 그룹 채팅방 나가기
  Future<Result<void>> leaveGroupChat(String chatId) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.groupChatLeave(chatId),
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
