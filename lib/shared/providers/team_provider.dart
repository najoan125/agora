import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/team_service.dart';
import '../../data/models/team/team.dart';

/// Team 서비스 Provider
final teamServiceProvider = Provider<TeamService>((ref) {
  return TeamService();
});

/// 팀 목록 Provider
final teamListProvider = FutureProvider.autoDispose<List<Team>>((ref) async {
  final service = ref.watch(teamServiceProvider);
  final result = await service.getTeams();

  return result.when(
    success: (teams) => teams,
    failure: (error) => throw error,
  );
});

/// 특정 팀 Provider
final teamByIdProvider =
    FutureProvider.autoDispose.family<Team, String>((ref, teamId) async {
  final service = ref.watch(teamServiceProvider);
  final result = await service.getTeamById(teamId);

  return result.when(
    success: (team) => team,
    failure: (error) => throw error,
  );
});

/// 팀 멤버 목록 Provider
final teamMembersProvider =
    FutureProvider.autoDispose.family<List<TeamMember>, String>((ref, teamId) async {
  final service = ref.watch(teamServiceProvider);
  final result = await service.getTeamMembers(teamId);

  return result.when(
    success: (members) => members,
    failure: (error) => throw error,
  );
});

/// 팀 공지 목록 Provider
final teamNoticesProvider =
    FutureProvider.autoDispose.family<List<Notice>, String>((ref, teamId) async {
  final service = ref.watch(teamServiceProvider);
  final result = await service.getNotices(teamId);

  return result.when(
    success: (notices) => notices,
    failure: (error) => throw error,
  );
});

/// 팀 할일 목록 Provider
final teamTodosProvider =
    FutureProvider.autoDispose.family<List<Todo>, String>((ref, teamId) async {
  final service = ref.watch(teamServiceProvider);
  final result = await service.getTodos(teamId);

  return result.when(
    success: (todos) => todos,
    failure: (error) => throw error,
  );
});

/// 팀 이벤트 목록 Provider
final teamEventsProvider =
    FutureProvider.autoDispose.family<List<Event>, String>((ref, teamId) async {
  final service = ref.watch(teamServiceProvider);
  final result = await service.getEvents(teamId);

  return result.when(
    success: (events) => events,
    failure: (error) => throw error,
  );
});

/// 내 팀 프로필 Provider (사용자당 하나의 팀 프로필)
final myTeamProfileProvider =
    FutureProvider.autoDispose<TeamProfile?>((ref) async {
  final service = ref.watch(teamServiceProvider);
  final result = await service.getMyTeamProfile();

  return result.when(
    success: (profile) => profile,
    failure: (error) {
      // 팀 프로필이 없는 경우 null 반환 (400 PROFILE_NOT_FOUND)
      if (error.statusCode == 400 || error.statusCode == 404) {
        return null;
      }
      throw error;
    },
  );
});

/// 팀 프로필 존재 여부 Provider
final teamProfileExistsProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  final service = ref.watch(teamServiceProvider);
  final result = await service.checkTeamProfileExists();

  return result.when(
    success: (exists) => exists,
    failure: (error) => false,
  );
});

/// 팀 작업 상태
class TeamActionState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const TeamActionState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });
}

/// 팀 작업 Notifier
class TeamActionNotifier extends StateNotifier<TeamActionState> {
  final TeamService _service;
  final Ref _ref;

  TeamActionNotifier(this._service, this._ref)
      : super(const TeamActionState());

  /// 팀 생성
  Future<Team?> createTeam({
    required String name,
    String? description,
  }) async {
    state = const TeamActionState(isLoading: true);

    final result = await _service.createTeam(
      name: name,
      description: description,
    );

    return result.when(
      success: (team) {
        state = const TeamActionState(successMessage: '팀이 생성되었습니다.');
        _ref.invalidate(teamListProvider);
        return team;
      },
      failure: (error) {
        state = TeamActionState(error: error.displayMessage);
        return null;
      },
    );
  }

  /// 팀 삭제
  Future<bool> deleteTeam(String teamId) async {
    state = const TeamActionState(isLoading: true);

    final result = await _service.deleteTeam(teamId);

    return result.when(
      success: (_) {
        state = const TeamActionState();
        _ref.invalidate(teamListProvider);
        return true;
      },
      failure: (error) {
        state = TeamActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  /// 멤버 초대
  Future<bool> inviteMember(String teamId, String userEmail) async {
    state = const TeamActionState(isLoading: true);

    final result = await _service.inviteMember(teamId, userEmail);

    return result.when(
      success: (_) {
        state = const TeamActionState(successMessage: '초대를 보냈습니다.');
        _ref.invalidate(teamMembersProvider(teamId));
        return true;
      },
      failure: (error) {
        state = TeamActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  /// 할일 완료
  Future<bool> completeTodo(String teamId, String todoId) async {
    state = const TeamActionState(isLoading: true);

    final result = await _service.completeTodo(teamId, todoId);

    return result.when(
      success: (_) {
        state = const TeamActionState();
        _ref.invalidate(teamTodosProvider(teamId));
        return true;
      },
      failure: (error) {
        state = TeamActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  void clearError() {
    state = const TeamActionState();
  }

  void clearSuccessMessage() {
    state = const TeamActionState();
  }
}

/// 팀 작업 Provider
final teamActionProvider =
    StateNotifierProvider<TeamActionNotifier, TeamActionState>((ref) {
  final service = ref.watch(teamServiceProvider);
  return TeamActionNotifier(service, ref);
});

// ============ Team Invitations ============

/// 받은 팀 초대 목록 Provider
final teamInvitationsProvider =
    FutureProvider.autoDispose<List<TeamInvitation>>((ref) async {
  final service = ref.watch(teamServiceProvider);
  final result = await service.getReceivedInvitations();

  return result.when(
    success: (invitations) =>
        invitations.where((inv) => inv.isPending).toList(),
    failure: (error) => throw error,
  );
});

/// 팀 초대 작업 상태
class TeamInvitationActionState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const TeamInvitationActionState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });
}

/// 팀 초대 작업 Notifier
class TeamInvitationActionNotifier
    extends StateNotifier<TeamInvitationActionState> {
  final TeamService _service;
  final Ref _ref;

  TeamInvitationActionNotifier(this._service, this._ref)
      : super(const TeamInvitationActionState());

  /// 팀 초대 수락
  Future<bool> acceptInvitation(String invitationId) async {
    state = const TeamInvitationActionState(isLoading: true);

    final result = await _service.acceptInvitation(invitationId);

    return result.when(
      success: (invitation) {
        state = TeamInvitationActionState(
          successMessage: '${invitation.teamName} 팀에 가입했습니다.',
        );
        _ref.invalidate(teamInvitationsProvider);
        _ref.invalidate(teamListProvider);
        return true;
      },
      failure: (error) {
        state = TeamInvitationActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  /// 팀 초대 거절
  Future<bool> rejectInvitation(String invitationId) async {
    state = const TeamInvitationActionState(isLoading: true);

    final result = await _service.rejectInvitation(invitationId);

    return result.when(
      success: (_) {
        state = const TeamInvitationActionState(
          successMessage: '초대를 거절했습니다.',
        );
        _ref.invalidate(teamInvitationsProvider);
        return true;
      },
      failure: (error) {
        state = TeamInvitationActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  void clearError() {
    state = const TeamInvitationActionState();
  }

  void clearSuccessMessage() {
    state = const TeamInvitationActionState();
  }
}

/// 팀 초대 작업 Provider
final teamInvitationActionProvider =
    StateNotifierProvider<TeamInvitationActionNotifier, TeamInvitationActionState>(
        (ref) {
  final service = ref.watch(teamServiceProvider);
  return TeamInvitationActionNotifier(service, ref);
});
