import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/profile_service.dart';
import '../../data/api_client.dart';
import '../../data/models/agora_profile_response.dart';
import '../../data/models/create_agora_profile_request.dart';
import '../../data/models/update_agora_profile_request.dart';
import '../../core/exception/app_exception.dart';

/// Profile 서비스 Provider
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(ApiClient());
});

/// 내 프로필 Provider (FutureProvider)
final myProfileProvider = FutureProvider.autoDispose<AgoraProfileResponse?>((ref) async {
  final service = ref.watch(profileServiceProvider);
  try {
    return await service.getMyProfile();
  } catch (e) {
    // 프로필이 없는 경우 null 반환
    if (e.toString().contains('404') || e.toString().contains('not found')) {
      return null;
    }
    rethrow;
  }
});

/// 다른 사용자 프로필 Provider
final userProfileProvider = FutureProvider.autoDispose.family<AgoraProfileResponse?, String>((ref, agoraId) async {
  final service = ref.watch(profileServiceProvider);
  try {
    return await service.getUserProfile(agoraId);
  } catch (e) {
    return null;
  }
});

/// 프로필 액션 상태
class ProfileActionState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const ProfileActionState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });
}

/// 프로필 액션 Notifier (생성, 수정 등)
class ProfileActionNotifier extends StateNotifier<ProfileActionState> {
  final ProfileService _service;
  final Ref _ref;

  ProfileActionNotifier(this._service, this._ref) : super(const ProfileActionState());

  /// 프로필 생성
  Future<AgoraProfileResponse?> createProfile({
    required String agoraId,
    required String displayName,
    String? bio,
    String? phone,
    String? birthday,
  }) async {
    state = const ProfileActionState(isLoading: true);

    try {
      final request = CreateAgoraProfileRequest(
        agoraId: agoraId,
        displayName: displayName,
        bio: bio,
        phone: phone,
        birthday: birthday,
      );
      final result = await _service.createProfile(request);
      state = const ProfileActionState(successMessage: '프로필이 생성되었습니다.');
      _ref.invalidate(myProfileProvider);
      return result;
    } catch (e) {
      state = ProfileActionState(error: e.toString());
      return null;
    }
  }

  /// 프로필 수정
  Future<bool> updateProfile({
    String? agoraId,
    String? displayName,
    String? bio,
    String? phone,
    String? birthday,
  }) async {
    state = const ProfileActionState(isLoading: true);

    try {
      final request = UpdateAgoraProfileRequest(
        agoraId: agoraId,
        displayName: displayName,
        bio: bio,
        phone: phone,
        birthday: birthday,
      );
      await _service.updateProfile(request);
      state = const ProfileActionState(successMessage: '프로필이 수정되었습니다.');
      _ref.invalidate(myProfileProvider);
      return true;
    } catch (e) {
      state = ProfileActionState(error: e.toString());
      return false;
    }
  }

  /// 프로필 이미지 업데이트
  Future<bool> updateProfileImage(File imageFile) async {
    state = const ProfileActionState(isLoading: true);

    try {
      await _service.updateProfileImage(imageFile);
      state = const ProfileActionState(successMessage: '프로필 이미지가 수정되었습니다.');
      _ref.invalidate(myProfileProvider);
      return true;
    } catch (e) {
      state = ProfileActionState(error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = const ProfileActionState();
  }
}

/// 프로필 액션 Provider
final profileActionProvider = StateNotifierProvider<ProfileActionNotifier, ProfileActionState>((ref) {
  final service = ref.watch(profileServiceProvider);
  return ProfileActionNotifier(service, ref);
});

/// 사용자 검색 Provider
final userSearchProvider = FutureProvider.autoDispose.family<List<AgoraProfileResponse>, String>((ref, keyword) async {
  if (keyword.isEmpty) return [];

  final service = ref.watch(profileServiceProvider);
  try {
    return await service.searchUsers(keyword: keyword);
  } catch (e) {
    return [];
  }
});

/// agoraId 사용 가능 여부 확인 Provider
final agoraIdAvailableProvider = FutureProvider.autoDispose.family<bool, String>((ref, agoraId) async {
  if (agoraId.isEmpty) return false;

  final service = ref.watch(profileServiceProvider);
  try {
    return await service.checkAgoraIdAvailable(agoraId);
  } catch (e) {
    return false;
  }
});
