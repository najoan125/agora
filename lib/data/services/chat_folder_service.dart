import 'package:dio/dio.dart';
import '../api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/exception/app_exception.dart';
import '../models/chat/chat_folder.dart';

/// 채팅 폴더 서비스
class ChatFolderService {
  final ApiClient _apiClient;

  ChatFolderService([ApiClient? apiClient])
      : _apiClient = apiClient ?? ApiClient();

  /// 폴더 목록 조회
  Future<Result<List<ChatFolder>>> getFolders() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.chatFolders);
      final List<dynamic> foldersJson = response.data;
      return Success(
        foldersJson.map((json) => ChatFolder.fromJson(json)).toList(),
      );
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 폴더 생성
  Future<Result<ChatFolder>> createFolder({
    required String name,
    String? color,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.chatFolders,
        data: CreateChatFolderRequest(
          name: name,
          color: color,
        ).toJson(),
      );
      return Success(ChatFolder.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 폴더 수정
  Future<Result<ChatFolder>> updateFolder(
    String folderId, {
    String? name,
    String? color,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.chatFolderById(folderId),
        data: UpdateChatFolderRequest(
          name: name,
          color: color,
        ).toJson(),
      );
      return Success(ChatFolder.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 폴더 삭제
  Future<Result<void>> deleteFolder(String folderId) async {
    try {
      await _apiClient.delete(ApiEndpoints.chatFolderById(folderId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 채팅을 폴더에 추가
  Future<Result<void>> addChatToFolder(String chatId, String folderId) async {
    try {
      await _apiClient.post(ApiEndpoints.chatToFolder(chatId, folderId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 채팅을 폴더에서 제거
  Future<Result<void>> removeChatFromFolder(
      String chatId, String folderId) async {
    try {
      await _apiClient.delete(ApiEndpoints.chatToFolder(chatId, folderId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }
}
