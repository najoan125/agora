# CLAUDE.md

## Project Overview

**Agora** - Flutter 기반 멀티플랫폼 메신저 앱 (Android, iOS, Web, Linux, macOS, Windows)

- Flutter 3.x / Dart SDK 3.0+
- Material Design 3
- Riverpod 상태 관리
- OAuth 2.0 + PKCE 인증
- STOMP WebSocket 실시간 채팅

## API Documentation

**중요: `docs/agora/api/` 디렉토리에 백엔드 API 문서가 있습니다.**

### API 문서 구조
| 문서 | 설명 |
|------|------|
| `00_OVERVIEW.md` | API 개요, 인증, 공통 응답 형식 |
| `01_ACCOUNT_API.md` | 계정 관리 |
| `02_PROFILE_API.md` | 프로필 CRUD |
| `03_FILE_API.md` | 파일 업로드/다운로드 |
| `04_FRIEND_API.md` | 친구 관리 |
| `05_CHAT_API.md` | 1:1 채팅 REST API |
| `06_WEBSOCKET_API.md` | 실시간 채팅 (STOMP) |
| `07_GROUP_CHAT_API.md` | 그룹 채팅 |
| `08_CHAT_FOLDER_API.md` | 채팅 폴더 |
| `09_NOTIFICATION_API.md` | 알림 & FCM |
| `10_TEAM_API.md` | 팀 관리 |
| `11_TEAM_PROFILE_API.md` | 팀 프로필 |
| `12_TEAM_FEATURES_API.md` | 팀 공지/할일/일정 |
| `13_SETTINGS_API.md` | 사용자 설정 |

### Flow 문서
- `FLOW_AUTH.md` - OAuth 2.0 인증 흐름
- `FLOW_ONBOARDING.md` - 회원가입 흐름
- `FLOW_CHAT.md` - 채팅 흐름
- `FLOW_FRIEND.md` - 친구 추가 흐름
- `FLOW_TEAM.md` - 팀 생성 흐름

### Flutter 구현 가이드
- `FLUTTER_SETUP.md` - 프로젝트 설정
- `FLUTTER_AUTH.md` - OAuth 인증 구현
- `FLUTTER_API_CLIENT.md` - API 클라이언트
- `FLUTTER_WEBSOCKET.md` - WebSocket 구현
- `FLUTTER_STATE_MANAGEMENT.md` - Riverpod 상태 관리
- `FLUTTER_FILE_UPLOAD.md` - 파일 업로드
- `FLUTTER_FCM.md` - FCM 푸시 알림

## Project Structure

```
lib/
├── main.dart                 # 앱 진입점
├── core/
│   ├── constants/           # API endpoints, 상수
│   ├── exception/           # 앱 예외 처리
│   ├── utils/               # PKCE, SecureStorage 등
│   └── theme.dart           # Material 3 테마
├── data/
│   ├── api_client.dart      # Dio 기반 API 클라이언트
│   ├── auth_service.dart    # 인증 서비스
│   ├── models/              # 데이터 모델 (freezed/json_serializable)
│   └── services/            # 각 기능별 API 서비스
├── features/
│   ├── auth/                # 로그인/회원가입
│   ├── chat/                # 채팅 화면
│   ├── friends/             # 친구 목록
│   ├── home/                # 홈 화면
│   ├── profile/             # 프로필
│   ├── settings/            # 설정
│   └── teams/               # 팀
├── services/
│   ├── websocket_service.dart  # STOMP WebSocket
│   └── oauth_service.dart      # OAuth 2.0 + PKCE
├── shared/
│   └── providers/           # Riverpod providers
└── utils/
```

## Development Commands

```bash
# 의존성 설치
flutter pub get

# 코드 생성 (freezed, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# 실행
flutter run
flutter run -d linux  # Linux

# 빌드
flutter build apk
flutter build web

# 코드 품질
flutter analyze
dart format lib/
```

## Key Technologies

| 영역 | 패키지 |
|------|--------|
| 상태 관리 | `flutter_riverpod`, `riverpod_annotation` |
| 네트워킹 | `dio` |
| 모델 생성 | `freezed`, `json_serializable` |
| WebSocket | `stomp_dart_client` |
| 인증 | `flutter_secure_storage`, `app_links` |
| 알림 | `flutter_local_notifications` |

## Configuration

- **API Base URL**: `lib/core/constants/api_endpoints.dart`
- **OAuth Config**: `lib/core/constants/api_endpoints.dart` (OAuthConfig class)
- **Theme**: `lib/core/theme.dart`