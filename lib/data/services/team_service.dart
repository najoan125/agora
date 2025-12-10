import 'package:dio/dio.dart';
import '../api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/exception/app_exception.dart';
import '../models/team/team.dart';
import '../models/chat/chat.dart';

/// 팀 관리 서비스
class TeamService {
  final ApiClient _apiClient;

  TeamService([ApiClient? apiClient]) : _apiClient = apiClient ?? ApiClient();

  // ============ Team CRUD ============

  /// 팀 목록 조회
  Future<Result<List<Team>>> getTeams({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.teams,
        queryParameters: {'page': page, 'size': size},
      );
      // 서버가 배열을 직접 반환
      final List<dynamic> data = response.data is List ? response.data : [];
      final teams = data.map((json) => Team.fromJson(json)).toList();
      return Success(teams);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 팀 생성
  Future<Result<Team>> createTeam({
    required String name,
    String? description,
    String? profileImage,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.teams,
        data: {
          'name': name,
          if (description != null) 'description': description,
          if (profileImage != null) 'profileImage': profileImage,
        },
      );
      return Success(Team.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 팀 상세 조회
  Future<Result<Team>> getTeamById(String teamId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.teamById(teamId));
      return Success(Team.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 팀 수정
  Future<Result<Team>> updateTeam(
    String teamId, {
    String? name,
    String? description,
    String? profileImage,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (name != null) queryParams['name'] = name;
      if (description != null) queryParams['description'] = description;
      if (profileImage != null) queryParams['profileImage'] = profileImage;

      final response = await _apiClient.put(
        ApiEndpoints.teamById(teamId),
        queryParameters: queryParams,
      );
      return Success(Team.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 팀 삭제
  Future<Result<void>> deleteTeam(String teamId) async {
    try {
      await _apiClient.delete(ApiEndpoints.teamById(teamId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  // ============ Team Members ============

  /// 팀 멤버 목록 조회
  Future<Result<List<TeamMember>>> getTeamMembers(String teamId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.teamMembers(teamId));
      final List<dynamic> data = response.data;
      final members = data.map((json) => TeamMember.fromJson(json)).toList();
      return Success(members);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 팀 멤버 초대 (초대 전송)
  Future<Result<TeamInvitation>> inviteMember(String teamId, String agoraId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.teamInvitations(teamId),
        data: {'agoraId': agoraId},
      );
      return Success(TeamInvitation.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 팀 멤버 제거
  Future<Result<void>> removeMember(String teamId, String memberId) async {
    try {
      await _apiClient.delete(ApiEndpoints.teamMemberRemove(teamId, memberId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 팀 멤버 역할 변경
  Future<Result<void>> changeMemberRole(
    String teamId,
    String memberId,
    TeamRole role,
  ) async {
    try {
      await _apiClient.put(
        ApiEndpoints.teamMemberRole(teamId, memberId),
        queryParameters: {'roleName': role.name.toUpperCase()},
      );
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  // ============ Team Profile ============

  /// 내 팀 프로필 조회
  Future<Result<TeamProfile>> getMyTeamProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.teamProfile);
      return Success(TeamProfile.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 팀 프로필 존재 여부 확인
  Future<Result<bool>> checkTeamProfileExists() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.teamProfileExists);
      return Success(response.data['exists'] == true);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 팀 프로필 생성
  Future<Result<TeamProfile>> createTeamProfile({
    required String displayName,
    String? profileImage,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.teamProfile,
        data: {
          'displayName': displayName,
          if (profileImage != null) 'profileImage': profileImage,
        },
      );
      return Success(TeamProfile.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 팀 프로필 수정
  Future<Result<TeamProfile>> updateTeamProfile({
    String? displayName,
    String? profileImage,
    String? bio,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (displayName != null) queryParams['displayName'] = displayName;
      if (profileImage != null) queryParams['profileImage'] = profileImage;
      if (bio != null) queryParams['bio'] = bio;

      final response = await _apiClient.put(
        ApiEndpoints.teamProfile,
        queryParameters: queryParams,
      );
      return Success(TeamProfile.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 다른 사용자의 팀 프로필 조회
  Future<Result<TeamProfile>> getTeamProfileByUserId(String userId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.teamProfileByUserId(userId));
      return Success(TeamProfile.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  // ============ Notices ============

  /// 공지 목록 조회
  Future<Result<List<Notice>>> getNotices(String teamId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.teamNotices(teamId));
      // API가 배열을 직접 반환
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['content'] ?? []);
      final notices = data.map((json) => Notice.fromJson(json)).toList();
      return Success(notices);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 공지 생성
  Future<Result<Notice>> createNotice(
    String teamId, {
    required String title,
    required String content,
    bool isPinned = false,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.teamNotices(teamId),
        data: {
          'title': title,
          'content': content,
          'isPinned': isPinned,
        },
      );
      return Success(Notice.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 공지 삭제
  Future<Result<void>> deleteNotice(String teamId, String noticeId) async {
    try {
      await _apiClient.delete(ApiEndpoints.teamNoticeById(teamId, noticeId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  // ============ Todos ============

  /// 할일 목록 조회
  Future<Result<List<Todo>>> getTodos(String teamId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.teamTodos(teamId));
      final List<dynamic> data = response.data['content'] ?? response.data;
      final todos = data.map((json) => Todo.fromJson(json)).toList();
      return Success(todos);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 할일 생성
  Future<Result<Todo>> createTodo(
    String teamId, {
    required String title,
    String? description,
    TodoPriority priority = TodoPriority.medium,
    String? assignedToId,
    DateTime? dueDate,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.teamTodos(teamId),
        data: {
          'title': title,
          if (description != null) 'description': description,
          'priority': priority.name.toUpperCase(),
          if (assignedToId != null) 'assignedToId': assignedToId,
          if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
        },
      );
      return Success(Todo.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 할일 완료 처리
  Future<Result<Todo>> completeTodo(String teamId, String todoId) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.teamTodoComplete(teamId, todoId),
      );
      return Success(Todo.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 할일 삭제
  Future<Result<void>> deleteTodo(String teamId, String todoId) async {
    try {
      await _apiClient.delete(ApiEndpoints.teamTodoById(teamId, todoId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  // ============ Events ============

  /// 이벤트 목록 조회
  Future<Result<List<Event>>> getEvents(String teamId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.teamEvents(teamId));
      final List<dynamic> data = response.data['content'] ?? response.data;
      final events = data.map((json) => Event.fromJson(json)).toList();
      return Success(events);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 이벤트 생성
  Future<Result<Event>> createEvent(
    String teamId, {
    required String title,
    String? description,
    String? location,
    required DateTime startTime,
    required DateTime endTime,
    bool isAllDay = false,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.teamEvents(teamId),
        data: {
          'title': title,
          if (description != null) 'description': description,
          if (location != null) 'location': location,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'isAllDay': isAllDay,
        },
      );
      return Success(Event.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 이벤트 삭제
  Future<Result<void>> deleteEvent(String teamId, String eventId) async {
    try {
      await _apiClient.delete(ApiEndpoints.teamEventById(teamId, eventId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  // ============ Team Invitations ============

  /// 받은 초대 목록 조회
  Future<Result<List<TeamInvitation>>> getReceivedInvitations() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.teamInvitationsReceived);
      final List<dynamic> data = response.data;
      final invitations = data.map((json) => TeamInvitation.fromJson(json)).toList();
      return Success(invitations);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 보낸 초대 목록 조회
  Future<Result<List<TeamInvitation>>> getSentInvitations(String teamId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.teamInvitations(teamId));
      final List<dynamic> data = response.data;
      final invitations = data.map((json) => TeamInvitation.fromJson(json)).toList();
      return Success(invitations);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 초대 수락
  Future<Result<TeamInvitation>> acceptInvitation(String invitationId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.teamInvitationAccept(invitationId),
      );
      return Success(TeamInvitation.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 초대 거절
  Future<Result<TeamInvitation>> rejectInvitation(String invitationId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.teamInvitationReject(invitationId),
      );
      return Success(TeamInvitation.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 팀 그룹 채팅 조회
  Future<Result<Chat>> getTeamChat(String teamId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.teamChat(teamId));
      return Success(Chat.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }
}
