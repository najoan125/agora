# 🚀 Hyfata API - 라우트별 구현 가이드

**작성일:** 2025-12-01
**프로젝트:** Spring Boot REST API for Agora Messenger

---

## 📐 아키텍처 개요

### 프로필 계층 구조
```
User (계정)
  └── AgoraUserProfile (Agora 앱 프로필)
        └── TeamProfile (팀별 프로필)
```

- **User**: 기본 계정 정보 (email, password, username, firstName, lastName)
- **AgoraUserProfile**: Agora 앱 전용 프로필 (agoraId, displayName, profileImage, bio, phone, birthday)
- **TeamProfile**: 팀 내에서 사용하는 별도 프로필 (displayName, profileImage)

### API 구조
- `/api/account/*` - 계정 관리 (비밀번호, 보안 설정 등)
- `/api/agora/*` - Agora 앱 기능 (프로필, 친구, 채팅, 팀 등)

---

## 🔥 High Priority - 필수 구현

### `/api/account` - 계정 관리 (AccountController 생성 필요)

| 메서드 | 엔드포인트 | 설명 | 우선순위 | 상태 |
|--------|-----------|------|----------|------|
| PUT | `/api/account/password` | 비밀번호 변경 | ⭐⭐⭐ | ❌ |
| POST | `/api/account/deactivate` | 계정 비활성화 | ⭐ | ❌ |
| DELETE | `/api/account` | 계정 삭제 | ⭐ | ❌ |
| POST | `/api/account/restore` | 계정 복구 | ⭐ | ❌ |

**구현 파일:**
- `AccountController.java`
- `AccountService.java`
- `AccountServiceImpl.java`
- DTO: `ChangePasswordRequest.java`

---

### `/api/agora/profile` - Agora 프로필 관리 (AgoraProfileController 생성 필요)

| 메서드 | 엔드포인트 | 설명 | 우선순위 | 상태 |
|--------|-----------|------|----------|------|
| GET | `/api/agora/profile` | 내 Agora 프로필 조회 | ⭐⭐⭐ | ❌ |
| POST | `/api/agora/profile` | Agora 프로필 생성 (최초 설정) | ⭐⭐⭐ | ❌ |
| PUT | `/api/agora/profile` | Agora 프로필 수정 | ⭐⭐⭐ | ❌ |
| PUT | `/api/agora/profile/image` | 프로필 이미지 변경 | ⭐⭐ | ❌ |
| GET | `/api/agora/profile/{agoraId}` | 다른 사용자 프로필 조회 | ⭐⭐ | ❌ |
| GET | `/api/agora/profile/search` | 사용자 검색 (agoraId, displayName) | ⭐⭐ | ❌ |
| GET | `/api/agora/profile/check-id` | agoraId 중복 확인 | ⭐⭐ | ❌ |

**구현 파일:**
- `AgoraProfileController.java`
- `AgoraProfileService.java`
- `AgoraProfileServiceImpl.java`
- DTO: `AgoraProfileResponse.java`, `CreateAgoraProfileRequest.java`, `UpdateAgoraProfileRequest.java`

**엔티티 (기존):** `AgoraUserProfile.java`

---

### `/api/agora/friends` - 친구 관리 (AgoraFriendController 생성 필요)

| 메서드 | 엔드포인트 | 설명 | 우선순위 | 상태 |
|--------|-----------|------|----------|------|
| GET | `/api/agora/friends` | 친구 목록 | ⭐⭐⭐ | ❌ |
| POST | `/api/agora/friends/request` | 친구 요청 | ⭐⭐⭐ | ❌ |
| GET | `/api/agora/friends/requests` | 받은 친구 요청 목록 | ⭐⭐⭐ | ❌ |
| POST | `/api/agora/friends/requests/{requestId}/accept` | 친구 요청 수락 | ⭐⭐⭐ | ❌ |
| DELETE | `/api/agora/friends/requests/{requestId}` | 친구 요청 거절 | ⭐⭐⭐ | ❌ |
| DELETE | `/api/agora/friends/{friendId}` | 친구 삭제 | ⭐⭐ | ❌ |
| POST | `/api/agora/friends/{friendId}/favorite` | 즐겨찾기 추가 | ⭐ | ❌ |
| DELETE | `/api/agora/friends/{friendId}/favorite` | 즐겨찾기 제거 | ⭐ | ❌ |
| POST | `/api/agora/friends/{friendId}/block` | 차단 | ⭐ | ❌ |
| DELETE | `/api/agora/friends/{friendId}/block` | 차단 해제 | ⭐ | ❌ |
| GET | `/api/agora/friends/blocked` | 차단 목록 | ⭐ | ❌ |
| GET | `/api/agora/friends/birthdays` | 친구 생일 목록 | ⭐ | ❌ |

**구현 파일:**
- `AgoraFriendController.java`
- `AgoraFriendService.java`
- `AgoraFriendServiceImpl.java`
- DTO: `FriendResponse.java`, `FriendRequestDto.java`

**엔티티 (기존):** `Friend.java`, `FriendRequest.java`, `BlockedUser.java`

---

### `/api/agora/chats` - 채팅 (1:1) (AgoraChatController 생성 필요)

| 메서드 | 엔드포인트 | 설명 | 우선순위 | 상태 |
|--------|-----------|------|----------|------|
| GET | `/api/agora/chats` | 채팅방 목록 | ⭐⭐⭐ | ❌ |
| POST | `/api/agora/chats` | 채팅방 생성 | ⭐⭐⭐ | ❌ |
| GET | `/api/agora/chats/{chatId}/messages` | 메시지 목록 (페이징) | ⭐⭐⭐ | ❌ |
| POST | `/api/agora/chats/{chatId}/messages` | 메시지 전송 | ⭐⭐⭐ | ❌ |
| DELETE | `/api/agora/chats/{chatId}/messages/{messageId}` | 메시지 삭제 | ⭐⭐ | ❌ |
| PUT | `/api/agora/chats/{chatId}/read` | 읽음 처리 | ⭐⭐ | ❌ |

**WebSocket 엔드포인트:**
- `/ws/agora/chat` - WebSocket 연결
- `/topic/agora/chat/{chatId}` - 구독
- `/app/agora/chat/{chatId}/send` - 메시지 발행

**구현 파일:**
- `AgoraChatController.java`
- `AgoraChatService.java`
- `AgoraChatServiceImpl.java`
- `WebSocketConfig.java`
- `AgoraChatWebSocketHandler.java`
- DTO: `ChatResponse.java`, `MessageDto.java`, `SendMessageRequest.java`

**엔티티 (기존):** `Chat.java`, `Message.java`, `ChatParticipant.java`, `MessageAttachment.java`, `MessageReadStatus.java`

---

### `/api/agora/files` - 파일 업로드 (AgoraFileController 생성 필요)

| 메서드 | 엔드포인트 | 설명 | 우선순위 | 상태 |
|--------|-----------|------|----------|------|
| POST | `/api/agora/files/upload` | 파일 업로드 | ⭐⭐⭐ | ❌ |
| POST | `/api/agora/files/upload-image` | 이미지 업로드 (썸네일 생성) | ⭐⭐ | ❌ |
| GET | `/api/agora/files/{fileId}/download` | 파일 다운로드 | ⭐⭐ | ❌ |
| DELETE | `/api/agora/files/{fileId}` | 파일 삭제 | ⭐⭐ | ❌ |

**구현 파일:**
- `AgoraFileController.java`
- `AgoraFileService.java`
- `AgoraFileServiceImpl.java`
- DTO: `FileUploadResponse.java`

**엔티티 (기존):** `AgoraFile.java`, `FileMetadata.java`

**기술 스택:**
- AWS S3 또는 MinIO
- Spring Boot Multipart

---

## 🟡 Medium Priority - 중요 기능

### `/api/agora/chats/groups` - 그룹 채팅 (AgoraGroupChatController 생성 필요)

| 메서드 | 엔드포인트 | 설명 | 우선순위 | 상태 |
|--------|-----------|------|----------|------|
| POST | `/api/agora/chats/groups` | 그룹 생성 | ⭐⭐ | ❌ |
| GET | `/api/agora/chats/groups/{groupId}` | 그룹 정보 조회 | ⭐⭐ | ❌ |
| PUT | `/api/agora/chats/groups/{groupId}` | 그룹 정보 수정 | ⭐⭐ | ❌ |
| POST | `/api/agora/chats/groups/{groupId}/members` | 멤버 초대 | ⭐⭐ | ❌ |
| DELETE | `/api/agora/chats/groups/{groupId}/members/{userId}` | 멤버 추방 | ⭐⭐ | ❌ |
| DELETE | `/api/agora/chats/groups/{groupId}/leave` | 그룹 나가기 | ⭐⭐ | ❌ |

**구현 파일:**
- `AgoraGroupChatController.java`
- `AgoraGroupChatService.java`
- `AgoraGroupChatServiceImpl.java`

**엔티티 (생성 필요):** `Group.java`, `GroupMember.java`

---

### `/api/agora/chats/folders` - 채팅 폴더 (AgoraChatFolderController 생성 필요)

| 메서드 | 엔드포인트 | 설명 | 우선순위 | 상태 |
|--------|-----------|------|----------|------|
| GET | `/api/agora/chats/folders` | 폴더 목록 | ⭐⭐ | ❌ |
| POST | `/api/agora/chats/folders` | 폴더 생성 | ⭐⭐ | ❌ |
| PUT | `/api/agora/chats/folders/{folderId}` | 폴더 수정 | ⭐⭐ | ❌ |
| DELETE | `/api/agora/chats/folders/{folderId}` | 폴더 삭제 | ⭐⭐ | ❌ |
| POST | `/api/agora/chats/{chatId}/folder` | 채팅방을 폴더에 추가 | ⭐⭐ | ❌ |
| DELETE | `/api/agora/chats/{chatId}/folder` | 채팅방을 폴더에서 제거 | ⭐⭐ | ❌ |

**구현 파일:**
- `AgoraChatFolderController.java`
- `AgoraChatFolderService.java`
- `AgoraChatFolderServiceImpl.java`

**엔티티 (기존):** `ChatFolder.java`, `ChatFolderItem.java`

---

### `/api/agora/teams` - 팀 관리 (AgoraTeamController 생성 필요)

| 메서드 | 엔드포인트 | 설명 | 우선순위 | 상태 |
|--------|-----------|------|----------|------|
| GET | `/api/agora/teams` | 팀 목록 | ⭐⭐ | ❌ |
| POST | `/api/agora/teams` | 팀 생성 | ⭐⭐ | ❌ |
| GET | `/api/agora/teams/{teamId}` | 팀 상세 정보 | ⭐⭐ | ❌ |
| PUT | `/api/agora/teams/{teamId}` | 팀 정보 수정 | ⭐⭐ | ❌ |
| DELETE | `/api/agora/teams/{teamId}` | 팀 삭제 | ⭐⭐ | ❌ |
| POST | `/api/agora/teams/{teamId}/members` | 팀원 추가 | ⭐⭐ | ❌ |
| DELETE | `/api/agora/teams/{teamId}/members/{userId}` | 팀원 제거 | ⭐⭐ | ❌ |
| PUT | `/api/agora/teams/{teamId}/members/{userId}/role` | 팀원 역할 변경 | ⭐⭐ | ❌ |

**구현 파일:**
- `AgoraTeamController.java`
- `AgoraTeamService.java`
- `AgoraTeamServiceImpl.java`

**엔티티 (기존):** `Team.java`, `TeamMember.java`, `TeamRole.java`

---

### `/api/agora/teams/{teamId}/profile` - 팀 프로필 관리 ⭐ NEW

| 메서드 | 엔드포인트 | 설명 | 우선순위 | 상태 |
|--------|-----------|------|----------|------|
| POST | `/api/agora/teams/{teamId}/profile` | 팀 프로필 생성 (최초) | ⭐⭐ | ❌ |
| GET | `/api/agora/teams/{teamId}/profile` | 내 팀 프로필 조회 | ⭐⭐ | ❌ |
| PUT | `/api/agora/teams/{teamId}/profile` | 팀 프로필 수정 | ⭐⭐ | ❌ |
| PUT | `/api/agora/teams/{teamId}/profile/image` | 팀 프로필 이미지 변경 | ⭐⭐ | ❌ |
| GET | `/api/agora/teams/{teamId}/members/{memberId}/profile` | 다른 팀원 프로필 조회 | ⭐⭐ | ❌ |

**설명:**
- 팀 프로필은 자동 생성되지 않음 → 명시적으로 생성 필요
- 팀원 초대 수락 시 앱에서 팀 프로필 생성 화면으로 이동
- 팀 내에서 개인 Agora 프로필과 별도로 사용하는 프로필
- displayName, profileImage를 팀별로 다르게 설정 가능

**구현 파일:**
- `AgoraTeamProfileController.java` 또는 `AgoraTeamController.java`에 통합
- `AgoraTeamProfileService.java`
- `AgoraTeamProfileServiceImpl.java`

**엔티티 (기존):** `TeamProfile.java`

---

### `/api/agora/notifications` - 알림 (AgoraNotificationController 생성 필요)

| 메서드 | 엔드포인트 | 설명 | 우선순위 | 상태 |
|--------|-----------|------|----------|------|
| GET | `/api/agora/notifications` | 알림 목록 | ⭐⭐ | ❌ |
| PUT | `/api/agora/notifications/{notificationId}/read` | 읽음 처리 | ⭐⭐ | ❌ |
| DELETE | `/api/agora/notifications/{notificationId}` | 알림 삭제 | ⭐⭐ | ❌ |
| POST | `/api/agora/notifications/fcm-token` | FCM 토큰 등록 | ⭐⭐ | ❌ |

**구현 파일:**
- `AgoraNotificationController.java`
- `AgoraNotificationService.java`
- `AgoraNotificationServiceImpl.java`
- `FCMService.java`

**엔티티 (기존):** `Notification.java`, `FcmToken.java`

---

## 🟢 Low Priority - 추가 기능

### `/api/agora/teams/{teamId}/notices` - 팀 공지사항

| 메서드 | 엔드포인트 | 설명 | 상태 |
|--------|-----------|------|------|
| GET | `/api/agora/teams/{teamId}/notices` | 공지사항 목록 | ❌ |
| POST | `/api/agora/teams/{teamId}/notices` | 공지사항 작성 | ❌ |
| GET | `/api/agora/teams/{teamId}/notices/{noticeId}` | 공지사항 상세 | ❌ |
| PUT | `/api/agora/teams/{teamId}/notices/{noticeId}` | 공지사항 수정 | ❌ |
| DELETE | `/api/agora/teams/{teamId}/notices/{noticeId}` | 공지사항 삭제 | ❌ |

**엔티티 (기존):** `Notice.java`

---

### `/api/agora/teams/{teamId}/todos` - 할 일

| 메서드 | 엔드포인트 | 설명 | 상태 |
|--------|-----------|------|------|
| GET | `/api/agora/teams/{teamId}/todos` | 할 일 목록 | ❌ |
| POST | `/api/agora/teams/{teamId}/todos` | 할 일 생성 | ❌ |
| PUT | `/api/agora/teams/{teamId}/todos/{todoId}` | 할 일 수정 | ❌ |
| PUT | `/api/agora/teams/{teamId}/todos/{todoId}/complete` | 완료 처리 | ❌ |
| DELETE | `/api/agora/teams/{teamId}/todos/{todoId}` | 할 일 삭제 | ❌ |

**엔티티 (기존):** `Todo.java`

---

### `/api/agora/teams/{teamId}/events` - 캘린더/일정

| 메서드 | 엔드포인트 | 설명 | 상태 |
|--------|-----------|------|------|
| GET | `/api/agora/teams/{teamId}/events` | 일정 목록 | ❌ |
| POST | `/api/agora/teams/{teamId}/events` | 일정 생성 | ❌ |
| PUT | `/api/agora/teams/{teamId}/events/{eventId}` | 일정 수정 | ❌ |
| DELETE | `/api/agora/teams/{teamId}/events/{eventId}` | 일정 삭제 | ❌ |

**엔티티 (기존):** `Event.java`

---

### `/api/agora/teams/{teamId}/org-chart` - 조직도

| 메서드 | 엔드포인트 | 설명 | 상태 |
|--------|-----------|------|------|
| GET | `/api/agora/teams/{teamId}/org-chart` | 조직도 조회 | ❌ |
| POST | `/api/agora/teams/{teamId}/positions` | 직책 추가 | ❌ |
| PUT | `/api/agora/teams/{teamId}/positions/{positionId}` | 직책 수정 | ❌ |
| DELETE | `/api/agora/teams/{teamId}/positions/{positionId}` | 직책 삭제 | ❌ |

---

### `/api/agora/settings` - 설정 관리 (AgoraSettingsController 생성 필요)

#### 알림 설정

| 메서드 | 엔드포인트 | 설명 | 상태 |
|--------|-----------|------|------|
| GET | `/api/agora/settings/notifications` | 알림 설정 조회 | ❌ |
| PUT | `/api/agora/settings/notifications` | 알림 설정 업데이트 | ❌ |

#### 개인정보 설정

| 메서드 | 엔드포인트 | 설명 | 상태 |
|--------|-----------|------|------|
| GET | `/api/agora/settings/privacy` | 개인정보 설정 조회 | ❌ |
| PUT | `/api/agora/settings/privacy` | 개인정보 설정 업데이트 | ❌ |

#### 생일 알림 설정

| 메서드 | 엔드포인트 | 설명 | 상태 |
|--------|-----------|------|------|
| PUT | `/api/agora/settings/birthday-reminder` | 생일 알림 설정 | ❌ |

**엔티티 (기존):** `UserSettings.java`

---

### `/api/account/security` - 계정 보안 설정 (AccountController에 추가)

| 메서드 | 엔드포인트 | 설명 | 상태 |
|--------|-----------|------|------|
| GET | `/api/account/security` | 보안 설정 조회 | ❌ |
| PUT | `/api/account/security` | 보안 설정 업데이트 | ❌ |
| GET | `/api/account/security/sessions` | 활성 세션 목록 | ✅ 구현됨 (SessionController) |
| DELETE | `/api/account/security/sessions/{sessionId}` | 세션 종료 | ✅ 구현됨 (SessionController) |

**참고:** 세션 관련 API는 이미 `SessionController`에 구현되어 있음

---

## 📋 구현 순서 추천

### Phase 1: 프로필 기본 기능
1. ✅ 인증 (완료 - OAuth 2.0 + PKCE)
2. ✅ 세션 관리 (완료 - SessionController)
3. **AccountController** - 계정 관리 (비밀번호 변경 등)
4. **AgoraProfileController** - Agora 프로필 관리
5. **AgoraFileController** - 파일 업로드

### Phase 2: 소셜 기능
1. **AgoraFriendController** - 친구 관리
2. **AgoraNotificationController** - 알림

### Phase 3: 채팅 기능
1. **AgoraChatController** - 1:1 채팅
2. **WebSocket** - 실시간 메시징
3. **AgoraGroupChatController** - 그룹 채팅
4. **AgoraChatFolderController** - 채팅 폴더

### Phase 4: 팀 기능
1. **AgoraTeamController** - 팀 관리
2. **AgoraTeamProfileController** - 팀 프로필 관리
3. 팀 공지사항, 할 일, 일정

### Phase 5: 고급 기능
1. **AgoraSettingsController** - 설정 관리
2. 조직도, 생일 관리 등

---

## 🛠️ 기술 스택

### Backend (현재 상태)
- ✅ Spring Boot 3.4.4
- ✅ Spring Security + JWT (OAuth 2.0 + PKCE)
- ✅ PostgreSQL
- ✅ Redis (세션, 토큰 블랙리스트)
- ⏳ Spring WebSocket + STOMP
- ⏳ AWS S3 / MinIO (파일 저장)
- ⏳ Firebase Cloud Messaging (푸시 알림)
- ⏳ JavaMailSender (이메일)

### Database Tables

#### 구현됨 ✅
- `users` - 기본 계정 정보
- `user_sessions` - 세션 관리
- `login_history` - 로그인 기록
- `clients` - OAuth 클라이언트
- `authorization_codes` - OAuth 인증 코드

#### Agora 엔티티 (정의됨, DDL 필요) ⏳
- `agora_user_profiles` - Agora 사용자 프로필
- `team_profiles` - 팀별 프로필
- `friends`, `friend_requests`, `blocked_users` - 친구 관리
- `chats`, `messages`, `chat_participants` - 채팅
- `message_attachments`, `message_read_status` - 메시지 상세
- `chat_folders`, `chat_folder_items` - 채팅 폴더
- `teams`, `team_members`, `team_roles` - 팀
- `notices`, `todos`, `events` - 팀 기능
- `notifications`, `fcm_tokens` - 알림
- `agora_files`, `file_metadata` - 파일
- `user_settings` - 사용자 설정

---

## 📁 프로젝트 구조

```
src/main/java/kr/hyfata/rest/api/
├── controller/
│   ├── AuthController.java         ✅
│   ├── OAuthController.java        ✅
│   ├── SessionController.java      ✅
│   ├── ClientController.java       ✅
│   ├── AccountController.java      ⏳ (생성 필요)
│   └── agora/                      ⏳ (패키지 생성 필요)
│       ├── AgoraProfileController.java
│       ├── AgoraFriendController.java
│       ├── AgoraChatController.java
│       ├── AgoraTeamController.java
│       └── ...
├── entity/
│   ├── User.java                   ✅
│   ├── UserSession.java            ✅
│   ├── LoginHistory.java           ✅
│   ├── Client.java                 ✅
│   ├── AuthorizationCode.java      ✅
│   └── agora/                      ✅ (엔티티 정의됨)
│       ├── AgoraUserProfile.java
│       ├── TeamProfile.java
│       ├── Friend.java
│       └── ...
└── ...
```

---

**최종 수정:** 2025-12-02
**버전:** 2.0
