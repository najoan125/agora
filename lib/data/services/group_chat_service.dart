import 'package:dio/dio.dart';
import '../api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/exception/app_exception.dart';
import '../models/chat/chat.dart';
import '../models/chat/group_chat.dart';

/// 그룹 채팅 서비스
class GroupChatService {
  final ApiClient _apiClient;

  GroupChatService([ApiClient? apiClient])
      : _apiClient = apiClient ?? ApiClient();

  /// 그룹 채팅 생성
  Future<Result<Chat>> createGroupChat({
    required String name,
    required List<String> memberAgoraIds,
    String? profileImageUrl,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.groupChats,
        data: CreateGroupChatRequest(
          name: name,
          memberAgoraIds: memberAgoraIds,
          profileImageUrl: profileImageUrl,
        ).toJson(),
      );
      return Success(Chat.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 그룹 채팅 상세 조회
  Future<Result<GroupChatDetail>> getGroupChat(String groupId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.groupChatById(groupId),
      );
      return Success(GroupChatDetail.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 그룹 채팅 정보 수정
  Future<Result<Chat>> updateGroupChat(
    String groupId, {
    String? name,
    String? profileImageUrl,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.groupChatById(groupId),
        data: UpdateGroupChatRequest(
          name: name,
          profileImageUrl: profileImageUrl,
        ).toJson(),
      );
      return Success(Chat.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 그룹 채팅 삭제 (관리자만 가능)
  Future<Result<void>> deleteGroupChat(String groupId) async {
    try {
      await _apiClient.delete(ApiEndpoints.groupChatById(groupId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 그룹에 멤버 초대
  Future<Result<List<GroupMember>>> inviteMembers(
    String groupId,
    List<String> agoraIds,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.groupChatMembers(groupId),
        data: InviteGroupMembersRequest(agoraIds: agoraIds).toJson(),
      );
      final List<dynamic> membersJson = response.data;
      return Success(
        membersJson.map((json) => GroupMember.fromJson(json)).toList(),
      );
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 그룹에서 멤버 제거 (관리자만 가능)
  Future<Result<void>> removeMember(String groupId, String userId) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.groupChatMemberRemove(groupId, userId),
      );
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 그룹 채팅 나가기
  Future<Result<void>> leaveGroup(String groupId) async {
    try {
      await _apiClient.delete(ApiEndpoints.groupChatLeave(groupId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  // ============ 신규 Group Chat API ============

  /// 친구 그룹 채팅 생성 (신규 API)
  ///
  /// [name] 채팅방 이름
  /// [profileImage] 채팅방 이미지 URL (선택)
  /// [memberAgoraIds] 초대할 멤버 아고라 ID 목록 (memberUserIds와 둘 중 하나 필수)
  /// [memberUserIds] 초대할 멤버 사용자 ID 목록 (memberAgoraIds와 둘 중 하나 필수)
  Future<Result<Chat>> createGroupChatNew({
    required String name,
    String? profileImage,
    List<String>? memberAgoraIds,
    List<int>? memberUserIds,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.groupChat,
        data: {
          'name': name,
          if (profileImage != null) 'profileImage': profileImage,
          if (memberAgoraIds != null) 'memberAgoraIds': memberAgoraIds,
          if (memberUserIds != null) 'memberUserIds': memberUserIds,
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

  /// 그룹 채팅 목록 조회 (신규 API)
  ///
  /// 친구 그룹 채팅 목록만 조회 (팀 그룹 채팅 제외)
  Future<Result<List<Chat>>> getGroupChats() async {
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
}
