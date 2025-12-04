# 🚀 Hyfata API - 라우트별 구현 가이드

**작성일:** 2025-12-01  
**프로젝트:** Spring Boot REST API for Agora Messenger

---

## 📊 구현 현황 요약

- ✅ **완료:** 12개 API
- ⏳ **미구현:** 약 98개 API
- 🎯 **우선순위:** High → Medium → Low

---

## ✅ 완료된 API

### `/api/auth` - 인증 (AuthController)

| 메서드 | 엔드포인트 | 설명 | 상태 |
|--------|-----------|------|------|
| POST | `/api/auth/register` | 회원가입 | ✅ |
| POST | `/api/auth/login` | 로그인 (레거시) | ✅ |
| POST | `/api/auth/refresh` | 토큰 갱신 | ✅ |
| POST | `/api/auth/verify-2fa` | 2FA 검증 | ✅ |
| POST | `/api/auth/request-password-reset` | 비밀번호 재설정 요청 | ✅ |
| POST | `/api/auth/reset-password` | 비밀번호 재설정 | ✅ |
| GET | `/api/auth/verify-email` | 이메일 검증 | ✅ |
| POST | `/api/auth/enable-2fa` | 2FA 활성화 | ✅ |
| POST | `/api/auth/disable-2fa` | 2FA 비활성화 | ✅ |

### `/oauth` - OAuth 2.0 (OAuthController)

| 메서드 | 엔드포인트 | 설명 | 상태 |
|--------|-----------|------|------|
| GET | `/oauth/authorize` | OAuth 인증 요청 (PKCE 지원) | ✅ |
| POST | `/oauth/login` | OAuth 로그인 처리 | ✅ |
| POST | `/oauth/token` | Authorization Code → Token 교환 | ✅ |

---

## 🔥 High Priority - 필수 구현

### `/api/users` - 사용자 관리 (UserController 생성 필요)

| 메서드 | 엔드포인트 | 설명 | 우선순위 | 상태 |
|--------|-----------|------|----------|------|
| GET | `/api/users/me` | 내 프로필 조회 | ⭐⭐⭐ | ❌ |
| PUT | `/api/users/me` | 프로필 수정 | ⭐⭐⭐ | ❌ |
| PUT | `/api/users/me/password` | 비밀번호 변경 | ⭐⭐⭐ | ❌ |
| POST | `/api/users/me/avatar` | 프로필 사진 업로드 | ⭐⭐ | ❌ |
| GET | `/api/users/{userId}` | 다른 사용자 프로필 조회 | ⭐⭐ | ❌ |
| GET | `/api/users/search` | 사용자 검색 | ⭐⭐ | ❌ |
| GET | `/api/users/by-email` | 이메일로 사용자 찾기 | ⭐⭐ | ❌ |
| POST | `/api/users/me/deactivate` | 계정 비활성화 | ⭐ | ❌ |
| DELETE | `/api/users/me` | 계정 삭제 | ⭐ | ❌ |
| POST | `/api/users/me/restore` | 계정 복구 | ⭐ | ❌ |

**구현 파일:**
- `UserController.java`
- `UserService.java`
- `UserServiceImpl.java`
- DTO: `UserProfileResponse.java`, `UpdateProfileRequest.java`, `ChangePasswordRequest.java`

---

### `/api/friends` - 친구 관리 (FriendController 생성 필요)

| 메서드 | 엔드포인트 | 설명 | 우선순위 | 상태 |
|--------|-----------|------|----------|------|
| GET | `/api/friends` | 친구 목록 | ⭐⭐⭐ | ❌ |
| POST | `/api/friends/request` | 친구 요청 | ⭐⭐⭐ | ❌ |
| GET | `/api/friends/requests` | 받은 친구 요청 목록 | ⭐⭐⭐ | ❌ |
| POST | `/api/friends/requests/{requestId}/accept` | 친구 요청 수락 | ⭐⭐⭐ | ❌ |
| DELETE | `/api/friends/requests/{requestId}` | 친구 요청 거절 | ⭐⭐⭐ | ❌ |
| DELETE | `/api/friends/{friendId}` | 친구 삭제 | ⭐⭐ | ❌ |
| POST | `/api/friends/{friendId}/favorite` | 즐겨찾기 추가 | ⭐ | ❌ |
| DELETE | `/api/friends/{friendId}/favorite` | 즐겨찾기 제거 | ⭐ | ❌ |
| POST | `/api/friends/{friendId}/block` | 차단 | ⭐ | ❌ |
| DELETE | `/api/friends/{friendId}/block` | 차단 해제 | ⭐ | ❌ |
| GET | `/api/friends/blocked` | 차단 목록 | ⭐ | ❌ |
| GET | `/api/friends/birthdays` | 친구 생일 목록 | ⭐ | ❌ |

**구현 파일:**
- `FriendController.java`
- `FriendService.java`
- `FriendServiceImpl.java`
- Entity: `Friend.java`, `FriendRequest.java`, `BlockedUser.java`
- DTO: `FriendResponse.java`, `FriendRequestDto.java`

---

### `/api/chats` - 채팅 (1:1) (ChatController 생성 필요)

| 메서드 | 엔드포인트 | 설명 | 우선순위 | 상태 |
|--------|-----------|------|----------|------|
| GET | `/api/chats` | 채팅방 목록 | ⭐⭐⭐ | ❌ |
| POST | `/api/chats` | 채팅방 생성 | ⭐⭐⭐ | ❌ |
| GET | `/api/chats/{chatId}/messages` | 메시지 목록 (페이징) | ⭐⭐⭐ | ❌ |
| POST | `/api/chats/{chatId}/messages` | 메시지 전송 | ⭐⭐⭐ | ❌ |
| DELETE | `/api/chats/{chatId}/messages/{messageId}` | 메시지 삭제 | ⭐⭐ | ❌ |
| PUT | `/api/chats/{chatId}/read` | 읽음 처리 | ⭐⭐ | ❌ |

**WebSocket 엔드포인트:**
- `/ws/chat` - WebSocket 연결
- `/topic/chat/{chatId}` - 구독
- `/app/chat/{chatId}/send` - 메시지 발행

**구현 파일:**
- `ChatController.java`
- `ChatService.java`
- `ChatServiceImpl.java`
- `WebSocketConfig.java`
- `ChatWebSocketHandler.java`
- Entity: `Chat.java`, `Message.java`, `ChatParticipant.java`
- DTO: `ChatResponse.java`, `MessageDto.java`, `SendMessageRequest.java`

---

### `/api/files` - 파일 업로드 (FileController 생성 필요)

| 메서드 | 엔드포인트 | 설명 | 우선순위 | 상태 |
|--------|-----------|------|----------|------|
| POST | `/api/files/upload` | 파일 업로드 | ⭐⭐⭐ | ❌ |
| POST | `/api/files/upload-image` | 이미지 업로드 (썸네일 생성) | ⭐⭐ | ❌ |
| GET | `/api/files/{fileId}/download` | 파일 다운로드 | ⭐⭐ | ❌ |
| DELETE | `/api/files/{fileId}` | 파일 삭제 | ⭐⭐ | ❌ |

**구현 파일:**
- `FileController.java`
- `FileService.java`
- `FileServiceImpl.java`
- Entity: `FileMetadata.java`
- DTO: `FileUploadResponse.java`

**기술 스택:**
- AWS S3 또는 MinIO
- Spring Boot Multipart

---

## 🟡 Medium Priority - 중요 기능

### `/api/chats/groups` - 그룹 채팅 (GroupChatController 생성 필요)

| 메서드 | 엔드포인트 | 설명 | 우선순위 | 상태 |
|--------|-----------|------|----------|------|
| POST | `/api/chats/groups` | 그룹 생성 | ⭐⭐ | ❌ |
| GET | `/api/chats/groups/{groupId}` | 그룹 정보 조회 | ⭐⭐ | ❌ |
| PUT | `/api/chats/groups/{groupId}` | 그룹 정보 수정 | ⭐⭐ | ❌ |
| POST | `/api/chats/groups/{groupId}/members` | 멤버 초대 | ⭐⭐ | ❌ |
| DELETE | `/api/chats/groups/{groupId}/members/{userId}` | 멤버 추방 | ⭐⭐ | ❌ |
| DELETE | `/api/chats/groups/{groupId}/leave` | 그룹 나가기 | ⭐⭐ | ❌ |

**구현 파일:**
- `GroupChatController.java`
- `GroupChatService.java`
- Entity: `Group.java`, `GroupMember.java`

---

### `/api/chats/folders` - 채팅 폴더 (ChatFolderController 생성 필요)

| 메서드 | 엔드포인트 | 설명 | 우선순위 | 상태 |
|--------|-----------|------|----------|------|
| GET | `/api/chats/folders` | 폴더 목록 | ⭐⭐ | ❌ |
| POST | `/api/chats/folders` | 폴더 생성 | ⭐⭐ | ❌ |
| PUT | `/api/chats/folders/{folderId}` | 폴더 수정 | ⭐⭐ | ❌ |
| DELETE | `/api/chats/folders/{folderId}` | 폴더 삭제 | ⭐⭐ | ❌ |
| POST | `/api/chats/{chatId}/folder` | 채팅방을 폴더에 추가 | ⭐⭐ | ❌ |
| DELETE | `/api/chats/{chatId}/folder` | 채팅방을 폴더에서 제거 | ⭐⭐ | ❌ |

**구현 파일:**
- `ChatFolderController.java`
- `ChatFolderService.java`
- Entity: `ChatFolder.java`, `ChatFolderItem.java`

---

### `/api/teams` - 팀 관리 (TeamController 생성 필요)

| 메서드 | 엔드포인트 | 설명 | 우선순위 | 상태 |
|--------|-----------|------|----------|------|
| GET | `/api/teams` | 팀 목록 | ⭐⭐ | ❌ |
| POST | `/api/teams` | 팀 생성 | ⭐⭐ | ❌ |
| GET | `/api/teams/{teamId}` | 팀 상세 정보 | ⭐⭐ | ❌ |
| PUT | `/api/teams/{teamId}` | 팀 정보 수정 | ⭐⭐ | ❌ |
| DELETE | `/api/teams/{teamId}` | 팀 삭제 | ⭐⭐ | ❌ |
| POST | `/api/teams/{teamId}/members` | 팀원 추가 | ⭐⭐ | ❌ |
| DELETE | `/api/teams/{teamId}/members/{userId}` | 팀원 제거 | ⭐⭐ | ❌ |
| PUT | `/api/teams/{teamId}/members/{userId}/role` | 팀원 역할 변경 | ⭐⭐ | ❌ |

**구현 파일:**
- `TeamController.java`
- `TeamService.java`
- Entity: `Team.java`, `TeamMember.java`, `TeamRole.java`

---

### `/api/notifications` - 알림 (NotificationController 생성 필요)

| 메서드 | 엔드포인트 | 설명 | 우선순위 | 상태 |
|--------|-----------|------|----------|------|
| GET | `/api/notifications` | 알림 목록 | ⭐⭐ | ❌ |
| PUT | `/api/notifications/{notificationId}/read` | 읽음 처리 | ⭐⭐ | ❌ |
| DELETE | `/api/notifications/{notificationId}` | 알림 삭제 | ⭐⭐ | ❌ |
| POST | `/api/notifications/fcm-token` | FCM 토큰 등록 | ⭐⭐ | ❌ |

**구현 파일:**
- `NotificationController.java`
- `NotificationService.java`
- `FCMService.java`
- Entity: `Notification.java`, `FCMToken.java`

---

## 🟢 Low Priority - 추가 기능

### `/api/teams/{teamId}/notices` - 팀 공지사항

| 메서드 | 엔드포인트 | 설명 | 상태 |
|--------|-----------|------|------|
| GET | `/api/teams/{teamId}/notices` | 공지사항 목록 | ❌ |
| POST | `/api/teams/{teamId}/notices` | 공지사항 작성 | ❌ |
| GET | `/api/teams/{teamId}/notices/{noticeId}` | 공지사항 상세 | ❌ |
| PUT | `/api/teams/{teamId}/notices/{noticeId}` | 공지사항 수정 | ❌ |
| DELETE | `/api/teams/{teamId}/notices/{noticeId}` | 공지사항 삭제 | ❌ |

---

### `/api/teams/{teamId}/todos` - 할 일

| 메서드 | 엔드포인트 | 설명 | 상태 |
|--------|-----------|------|------|
| GET | `/api/teams/{teamId}/todos` | 할 일 목록 | ❌ |
| POST | `/api/teams/{teamId}/todos` | 할 일 생성 | ❌ |
| PUT | `/api/teams/{teamId}/todos/{todoId}` | 할 일 수정 | ❌ |
| PUT | `/api/teams/{teamId}/todos/{todoId}/complete` | 완료 처리 | ❌ |
| DELETE | `/api/teams/{teamId}/todos/{todoId}` | 할 일 삭제 | ❌ |

---

### `/api/teams/{teamId}/events` - 캘린더/일정

| 메서드 | 엔드포인트 | 설명 | 상태 |
|--------|-----------|------|------|
| GET | `/api/teams/{teamId}/events` | 일정 목록 | ❌ |
| POST | `/api/teams/{teamId}/events` | 일정 생성 | ❌ |
| PUT | `/api/teams/{teamId}/events/{eventId}` | 일정 수정 | ❌ |
| DELETE | `/api/teams/{teamId}/events/{eventId}` | 일정 삭제 | ❌ |

---

### `/api/teams/{teamId}/org-chart` - 조직도

| 메서드 | 엔드포인트 | 설명 | 상태 |
|--------|-----------|------|------|
| GET | `/api/teams/{teamId}/org-chart` | 조직도 조회 | ❌ |
| POST | `/api/teams/{teamId}/positions` | 직책 추가 | ❌ |
| PUT | `/api/teams/{teamId}/positions/{positionId}` | 직책 수정 | ❌ |
| DELETE | `/api/teams/{teamId}/positions/{positionId}` | 직책 삭제 | ❌ |

---

### `/api/settings` - 설정 관리 (SettingsController 생성 필요)

#### 알림 설정

| 메서드 | 엔드포인트 | 설명 | 상태 |
|--------|-----------|------|------|
| GET | `/api/settings/notifications` | 알림 설정 조회 | ❌ |
| PUT | `/api/settings/notifications` | 알림 설정 업데이트 | ❌ |

#### 개인정보 설정

| 메서드 | 엔드포인트 | 설명 | 상태 |
|--------|-----------|------|------|
| GET | `/api/settings/privacy` | 개인정보 설정 조회 | ❌ |
| PUT | `/api/settings/privacy` | 개인정보 설정 업데이트 | ❌ |

#### 보안 설정

| 메서드 | 엔드포인트 | 설명 | 상태 |
|--------|-----------|------|------|
| GET | `/api/settings/security` | 보안 설정 조회 | ❌ |
| PUT | `/api/settings/security` | 보안 설정 업데이트 | ❌ |
| GET | `/api/settings/security/sessions` | 활성 세션 목록 | ❌ |
| DELETE | `/api/settings/security/sessions/{sessionId}` | 세션 종료 | ❌ |

#### 생일 관리

| 메서드 | 엔드포인트 | 설명 | 상태 |
|--------|-----------|------|------|
| PUT | `/api/settings/birthday-reminder` | 생일 알림 설정 | ❌ |

---

## 📋 구현 순서 추천

### Phase 1: 사용자 기본 기능 (1-2주)
1. ✅ 인증 (완료)
2. **UserController** - 사용자 프로필 관리
3. **FileController** - 파일 업로드

### Phase 2: 소셜 기능 (2-3주)
4. **FriendController** - 친구 관리
5. **NotificationController** - 알림

### Phase 3: 채팅 기능 (3-4주)
6. **ChatController** - 1:1 채팅
7. **WebSocket** - 실시간 메시징
8. **GroupChatController** - 그룹 채팅
9. **ChatFolderController** - 채팅 폴더

### Phase 4: 팀 기능 (2-3주)
10. **TeamController** - 팀 관리
11. 팀 공지사항, 할 일, 일정

### Phase 5: 고급 기능 (2-3주)
12. **SettingsController** - 설정 관리
13. 조직도, 생일 관리 등

---

## 🛠️ 필요한 기술 스택

### Backend
- ✅ Spring Boot 3.x
- ✅ Spring Security + JWT
- ✅ PostgreSQL
- ⏳ Spring WebSocket + STOMP
- ⏳ Redis (세션, 캐싱)
- ⏳ AWS S3 / MinIO (파일 저장)
- ⏳ Firebase Cloud Messaging (푸시 알림)
- ⏳ JavaMailSender (이메일)

### Database Tables 필요
- ✅ `users`
- ⏳ `friends`, `friend_requests`, `blocked_users`
- ⏳ `chats`, `messages`, `chat_participants`
- ⏳ `chat_folders`, `chat_folder_items`
- ⏳ `groups`, `group_members`
- ⏳ `teams`, `team_members`, `team_roles`
- ⏳ `notifications`, `fcm_tokens`
- ⏳ `files`, `file_metadata`
- ⏳ `notices`, `todos`, `events`
- ⏳ `user_settings`, `user_sessions`

---

**작성자:** Antigravity AI Assistant  
**최종 수정:** 2025-12-01  
**버전:** 1.0
