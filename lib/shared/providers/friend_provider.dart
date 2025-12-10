import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/friend_service.dart';
import '../../data/models/friend/friend.dart';
import '../../data/models/friend/friend_request.dart';
import '../../data/models/friend/blocked_user.dart';

/// Friend 서비스 Provider
final friendServiceProvider = Provider<FriendService>((ref) {
  return FriendService();
});

/// 친구 목록 Provider
final friendListProvider =
    FutureProvider.autoDispose<List<Friend>>((ref) async {
  final service = ref.watch(friendServiceProvider);
  final result = await service.getFriends();

  return result.when(
    success: (friends) => friends,
    failure: (error) => throw error,
  );
});

/// 받은 친구 요청 목록 Provider
final friendRequestsProvider =
    FutureProvider.autoDispose<List<FriendRequest>>((ref) async {
  final service = ref.watch(friendServiceProvider);
  final result = await service.getReceivedRequests();

  return result.when(
    success: (requests) => requests,
    failure: (error) => throw error,
  );
});

/// 차단 사용자 목록 Provider
final blockedUsersProvider =
    FutureProvider.autoDispose<List<BlockedUser>>((ref) async {
  final service = ref.watch(friendServiceProvider);
  final result = await service.getBlockedUsers();

  return result.when(
    success: (users) => users,
    failure: (error) => throw error,
  );
});

/// 다가오는 생일 목록 Provider
final upcomingBirthdaysProvider =
    FutureProvider.autoDispose<List<Friend>>((ref) async {
  final service = ref.watch(friendServiceProvider);
  final result = await service.getUpcomingBirthdays();

  return result.when(
    success: (friends) => friends,
    failure: (error) => throw error,
  );
});

/// 친구 작업 상태
class FriendActionState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const FriendActionState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  FriendActionState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return FriendActionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// 친구 작업 Notifier
class FriendActionNotifier extends StateNotifier<FriendActionState> {
  final FriendService _service;
  final Ref _ref;

  FriendActionNotifier(this._service, this._ref)
      : super(const FriendActionState());

  /// 친구 요청 보내기
  Future<bool> sendFriendRequest(String targetAgoraId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _service.sendFriendRequest(targetAgoraId);

    return result.when(
      success: (_) {
        state = state.copyWith(
          isLoading: false,
          successMessage: '친구 요청을 보냈습니다.',
        );
        return true;
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, error: error.displayMessage);
        return false;
      },
    );
  }

  /// 친구 요청 수락
  Future<bool> acceptFriendRequest(String requestId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _service.acceptFriendRequest(requestId);

    return result.when(
      success: (_) {
        state = state.copyWith(
          isLoading: false,
          successMessage: '친구가 되었습니다!',
        );
        // 목록 새로고침
        _ref.invalidate(friendListProvider);
        _ref.invalidate(friendRequestsProvider);
        return true;
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, error: error.displayMessage);
        return false;
      },
    );
  }

  /// 친구 요청 거절
  Future<bool> rejectFriendRequest(String requestId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _service.rejectFriendRequest(requestId);

    return result.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
        _ref.invalidate(friendRequestsProvider);
        return true;
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, error: error.displayMessage);
        return false;
      },
    );
  }

  /// 친구 삭제
  Future<bool> deleteFriend(String friendId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _service.deleteFriend(friendId);

    return result.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
        _ref.invalidate(friendListProvider);
        return true;
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, error: error.displayMessage);
        return false;
      },
    );
  }

  /// 즐겨찾기 토글
  Future<bool> toggleFavorite(String friendId, bool isFavorite) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = isFavorite
        ? await _service.removeFromFavorites(friendId)
        : await _service.addToFavorites(friendId);

    return result.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
        _ref.invalidate(friendListProvider);
        return true;
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, error: error.displayMessage);
        return false;
      },
    );
  }

  /// 사용자 차단
  Future<bool> blockUser(String friendId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _service.blockUser(friendId);

    return result.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
        _ref.invalidate(friendListProvider);
        _ref.invalidate(blockedUsersProvider);
        return true;
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, error: error.displayMessage);
        return false;
      },
    );
  }

  /// 차단 해제
  Future<bool> unblockUser(String friendId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _service.unblockUser(friendId);

    return result.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
        _ref.invalidate(blockedUsersProvider);
        return true;
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, error: error.displayMessage);
        return false;
      },
    );
  }

  /// 에러 초기화
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 성공 메시지 초기화
  void clearSuccessMessage() {
    state = state.copyWith(successMessage: null);
  }
}

/// 친구 작업 Provider
final friendActionProvider =
    StateNotifierProvider<FriendActionNotifier, FriendActionState>((ref) {
  final service = ref.watch(friendServiceProvider);
  return FriendActionNotifier(service, ref);
});
