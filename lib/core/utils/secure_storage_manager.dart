import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 보안 저장소 관리자
/// flutter_secure_storage를 사용하여 민감한 데이터를 암호화하여 저장
class SecureStorageManager {
  SecureStorageManager._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // ============ Storage Keys ============
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyTokenExpiresAt = 'token_expires_at';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyAgoraId = 'agora_id';
  static const String _keyFcmToken = 'fcm_token';
  static const String _keyDeviceId = 'device_id';
  static const String _keyCodeVerifier = 'code_verifier';
  static const String _keyOAuthState = 'oauth_state';

  // ============ Token Management ============

  /// 토큰 저장
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    DateTime? expiresAt,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
    if (expiresAt != null) {
      await _storage.write(
        key: _keyTokenExpiresAt,
        value: expiresAt.toIso8601String(),
      );
    }
  }

  /// Access Token 가져오기
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  /// Refresh Token 가져오기
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  /// 토큰 만료 시간 가져오기
  static Future<DateTime?> getTokenExpiresAt() async {
    final expiresAtStr = await _storage.read(key: _keyTokenExpiresAt);
    if (expiresAtStr == null) return null;
    return DateTime.tryParse(expiresAtStr);
  }

  /// Access Token 유효성 검사 (5분 버퍼 포함)
  static Future<bool> isAccessTokenValid() async {
    final expiresAt = await getTokenExpiresAt();
    if (expiresAt == null) {
      // 만료 시간 정보 없으면 토큰 존재 여부만 확인
      final token = await getAccessToken();
      return token != null && token.isNotEmpty;
    }
    // 5분 전에 만료로 간주 (버퍼)
    final buffer = const Duration(minutes: 5);
    return DateTime.now().isBefore(expiresAt.subtract(buffer));
  }

  /// 토큰 갱신이 필요한지 확인
  static Future<bool> shouldRefreshToken() async {
    final expiresAt = await getTokenExpiresAt();
    if (expiresAt == null) return false;
    // 5분 전에 갱신 필요
    final buffer = const Duration(minutes: 5);
    return DateTime.now().isAfter(expiresAt.subtract(buffer));
  }

  // ============ User Info ============

  /// 사용자 정보 저장
  static Future<void> saveUserInfo({
    String? userId,
    String? email,
    String? agoraId,
  }) async {
    if (userId != null) {
      await _storage.write(key: _keyUserId, value: userId);
    }
    if (email != null) {
      await _storage.write(key: _keyUserEmail, value: email);
    }
    if (agoraId != null) {
      await _storage.write(key: _keyAgoraId, value: agoraId);
    }
  }

  /// 사용자 ID 가져오기
  static Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  /// 이메일 가져오기
  static Future<String?> getUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }

  /// Agora ID 가져오기
  static Future<String?> getAgoraId() async {
    return await _storage.read(key: _keyAgoraId);
  }

  // ============ FCM Token ============

  /// FCM 토큰 저장
  static Future<void> saveFcmToken(String token) async {
    await _storage.write(key: _keyFcmToken, value: token);
  }

  /// FCM 토큰 가져오기
  static Future<String?> getFcmToken() async {
    return await _storage.read(key: _keyFcmToken);
  }

  // ============ Device ID ============

  /// 디바이스 ID 저장
  static Future<void> saveDeviceId(String deviceId) async {
    await _storage.write(key: _keyDeviceId, value: deviceId);
  }

  /// 디바이스 ID 가져오기
  static Future<String?> getDeviceId() async {
    return await _storage.read(key: _keyDeviceId);
  }

  // ============ OAuth PKCE ============

  /// Code Verifier 저장 (OAuth PKCE용, 임시)
  static Future<void> saveCodeVerifier(String verifier) async {
    await _storage.write(key: _keyCodeVerifier, value: verifier);
  }

  /// Code Verifier 가져오기
  static Future<String?> getCodeVerifier() async {
    return await _storage.read(key: _keyCodeVerifier);
  }

  /// Code Verifier 삭제
  static Future<void> deleteCodeVerifier() async {
    await _storage.delete(key: _keyCodeVerifier);
  }

  /// OAuth State 저장 (CSRF 방지용)
  static Future<void> saveOAuthState(String state) async {
    await _storage.write(key: _keyOAuthState, value: state);
  }

  /// OAuth State 가져오기
  static Future<String?> getOAuthState() async {
    return await _storage.read(key: _keyOAuthState);
  }

  /// OAuth State 삭제
  static Future<void> deleteOAuthState() async {
    await _storage.delete(key: _keyOAuthState);
  }

  // ============ Session Management ============

  /// 세션 전체 저장
  static Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    DateTime? expiresAt,
    String? userId,
    String? email,
    String? agoraId,
  }) async {
    await saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
    await saveUserInfo(
      userId: userId,
      email: email,
      agoraId: agoraId,
    );
  }

  /// 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// 세션 전체 삭제 (로그아웃)
  static Future<void> clearSession() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyTokenExpiresAt);
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyUserEmail);
    await _storage.delete(key: _keyAgoraId);
    await _storage.delete(key: _keyCodeVerifier);
    await _storage.delete(key: _keyOAuthState);
    // FCM 토큰과 디바이스 ID는 유지 (재로그인 시 사용)
  }

  /// 모든 데이터 삭제
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// 저장된 모든 키 목록
  static Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }
}
