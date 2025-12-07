# Agora Profile API 문서

**작성일:** 2025-12-03
**버전:** 1.0

---

## 개요

Agora 프로필 관리 API는 사용자의 Agora 앱 전용 프로필을 생성, 조회, 수정하는 기능을 제공합니다.

### 기본 정보
- **Base URL:** `/api/agora/profile`
- **인증:** Bearer Token (JWT Access Token)
- **Content-Type:** `application/json`

---

## 엔드포인트

### 1. 내 Agora 프로필 조회

**요청**
```
GET /api/agora/profile
Authorization: Bearer {access_token}
```

**응답 (200 OK - 프로필 존재)**
```json
{
  "agoraId": "user123",
  "displayName": "홍길동",
  "profileImage": "https://example.com/image.jpg",
  "bio": "안녕하세요",
  "phone": "010-1234-5678",
  "birthday": "1990-01-01",
  "createdAt": "2025-12-03T10:30:00",
  "updatedAt": "2025-12-03T10:30:00"
}
```

**응답 (200 OK - 프로필 미존재)**
```json
{
  "message": "Agora profile not found. Please create a profile first.",
  "hasProfile": false
}
```

---

### 2. Agora 프로필 생성

**요청**
```
POST /api/agora/profile
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "agoraId": "user123",
  "displayName": "홍길동",
  "profileImage": "https://example.com/image.jpg",
  "bio": "안녕하세요",
  "phone": "010-1234-5678",
  "birthday": "1990-01-01"
}
```

**필드 설명**

| 필드 | 타입 | 필수 | 제약 조건 | 설명 |
|------|------|------|---------|------|
| agoraId | string | O | 3-50자, `[a-zA-Z0-9_]` | 고유한 사용자 ID |
| displayName | string | O | 1-100자 | 표시되는 사용자명 |
| profileImage | string | X | URL | 프로필 이미지 URL |
| bio | string | X | 무제한 | 자기소개 |
| phone | string | X | 20자 이하 | 전화번호 |
| birthday | date | X | YYYY-MM-DD | 생일 |

**응답 (200 OK)**
```json
{
  "agoraId": "user123",
  "displayName": "홍길동",
  "profileImage": "https://example.com/image.jpg",
  "bio": "안녕하세요",
  "phone": "010-1234-5678",
  "birthday": "1990-01-01",
  "createdAt": "2025-12-03T10:30:00",
  "updatedAt": "2025-12-03T10:30:00"
}
```

**에러 응답**

| 상태 | 메시지 | 원인 |
|------|--------|------|
| 400 | `agoraId is required` | agoraId 누락 |
| 400 | `displayName is required` | displayName 누락 |
| 400 | `agoraId must be between 3 and 50 characters` | agoraId 길이 초과 |
| 400 | `agoraId can only contain letters, numbers, and underscores` | agoraId 형식 오류 |
| 409 | `agoraId already taken` | 중복된 agoraId |
| 409 | `Agora profile already exists` | 이미 프로필이 존재 |
| 401 | `Unauthorized` | 인증 토큰 없음/만료 |

---

### 3. Agora 프로필 수정

**요청**
```
PUT /api/agora/profile
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "agoraId": "new_user_id",
  "displayName": "새이름",
  "profileImage": "https://example.com/new-image.jpg",
  "bio": "새 소개글",
  "phone": "010-9876-5432",
  "birthday": "1995-05-15"
}
```

**주의:** 변경할 필드만 전송하면 됩니다. 빈 필드는 무시됩니다.

**응답 (200 OK)**
```json
{
  "agoraId": "user123",
  "displayName": "새이름",
  "profileImage": "https://example.com/new-image.jpg",
  "bio": "새 소개글",
  "phone": "010-9876-5432",
  "birthday": "1995-05-15",
  "createdAt": "2025-12-03T10:30:00",
  "updatedAt": "2025-12-03T11:45:00"
}
```

**에러 응답**

| 상태 | 메시지 | 원인 |
|------|--------|------|
| 404 | `Agora profile not found. Please create a profile first.` | 프로필이 없음 |
| 400 | `agoraId must be between 3 and 50 characters` | agoraId 길이 오류 |
| 400 | `agoraId can only contain letters, numbers, and underscores` | agoraId 형식 오류 |
| 400 | `displayName must be between 1 and 100 characters` | displayName 길이 초과 |
| 409 | `agoraId already taken` | 중복된 agoraId |
| 401 | `Unauthorized` | 인증 토큰 없음/만료 |

---

## 상태 코드

| 코드 | 의미 |
|------|------|
| 200 | 성공 |
| 400 | 잘못된 요청 (유효성 검사 실패) |
| 401 | 인증 실패 |
| 404 | 리소스 없음 |
| 409 | 충돌 (중복된 agoraId 등) |
| 500 | 서버 오류 |

---

## Flutter 구현 예시

### 1. 모델 정의

```dart
class AgoraProfile {
  final String agoraId;
  final String displayName;
  final String? profileImage;
  final String? bio;
  final String? phone;
  final DateTime? birthday;
  final DateTime createdAt;
  final DateTime updatedAt;

  AgoraProfile({
    required this.agoraId,
    required this.displayName,
    this.profileImage,
    this.bio,
    this.phone,
    this.birthday,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AgoraProfile.fromJson(Map<String, dynamic> json) {
    return AgoraProfile(
      agoraId: json['agoraId'],
      displayName: json['displayName'],
      profileImage: json['profileImage'],
      bio: json['bio'],
      phone: json['phone'],
      birthday: json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'agoraId': agoraId,
    'displayName': displayName,
    'profileImage': profileImage,
    'bio': bio,
    'phone': phone,
    'birthday': birthday?.toIso8601String().split('T')[0],
  };
}
```

### 2. API 서비스

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class AgoraProfileService {
  final String baseUrl = 'https://api.example.com/api/agora/profile';
  final String accessToken; // JWT token

  AgoraProfileService({required this.accessToken});

  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  // 내 프로필 조회
  Future<AgoraProfile?> getMyProfile() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        // hasProfile이 false면 null 반환
        if (json['hasProfile'] == false) {
          return null;
        }

        return AgoraProfile.fromJson(json);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('토큰이 만료되었습니다');
      } else {
        throw Exception('프로필 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 프로필 생성
  Future<AgoraProfile> createProfile({
    required String agoraId,
    required String displayName,
    String? profileImage,
    String? bio,
    String? phone,
    DateTime? birthday,
  }) async {
    try {
      final body = {
        'agoraId': agoraId,
        'displayName': displayName,
        if (profileImage != null) 'profileImage': profileImage,
        if (bio != null) 'bio': bio,
        if (phone != null) 'phone': phone,
        if (birthday != null) 'birthday': birthday.toIso8601String().split('T')[0],
      };

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _headers(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return AgoraProfile.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 409) {
        throw DuplicateAgoraIdException('이미 사용 중인 agoraId입니다');
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw ValidationException(error['message'] ?? '유효하지 않은 입력');
      } else {
        throw Exception('프로필 생성 실패: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 프로필 수정
  Future<AgoraProfile> updateProfile({
    String? agoraId,
    String? displayName,
    String? profileImage,
    String? bio,
    String? phone,
    DateTime? birthday,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (agoraId != null) body['agoraId'] = agoraId;
      if (displayName != null) body['displayName'] = displayName;
      if (profileImage != null) body['profileImage'] = profileImage;
      if (bio != null) body['bio'] = bio;
      if (phone != null) body['phone'] = phone;
      if (birthday != null) body['birthday'] = birthday.toIso8601String().split('T')[0];

      final response = await http.put(
        Uri.parse(baseUrl),
        headers: _headers(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return AgoraProfile.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw ProfileNotFoundException('프로필이 존재하지 않습니다');
      } else if (response.statusCode == 409) {
        throw DuplicateAgoraIdException('이미 사용 중인 agoraId입니다');
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw ValidationException(error['message'] ?? '유효하지 않은 입력');
      } else {
        throw Exception('프로필 수정 실패: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
```

### 3. 예외 클래스

```dart
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => message;
}

class DuplicateAgoraIdException implements Exception {
  final String message;
  DuplicateAgoraIdException(this.message);

  @override
  String toString() => message;
}

class ProfileNotFoundException implements Exception {
  final String message;
  ProfileNotFoundException(this.message);

  @override
  String toString() => message;
}
```

### 4. UI 사용 예시

```dart
class ProfileSetupScreen extends StatefulWidget {
  final String accessToken;

  const ProfileSetupScreen({required this.accessToken});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  late AgoraProfileService _service;
  final _agoraIdController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _service = AgoraProfileService(accessToken: widget.accessToken);
  }

  Future<void> _createProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _service.createProfile(
        agoraId: _agoraIdController.text,
        displayName: _displayNameController.text,
        bio: _bioController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로필이 생성되었습니다!')),
        );
        Navigator.pop(context, profile);
      }
    } on DuplicateAgoraIdException catch (e) {
      setState(() => _errorMessage = e.toString());
    } on ValidationException catch (e) {
      setState(() => _errorMessage = e.toString());
    } catch (e) {
      setState(() => _errorMessage = '오류: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('프로필 설정')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _agoraIdController,
              decoration: InputDecoration(
                labelText: 'Agora ID (3-50자, 영문/숫자/_만 허용)',
                errorText: _errorMessage?.contains('agoraId') ?? false
                    ? _errorMessage
                    : null,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _displayNameController,
              decoration: InputDecoration(labelText: '이름'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(labelText: '자기소개'),
              maxLines: 3,
            ),
            SizedBox(height: 24),
            if (_errorMessage != null)
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ElevatedButton(
              onPressed: _isLoading ? null : _createProfile,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('프로필 생성'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _agoraIdController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
```

---

## 주의사항

1. **agoraId 변경 가능**: PUT 요청으로 agoraId를 변경할 수 있습니다. 단, 중복된 agoraId는 사용할 수 없습니다.
2. **토큰 만료**: 401 에러 발생 시 토큰을 갱신하고 재시도해야 합니다.
3. **부분 업데이트**: PUT 요청 시 변경할 필드만 포함하면, 다른 필드는 유지됩니다.
4. **날짜 포맷**: birthday는 `YYYY-MM-DD` 형식을 사용합니다.
