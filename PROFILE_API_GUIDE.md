# Agora Profile API 연동 가이드

## 📁 생성된 파일 목록

### 1. 모델 (Models)
- `lib/data/models/agora_profile_response.dart` - 프로필 응답 모델
- `lib/data/models/create_agora_profile_request.dart` - 프로필 생성 요청 모델
- `lib/data/models/update_agora_profile_request.dart` - 프로필 수정 요청 모델

### 2. 서비스 (Service)
- `lib/data/profile_service.dart` - 프로필 API 통신 서비스

### 3. 상태 관리 (Provider)
- `lib/shared/providers/profile_provider.dart` - 프로필 상태 관리

### 4. 화면 (Screens)
- `lib/features/profile/screens/create_profile_screen.dart` - 프로필 생성 화면
- `lib/features/profile/screens/edit_agora_profile_screen.dart` - 프로필 수정 화면
- `lib/features/profile/screens/view_agora_profile_screen.dart` - 프로필 조회 화면 (예시)

## 🚀 사용 방법

### 1. 패키지 설치

```bash
flutter pub get
```

### 2. 프로필 조회

```dart
import 'package:provider/provider.dart';
import 'package:agora/shared/providers/profile_provider.dart';

// 프로필 불러오기
final provider = context.read<ProfileProvider>();
await provider.loadMyProfile();

// 프로필 데이터 사용
final profile = provider.myProfile;
if (profile != null) {
  print('Agora ID: ${profile.agoraId}');
  print('표시 이름: ${profile.displayName}');
  print('상태 메시지: ${profile.statusMessage}');
}
```

### 3. 프로필 생성

```dart
final provider = context.read<ProfileProvider>();

final success = await provider.createProfile(
  agoraId: 'myagoraid',
  displayName: '내 이름',
  statusMessage: '안녕하세요!',
);

if (success) {
  print('프로필 생성 성공!');
} else {
  print('에러: ${provider.error}');
}
```

### 4. 프로필 수정

```dart
final provider = context.read<ProfileProvider>();

final success = await provider.updateProfile(
  displayName: '새로운 이름',
  statusMessage: '새로운 상태 메시지',
);

if (success) {
  print('프로필 수정 성공!');
}
```

### 5. 프로필 이미지 업로드

```dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';

final picker = ImagePicker();
final XFile? image = await picker.pickImage(source: ImageSource.gallery);

if (image != null) {
  final provider = context.read<ProfileProvider>();
  final success = await provider.updateProfileImage(File(image.path));
  
  if (success) {
    print('이미지 업로드 성공!');
  }
}
```

### 6. Agora ID 중복 확인

```dart
final provider = context.read<ProfileProvider>();
final available = await provider.checkAgoraIdAvailable('testid');

if (available) {
  print('사용 가능한 ID입니다.');
} else {
  print('이미 사용 중인 ID입니다.');
}
```

### 7. 사용자 검색

```dart
final provider = context.read<ProfileProvider>();

// Agora ID로 검색
final users = await provider.searchUsers(agoraId: 'searchid');

// 표시 이름으로 검색
final users2 = await provider.searchUsers(displayName: '홍길동');

for (var user in users) {
  print('${user.displayName} (@${user.agoraId})');
}
```

### 8. 다른 사용자 프로필 조회

```dart
final provider = context.read<ProfileProvider>();
final userProfile = await provider.getUserProfile('otheruserid');

if (userProfile != null) {
  print('사용자: ${userProfile.displayName}');
}
```

## 🎨 UI에서 사용하기

### Consumer로 실시간 상태 반영

```dart
Consumer<ProfileProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (provider.error != null) {
      return Text('에러: ${provider.error}');
    }
    
    final profile = provider.myProfile;
    if (profile == null) {
      return Text('프로필이 없습니다.');
    }
    
    return Column(
      children: [
        Text(profile.displayName),
        Text('@${profile.agoraId}'),
        if (profile.statusMessage != null)
          Text(profile.statusMessage!),
      ],
    );
  },
)
```

## 📡 API 엔드포인트

서버 API와 매핑된 엔드포인트:

- `GET /api/agora/profile` - 내 프로필 조회
- `POST /api/agora/profile` - 프로필 생성
- `PUT /api/agora/profile` - 프로필 수정
- `PUT /api/agora/profile/image` - 프로필 이미지 변경
- `GET /api/agora/profile/{agoraId}` - 다른 사용자 프로필 조회
- `GET /api/agora/profile/search` - 사용자 검색
- `GET /api/agora/profile/check-id` - Agora ID 중복 확인

## 🔧 서버 URL 설정

`lib/data/api_client.dart` 파일에서 서버 URL을 변경할 수 있습니다:

```dart
static const String baseUrl = 'http://localhost:8080';

// 안드로이드 에뮬레이터: http://10.0.2.2:8080
// 웹 브라우저: http://localhost:8080
// 실제 기기: http://192.168.x.x:8080 (PC IP 주소)
```

## ⚠️ 주의사항

1. **JWT 토큰**: API 호출 시 자동으로 JWT 토큰이 헤더에 추가됩니다.
2. **토큰 갱신**: 401/403 에러 발생 시 자동으로 토큰을 갱신합니다.
3. **에러 처리**: `provider.error`를 통해 에러 메시지를 확인할 수 있습니다.
4. **로딩 상태**: `provider.isLoading`으로 로딩 상태를 확인할 수 있습니다.

## 🎯 화면 네비게이션 예시

```dart
// 프로필 생성 화면으로 이동
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const CreateProfileScreen(),
  ),
);

// 프로필 수정 화면으로 이동
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const EditAgoraProfileScreen(),
  ),
);

// 프로필 조회 화면으로 이동
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ViewAgoraProfileScreen(),
  ),
);
```

## 📝 추가 구현 필요 사항

1. **이미지 캐싱**: 프로필 이미지 로딩 최적화
2. **오프라인 모드**: 네트워크 연결 없을 때 로컬 캐시 사용
3. **프로필 삭제**: 필요시 프로필 삭제 API 추가
4. **알림**: 프로필 변경 시 다른 사용자에게 알림

## 🐛 디버깅

로그 확인:
- `print` 문을 통해 API 호출 및 응답 확인
- `provider.error`로 에러 메시지 확인
- Dio 인터셉터에서 요청/응답 로그 출력

## 📚 참고

- [Provider 공식 문서](https://pub.dev/packages/provider)
- [Dio 공식 문서](https://pub.dev/packages/dio)
- [Image Picker 공식 문서](https://pub.dev/packages/image_picker)
