# Agora API 개요

## Base URL
```
https://api.hyfata.com
```

## 인증 방식

### OAuth 2.0 + PKCE

모든 Agora API는 OAuth 2.0 Bearer Token 기반 인증을 사용합니다.

**Header 형식:**
```
Authorization: Bearer {access_token}
```

**토큰 획득 흐름:**
1. 클라이언트에서 `code_verifier` 생성
2. `code_verifier`를 SHA256 해시 → `code_challenge` 생성
3. `/oauth/authorize?client_id=...&code_challenge=...` 요청
4. 사용자 로그인 → Authorization Code 반환
5. `/oauth/token`에서 Authorization Code + code_verifier 교환 → Access Token 획득

---

## 공통 응답 형식

### 성공 응답 (2xx)

**단일 객체:**
```json
{
  "id": 1,
  "email": "user@example.com",
  "createdAt": "2025-01-15T10:30:00"
}
```

**목록:**
```json
[
  {
    "id": 1,
    "title": "공지"
  },
  {
    "id": 2,
    "title": "공지2"
  }
]
```

**메시지만 반환:**
```json
{
  "message": "성공적으로 처리되었습니다"
}
```

### 에러 응답 (4xx, 5xx)

```json
{
  "error": "UNAUTHORIZED",
  "message": "인증 토큰이 유효하지 않습니다",
  "status": 401,
  "timestamp": "2025-01-15T10:30:00"
}
```

---

## 공통 에러 코드

| 상태 | 에러 | 설명 |
|------|------|------|
| 400 | BAD_REQUEST | 잘못된 요청 (필수 필드 누락 등) |
| 401 | UNAUTHORIZED | 인증 토큰 없음 또는 만료됨 |
| 403 | FORBIDDEN | 권한 없음 (관리자 권한 필요 등) |
| 404 | NOT_FOUND | 리소스를 찾을 수 없음 |
| 409 | CONFLICT | 중복된 리소스 (예: 이미 존재하는 친구) |
| 500 | INTERNAL_SERVER_ERROR | 서버 오류 |

---

## API 목록

### 계정 & 프로필
- **[AccountController](./01_ACCOUNT_API.md)** - 계정 관리 (비밀번호 변경, 계정 삭제 등)
- **[AgoraProfileController](./02_PROFILE_API.md)** - Agora 프로필 (생성, 조회, 수정, 검색)

### 파일
- **[AgoraFileController](./03_FILE_API.md)** - 파일 업로드/다운로드

### 친구
- **[AgoraFriendController](./04_FRIEND_API.md)** - 친구 관리 (요청, 수락, 차단, 즐겨찾기)

### 채팅 (REST)
- **[AgoraChatController](./05_CHAT_API.md)** - 1:1 채팅 (메시지 송수신)
- **[AgoraGroupChatController](./07_GROUP_CHAT_API.md)** - 그룹 채팅
- **[AgoraChatFolderController](./08_CHAT_FOLDER_API.md)** - 채팅 폴더 관리

### 채팅 (WebSocket)
- **[ChatWebSocketController](./06_WEBSOCKET_API.md)** - 실시간 채팅 (STOMP)

### 알림
- **[AgoraNotificationController](./09_NOTIFICATION_API.md)** - 알림 & FCM 토큰

### 팀
- **[AgoraTeamController](./10_TEAM_API.md)** - 팀 관리 (생성, 멤버 초대)
- **[AgoraTeamProfileController](./11_TEAM_PROFILE_API.md)** - 팀 프로필
- **[AgoraTeamNoticeController, AgoraTeamTodoController, AgoraTeamEventController](./12_TEAM_FEATURES_API.md)** - 공지/할일/일정

### 설정
- **[AgoraSettingsController](./13_SETTINGS_API.md)** - 사용자 설정 (알림, 개인정보)

---

## 페이지네이션

일부 API는 페이지네이션을 지원합니다.

**Query Parameters:**
```
?page=0&size=20&sort=createdAt,desc
```

**Response:**
```json
{
  "content": [ { "id": 1 }, { "id": 2 } ],
  "pageNumber": 0,
  "pageSize": 20,
  "totalElements": 100,
  "totalPages": 5
}
```

---

## 속도 제한 (Rate Limiting)

현재 속도 제한이 없습니다. 추후 변경될 수 있습니다.

---

## 버전 관리

현재 API 버전: **v1** (추후 v2 릴리스 예정)

---

## 문서 구조

- `01_ACCOUNT_API.md` - 계정 관리 API
- `02_PROFILE_API.md` - 프로필 API
- `03_FILE_API.md` - 파일 API
- `04_FRIEND_API.md` - 친구 관리 API
- `05_CHAT_API.md` - 1:1 채팅 API
- `06_WEBSOCKET_API.md` - WebSocket 실시간 채팅
- `07_GROUP_CHAT_API.md` - 그룹 채팅 API
- `08_CHAT_FOLDER_API.md` - 채팅 폴더 API
- `09_NOTIFICATION_API.md` - 알림 API
- `10_TEAM_API.md` - 팀 관리 API
- `11_TEAM_PROFILE_API.md` - 팀 프로필 API
- `12_TEAM_FEATURES_API.md` - 팀 부가 기능 (공지/할일/일정)
- `13_SETTINGS_API.md` - 설정 API
- `FLOW_AUTH.md` - OAuth 2.0 인증 흐름
- `FLOW_ONBOARDING.md` - 회원가입 흐름
- `FLOW_CHAT.md` - 채팅 흐름
- `FLOW_FRIEND.md` - 친구 추가 흐름
- `FLOW_TEAM.md` - 팀 생성 흐름
- `FLOW_NOTIFICATION.md` - 알림 수신 흐름

---

## 지원

문제가 발생하면 GitHub Issues에 보고해주세요.
