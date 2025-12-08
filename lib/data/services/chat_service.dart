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
      print('>>> getChats response: ${response.data}');
      // 서버가 배열을 직접 반환
      final List<dynamic> data = response.data is List ? response.data : [];
      final chats = data.map((json) => Chat.fromJson(json)).toList();
      return Success(chats);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      print('>>> getChats parsing error: $e');
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
      print('>>> getOrCreateDirectChat response: ${response.data}');
      return Success(Chat.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      print('>>> getOrCreateDirectChat parsing error: $e');
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
      print('>>> getMessages response: ${response.data}');

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
      print('>>> getMessages parsing error: $e');
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
}
