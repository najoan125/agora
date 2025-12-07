# Flutter Secure Storage 사용법

## 개요

flutter_secure_storage를 사용한 암호화된 토큰 저장소

---

## iOS 설정

### ios/Podfile

```ruby
# Uncomment this line to define a global platform for your project
platform :ios, '12.0'

target 'Runner' do
  flutter_root = File.expand_path(File.join(packages_path, 'flutter'))
  load File.join(flutter_root, 'packages', 'flutter_tools', 'bin', 'podhelper.rb')

  flutter_macos_pod_file_setup

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      flutter_post_install(installer)
      target.build_configurations.each do |config|
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
          '$(inherited)',
          'PERMISSION_CAMERA=1',
        ]
      end
    end
  end
end
```

### ios/Runner/Info.plist

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>앱이 로컬 네트워크에 접근하기 위해 권한이 필요합니다</string>

<key>NSBonjourServiceTypes</key>
<array>
    <string>_http._tcp</string>
    <string>_https._tcp</string>
</array>
```

---

## Android 설정

### android/app/build.gradle

```gradle
android {
    compileSdk 34
    ndkVersion "25.1.8937393"

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_11
        targetCompatibility JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = '11'
    }
}
```

### android/app/src/main/AndroidManifest.xml

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.USE_CREDENTIALS" />
<uses-permission android:name="android.permission.GET_ACCOUNTS" />
```

---

## Secure Storage Wrapper 클래스

### lib/core/utils/secure_storage_manager.dart

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agora_app/core/utils/logger.dart';

class SecureStorageManager {
  // 저장 키들
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _agoraIdKey = 'agora_id';
  static const String _fcmTokenKey = 'fcm_token';
  static const String _deviceIdKey = 'device_id';

  // 플랫폼별 옵션
  static final _storage = FlutterSecureStorage(
    aOptions: _androidOptions,
    iOptions: _iOSOptions,
  );

  // Android 옵션
  static const AndroidOptions _androidOptions = AndroidOptions(
    keyEncryptionAlgorithm: KeyEncryptionAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
    storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    resetOnError: true,
  );

  // iOS 옵션
  static const IOSOptions _iOSOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_available_when_unlocked_this_device_only,
  );

  /// 모든 항목 삭제
  static Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      AppLogger.debug('All items deleted from secure storage');
    } catch (e) {
      AppLogger.error('Error deleting all items', error: e);
      rethrow;
    }
  }

  /// 특정 항목 삭제
  static Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
      AppLogger.debug('Item deleted: $key');
    } catch (e) {
      AppLogger.error('Error deleting item: $key', error: e);
      rethrow;
    }
  }

  // ============ Access Token ============

  /// Access Token 저장
  static Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
      AppLogger.debug('Access token saved');
    } catch (e) {
      AppLogger.error('Failed to save access token', error: e);
      rethrow;
    }
  }

  /// Access Token 조회
  static Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      AppLogger.error('Failed to read access token', error: e);
      return null;
    }
  }

  /// Access Token 삭제
  static Future<void> deleteAccessToken() async {
    await delete(_accessTokenKey);
  }

  // ============ Refresh Token ============

  /// Refresh Token 저장
  static Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
      AppLogger.debug('Refresh token saved');
    } catch (e) {
      AppLogger.error('Failed to save refresh token', error: e);
      rethrow;
    }
  }

  /// Refresh Token 조회
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      AppLogger.error('Failed to read refresh token', error: e);
      return null;
    }
  }

  /// Refresh Token 삭제
  static Future<void> deleteRefreshToken() async {
    await delete(_refreshTokenKey);
  }

  // ============ User Info ============

  /// 사용자 정보 저장
  static Future<void> saveUserInfo({
    required String userId,
    required String email,
    required String agoraId,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _userIdKey, value: userId),
        _storage.write(key: _userEmailKey, value: email),
        _storage.write(key: _agoraIdKey, value: agoraId),
      ]);
      AppLogger.debug('User info saved');
    } catch (e) {
      AppLogger.error('Failed to save user info', error: e);
      rethrow;
    }
  }

  /// User ID 조회
  static Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      AppLogger.error('Failed to read user ID', error: e);
      return null;
    }
  }

  /// User Email 조회
  static Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _userEmailKey);
    } catch (e) {
      AppLogger.error('Failed to read user email', error: e);
      return null;
    }
  }

  /// Agora ID 조회
  static Future<String?> getAgoraId() async {
    try {
      return await _storage.read(key: _agoraIdKey);
    } catch (e) {
      AppLogger.error('Failed to read agora ID', error: e);
      return null;
    }
  }

  // ============ FCM Token ============

  /// FCM Token 저장
  static Future<void> saveFcmToken(String token) async {
    try {
      await _storage.write(key: _fcmTokenKey, value: token);
      AppLogger.debug('FCM token saved');
    } catch (e) {
      AppLogger.error('Failed to save FCM token', error: e);
      rethrow;
    }
  }

  /// FCM Token 조회
  static Future<String?> getFcmToken() async {
    try {
      return await _storage.read(key: _fcmTokenKey);
    } catch (e) {
      AppLogger.error('Failed to read FCM token', error: e);
      return null;
    }
  }

  /// FCM Token 삭제
  static Future<void> deleteFcmToken() async {
    await delete(_fcmTokenKey);
  }

  // ============ Device ID ============

  /// Device ID 저장
  static Future<void> saveDeviceId(String deviceId) async {
    try {
      await _storage.write(key: _deviceIdKey, value: deviceId);
      AppLogger.debug('Device ID saved');
    } catch (e) {
      AppLogger.error('Failed to save device ID', error: e);
      rethrow;
    }
  }

  /// Device ID 조회
  static Future<String?> getDeviceId() async {
    try {
      return await _storage.read(key: _deviceIdKey);
    } catch (e) {
      AppLogger.error('Failed to read device ID', error: e);
      return null;
    }
  }

  // ============ Bulk Operations ============

  /// 토큰과 사용자 정보 한번에 저장
  static Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String email,
    required String agoraId,
  }) async {
    try {
      await Future.wait([
        saveAccessToken(accessToken),
        saveRefreshToken(refreshToken),
        saveUserInfo(userId: userId, email: email, agoraId: agoraId),
      ]);
      AppLogger.info('Session saved');
    } catch (e) {
      AppLogger.error('Failed to save session', error: e);
      rethrow;
    }
  }

  /// 세션 정보 한번에 삭제 (로그아웃)
  static Future<void> clearSession() async {
    try {
      await Future.wait([
        deleteAccessToken(),
        deleteRefreshToken(),
        delete(_userIdKey),
        delete(_userEmailKey),
        delete(_agoraIdKey),
      ]);
      AppLogger.info('Session cleared');
    } catch (e) {
      AppLogger.error('Failed to clear session', error: e);
      rethrow;
    }
  }

  /// 로그인 여부 확인
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 저장된 모든 키 조회 (디버깅용)
  static Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      AppLogger.error('Failed to read all items', error: e);
      return {};
    }
  }
}

// Riverpod Provider
final secureStorageProvider = Provider((ref) => SecureStorageManager());
```

---

## 사용 예제

### 로그인 후 저장

```dart
final response = await authApi.tokenExchange(code, verifier);

await SecureStorageManager.saveSession(
  accessToken: response['accessToken'],
  refreshToken: response['refreshToken'],
  userId: response['userId'],
  email: response['email'],
  agoraId: response['agoraId'],
);
```

### 토큰 사용

```dart
class ApiInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorageManager.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }
}
```

### 로그아웃

```dart
await SecureStorageManager.clearSession();
Navigator.pushReplacementNamed(context, '/login');
```

---

## 보안 체크리스트

- [x] 암호화된 저장소 사용 (Keychain/Keystore)
- [x] 민감한 정보만 저장 (토큰, 사용자ID)
- [x] 로그아웃 시 전부 삭제
- [x] 에러 처리 (저장소 접근 불가)
- [x] 플랫폼별 최적 옵션 설정
- [x] 로깅에서 민감 정보 제외

---

## 문제 해결

### iOS에서 "Cannot create instance of flutter_secure_storage"

```bash
cd ios
pod deintegrate
pod install
cd ..
```

### Android에서 암호화 오류

```gradle
// android/app/build.gradle
dependencies {
    implementation 'androidx.security:security-crypto:1.1.0-alpha06'
}
```

---

## 다음 단계

- FLUTTER_AUTO_LOGIN.md - 자동 로그인 구현
- FLUTTER_LOGOUT.md - 로그아웃 처리
