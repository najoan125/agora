import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/agora_profile_response.dart';
import '../../data/models/create_agora_profile_request.dart';
import '../../data/models/update_agora_profile_request.dart';
import '../../data/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService;
  
  AgoraProfileResponse? _myProfile;
  bool _isLoading = false;
  String? _error;

  AgoraProfileResponse? get myProfile => _myProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProfileProvider(this._profileService);

  /// 내 프로필 불러오기
  Future<void> loadMyProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myProfile = await _profileService.getMyProfile();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('❌ Load profile error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 프로필 생성
  Future<bool> createProfile({
    required String agoraId,
    required String displayName,
    String? statusMessage,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = CreateAgoraProfileRequest(
        agoraId: agoraId,
        displayName: displayName,
        statusMessage: statusMessage,
      );
      _myProfile = await _profileService.createProfile(request);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print('❌ Create profile error: $e');
      return false;
    }
  }

  /// 프로필 수정
  Future<bool> updateProfile({
    String? displayName,
    String? statusMessage,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = UpdateAgoraProfileRequest(
        displayName: displayName,
        statusMessage: statusMessage,
      );
      _myProfile = await _profileService.updateProfile(request);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print('❌ Update profile error: $e');
      return false;
    }
  }

  /// 프로필 이미지 변경
  Future<bool> updateProfileImage(File imageFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _profileService.updateProfileImage(imageFile);
      // 이미지 업데이트 후 프로필 다시 불러오기
      await loadMyProfile();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print('❌ Update profile image error: $e');
      return false;
    }
  }

  /// 다른 사용자 프로필 조회
  Future<AgoraProfileResponse?> getUserProfile(String agoraId) async {
    try {
      return await _profileService.getUserProfile(agoraId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print('❌ Get user profile error: $e');
      return null;
    }
  }

  /// 사용자 검색
  Future<List<AgoraProfileResponse>> searchUsers({
    String? agoraId,
    String? displayName,
  }) async {
    try {
      return await _profileService.searchUsers(
        agoraId: agoraId,
        displayName: displayName,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print('❌ Search users error: $e');
      return [];
    }
  }

  /// agoraId 중복 확인
  Future<bool> checkAgoraIdAvailable(String agoraId) async {
    try {
      return await _profileService.checkAgoraIdAvailable(agoraId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print('❌ Check agoraId error: $e');
      return false;
    }
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
