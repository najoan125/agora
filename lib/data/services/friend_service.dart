import 'package:dio/dio.dart';
import '../api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/exception/app_exception.dart';
import '../models/friend/friend.dart';
import '../models/friend/friend_request.dart';
import '../models/friend/blocked_user.dart';

/// 친구 관리 서비스
class FriendService {
  final ApiClient _apiClient;

  FriendService([ApiClient? apiClient]) : _apiClient = apiClient ?? ApiClient();

  /// 친구 목록 조회
  Future<Result<List<Friend>>> getFriends({
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.friends,
        queryParameters: {
          'page': page,
          'size': size,
          if (sort != null) 'sort': sort,
        },
      );
      // 서버가 배열을 직접 반환
      final List<dynamic> data = response.data is List ? response.data : [];
      final friends = data.map((json) => Friend.fromJson(json)).toList();
      return Success(friends);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 친구 요청 보내기
  Future<Result<void>> sendFriendRequest(String targetAgoraId) async {
    try {
      await _apiClient.post(
        ApiEndpoints.friendRequest,
        data: {'agoraId': targetAgoraId},
      );
      return const Success(null);
    } on DioException catch (e) {
      final appException =
          e.requestOptions.extra['appException'] as AppException?;
      if (e.response?.statusCode == 409) {
        return Failure(AppException.conflict(
          message: 'Already friends or request pending',
          userMessage: '이미 친구이거나 요청이 대기 중입니다.',
          error: e,
        ));
      }
      return Failure(appException ?? AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 받은 친구 요청 목록
  Future<Result<List<FriendRequest>>> getReceivedRequests({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.friendRequests,
        queryParameters: {'page': page, 'size': size},
      );
      // 서버가 배열을 직접 반환
      final List<dynamic> data = response.data is List ? response.data : [];
      final requests = data.map((json) => FriendRequest.fromJson(json)).toList();
      return Success(requests);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 친구 요청 수락
  Future<Result<void>> acceptFriendRequest(String requestId) async {
    try {
      await _apiClient.post(ApiEndpoints.friendRequestAccept(requestId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 친구 요청 거절
  Future<Result<void>> rejectFriendRequest(String requestId) async {
    try {
      await _apiClient.delete(ApiEndpoints.friendRequestReject(requestId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 친구 삭제
  Future<Result<void>> deleteFriend(String friendId) async {
    try {
      await _apiClient.delete(ApiEndpoints.friendDelete(friendId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 즐겨찾기 추가
  Future<Result<void>> addToFavorites(String friendId) async {
    try {
      await _apiClient.post(ApiEndpoints.friendFavorite(friendId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 즐겨찾기 제거
  Future<Result<void>> removeFromFavorites(String friendId) async {
    try {
      await _apiClient.delete(ApiEndpoints.friendFavorite(friendId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 사용자 차단
  Future<Result<void>> blockUser(String friendId) async {
    try {
      await _apiClient.post(ApiEndpoints.friendBlock(friendId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 차단 해제
  Future<Result<void>> unblockUser(String friendId) async {
    try {
      await _apiClient.delete(ApiEndpoints.friendBlock(friendId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 차단 목록 조회
  Future<Result<List<BlockedUser>>> getBlockedUsers({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.friendsBlocked,
        queryParameters: {'page': page, 'size': size},
      );
      // 서버가 배열을 직접 반환
      final List<dynamic> data = response.data is List ? response.data : [];
      final users = data.map((json) => BlockedUser.fromJson(json)).toList();
      return Success(users);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 다가오는 생일 목록 (7일 이내)
  Future<Result<List<Friend>>> getUpcomingBirthdays() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.friendsBirthdays);
      final List<dynamic> data = response.data;
      final friends = data.map((json) => Friend.fromJson(json)).toList();
      return Success(friends);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }
}
