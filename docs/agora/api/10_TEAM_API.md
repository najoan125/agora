# 팀 관리 API

## Base URL
`/api/agora/teams`

## 인증
Bearer Token (OAuth 2.0)

---

## 1. GET / - 팀 목록 조회

사용자가 속한 팀 목록을 조회합니다.

### Request
```http
GET /api/agora/teams
Authorization: Bearer {access_token}
```

### Response 200
```json
[
  {
    "teamId": 1,
    "name": "개발팀",
    "description": "백엔드 개발 팀",
    "profileImage": "https://cdn.hyfata.com/teams/dev-team.jpg",
    "isMain": false,
    "creatorEmail": "admin@example.com",
    "memberCount": 5,
    "createdAt": "2025-01-01T10:00:00",
    "updatedAt": "2025-01-15T10:00:00"
  }
]
```

---

## 2. POST / - 팀 생성

새로운 팀을 생성합니다. 생성자는 자동으로 ADMIN 역할을 부여받습니다.

### Request
```http
POST /api/agora/teams
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "name": "개발팀",
  "description": "백엔드 개발 팀",
  "profileImage": "https://cdn.hyfata.com/teams/dev-team.jpg"
}
```

### Response 200
```json
{
  "teamId": 1,
  "name": "개발팀",
  "description": "백엔드 개발 팀",
  "profileImage": "https://cdn.hyfata.com/teams/dev-team.jpg",
  "isMain": false,
  "creatorEmail": "admin@example.com",
  "memberCount": 1,
  "createdAt": "2025-01-15T10:30:00",
  "updatedAt": "2025-01-15T10:30:00"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 400 | INVALID_NAME | 팀 이름이 유효하지 않습니다 |

---

## 3. GET /{id} - 팀 상세 조회

팀의 상세 정보를 조회합니다.

### Request
```http
GET /api/agora/teams/1
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "teamId": 1,
  "name": "개발팀",
  "description": "백엔드 개발 팀",
  "profileImage": "https://cdn.hyfata.com/teams/dev-team.jpg",
  "isMain": false,
  "creatorEmail": "admin@example.com",
  "memberCount": 5,
  "createdAt": "2025-01-01T10:00:00",
  "updatedAt": "2025-01-15T10:00:00"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 404 | TEAM_NOT_FOUND | 팀을 찾을 수 없습니다 |
| 403 | NOT_TEAM_MEMBER | 팀의 멤버가 아닙니다 |

---

## 4. PUT /{id} - 팀 정보 수정

팀의 정보를 수정합니다. **팀 생성자만 가능합니다.**

### Request
```http
PUT /api/agora/teams/1?name=개발팀(수정)&description=백엔드및프론트엔드개발팀&profileImage=https://cdn.hyfata.com/teams/dev-team-updated.jpg
Authorization: Bearer {access_token}
```

### Query Parameters
| Name | Type | Required | Description |
|------|------|----------|-------------|
| name | string | No | 팀 이름 |
| description | string | No | 팀 설명 |
| profileImage | string | No | 팀 프로필 이미지 URL |

### Response 200
```json
{
  "teamId": 1,
  "name": "개발팀 (수정)",
  "description": "백엔드 및 프론트엔드 개발 팀",
  "profileImage": "https://cdn.hyfata.com/teams/dev-team-updated.jpg",
  "isMain": false,
  "creatorEmail": "admin@example.com",
  "memberCount": 5,
  "createdAt": "2025-01-01T10:00:00",
  "updatedAt": "2025-01-15T11:00:00"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 403 | FORBIDDEN | 팀 생성자만 수정 가능합니다 |

---

## 5. DELETE /{id} - 팀 삭제

팀을 삭제합니다. **팀 생성자만 가능합니다.**

### Request
```http
DELETE /api/agora/teams/1
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "팀이 삭제되었습니다"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 403 | FORBIDDEN | 팀 생성자만 삭제 가능합니다 |

---

## 6. GET /{id}/members - 팀원 목록 조회

팀의 멤버 목록을 조회합니다.

### Request
```http
GET /api/agora/teams/1/members
Authorization: Bearer {access_token}
```

### Response 200
```json
[
  {
    "memberId": 1,
    "userId": 100,
    "agoraId": "admin_user",
    "displayName": "관리자",
    "profileImage": "https://cdn.hyfata.com/profiles/admin.jpg",
    "roleName": "admin",
    "joinedAt": "2025-01-01T10:00:00"
  },
  {
    "memberId": 2,
    "userId": 101,
    "agoraId": "user1",
    "displayName": "사용자1",
    "profileImage": "https://cdn.hyfata.com/profiles/user1.jpg",
    "roleName": "member",
    "joinedAt": "2025-01-05T15:30:00"
  }
]
```

**Note**: `displayName`과 `profileImage`는 사용자의 TeamProfile 정보입니다. TeamProfile이 없는 경우 `null`로 표시됩니다.

---

## 7. POST /{teamId}/invitations - 팀원 초대

팀에 새로운 멤버를 초대합니다. **팀 생성자만 가능합니다.**

agoraId를 사용하여 초대하며, 초대받은 사람이 수락하면 팀원으로 추가됩니다.

### Request
```http
POST /api/agora/teams/1/invitations
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "agoraId": "newuser"
}
```

### Response 200
```json
{
  "invitationId": 1,
  "teamId": 1,
  "teamName": "개발팀",
  "teamProfileImage": "https://cdn.hyfata.com/teams/dev-team.jpg",
  "fromAgoraId": "admin_user",
  "fromDisplayName": "관리자",
  "fromProfileImage": "https://cdn.hyfata.com/profiles/admin.jpg",
  "toAgoraId": "newuser",
  "toDisplayName": null,
  "toProfileImage": null,
  "status": "PENDING",
  "createdAt": "2025-01-15T11:30:00",
  "updatedAt": "2025-01-15T11:30:00"
}
```

**Note**: `toDisplayName`과 `toProfileImage`는 초대받은 사용자의 TeamProfile 정보입니다. TeamProfile이 없는 경우 `null`로 표시됩니다.

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 404 | USER_NOT_FOUND | agoraId로 사용자를 찾을 수 없습니다 |
| 404 | TEAM_NOT_FOUND | 팀을 찾을 수 없습니다 |
| 409 | ALREADY_MEMBER | 이미 팀의 멤버입니다 |
| 409 | INVITATION_ALREADY_SENT | 이미 초대를 보냈습니다 |
| 403 | FORBIDDEN | 팀 생성자만 초대 가능합니다 |

---

## 8. POST /invitations/{invitationId}/accept - 팀 초대 수락

받은 팀 초대를 수락합니다. **초대받은 사람만 가능합니다.**

수락 시 **TeamProfile이 필수**입니다. TeamProfile이 없는 경우 앱에서 생성 화면을 표시해야 합니다.

### Request
```http
POST /api/agora/teams/invitations/1/accept
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "invitationId": 1,
  "teamId": 1,
  "teamName": "개발팀",
  "teamProfileImage": "https://cdn.hyfata.com/teams/dev-team.jpg",
  "fromAgoraId": "admin_user",
  "fromDisplayName": "관리자",
  "fromProfileImage": "https://cdn.hyfata.com/profiles/admin.jpg",
  "toAgoraId": "newuser",
  "toDisplayName": "신입",
  "toProfileImage": "https://cdn.hyfata.com/profiles/newuser.jpg",
  "status": "ACCEPTED",
  "createdAt": "2025-01-15T11:30:00",
  "updatedAt": "2025-01-15T11:35:00"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 404 | INVITATION_NOT_FOUND | 초대를 찾을 수 없습니다 |
| 403 | FORBIDDEN | 초대받은 사람만 수락/거절할 수 있습니다 |
| 409 | ALREADY_PROCESSED | 이미 수락/거절된 초대입니다 |
| 400 | TEAM_PROFILE_REQUIRED | TeamProfile이 필요합니다 |

---

## 9. POST /invitations/{invitationId}/reject - 팀 초대 거절

받은 팀 초대를 거절합니다. **초대받은 사람만 가능합니다.**

### Request
```http
POST /api/agora/teams/invitations/1/reject
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "invitationId": 1,
  "teamId": 1,
  "teamName": "개발팀",
  "teamProfileImage": "https://cdn.hyfata.com/teams/dev-team.jpg",
  "fromAgoraId": "admin_user",
  "fromDisplayName": "관리자",
  "fromProfileImage": "https://cdn.hyfata.com/profiles/admin.jpg",
  "toAgoraId": "newuser",
  "toDisplayName": null,
  "toProfileImage": null,
  "status": "REJECTED",
  "createdAt": "2025-01-15T11:30:00",
  "updatedAt": "2025-01-15T11:40:00"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 404 | INVITATION_NOT_FOUND | 초대를 찾을 수 없습니다 |
| 403 | FORBIDDEN | 초대받은 사람만 수락/거절할 수 있습니다 |
| 409 | ALREADY_PROCESSED | 이미 수락/거절된 초대입니다 |

---

## 10. GET /invitations/received - 받은 팀 초대 목록

받은 팀 초대 목록을 조회합니다.

### Request
```http
GET /api/agora/teams/invitations/received
Authorization: Bearer {access_token}
```

### Response 200
```json
[
  {
    "invitationId": 1,
    "teamId": 1,
    "teamName": "개발팀",
    "teamProfileImage": "https://cdn.hyfata.com/teams/dev-team.jpg",
    "fromAgoraId": "admin_user",
    "fromDisplayName": "관리자",
    "fromProfileImage": "https://cdn.hyfata.com/profiles/admin.jpg",
    "toAgoraId": "newuser",
    "toDisplayName": null,
    "toProfileImage": null,
    "status": "PENDING",
    "createdAt": "2025-01-15T11:30:00",
    "updatedAt": "2025-01-15T11:30:00"
  }
]
```

---

## 11. GET /{teamId}/invitations - 보낸 팀 초대 목록

특정 팀에서 보낸 초대 목록을 조회합니다. **팀 생성자만 가능합니다.**

### Request
```http
GET /api/agora/teams/1/invitations
Authorization: Bearer {access_token}
```

### Response 200
```json
[
  {
    "invitationId": 1,
    "teamId": 1,
    "teamName": "개발팀",
    "teamProfileImage": "https://cdn.hyfata.com/teams/dev-team.jpg",
    "fromAgoraId": "admin_user",
    "fromDisplayName": "관리자",
    "fromProfileImage": "https://cdn.hyfata.com/profiles/admin.jpg",
    "toAgoraId": "newuser",
    "toDisplayName": null,
    "toProfileImage": null,
    "status": "PENDING",
    "createdAt": "2025-01-15T11:30:00",
    "updatedAt": "2025-01-15T11:30:00"
  }
]
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 404 | TEAM_NOT_FOUND | 팀을 찾을 수 없습니다 |
| 403 | FORBIDDEN | 팀 생성자만 조회할 수 있습니다 |

---

## 12. DELETE /{teamId}/members/{memberId} - 팀원 제거

팀에서 멤버를 제거합니다. **팀 생성자만 가능합니다.**

### Request
```http
DELETE /api/agora/teams/1/members/2
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "멤버가 제거되었습니다"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 403 | FORBIDDEN | 팀 생성자만 제거 가능합니다 |
| 403 | CANNOT_REMOVE_CREATOR | 생성자는 제거할 수 없습니다 |

---

## 13. PUT /{teamId}/members/{memberId}/role - 멤버 역할 변경

멤버의 역할을 변경합니다. **팀 생성자만 가능합니다.**

### Request
```http
PUT /api/agora/teams/1/members/2/role?roleName=admin
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "멤버 역할이 변경되었습니다"
}
```

### Query Parameters
| Name | Type | Required | Description |
|------|------|----------|-------------|
| roleName | string | Yes | 변경할 역할명 (admin, member) |

---

## 팀 역할

| 역할 | 권한 | 설명 |
|------|------|------|
| admin | 모든 권한 | 팀 수정, 멤버 관리, 공지/할일/일정 관리 |
| member | 읽기 및 기본 쓰기 | 채팅, 프로필 조회, 공지 읽기 |

---

## 14. GET /{teamId}/chat - 팀 그룹 채팅 조회

팀의 그룹 채팅방 정보를 조회합니다.

### Request
```http
GET /api/agora/teams/1/chat
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "chatId": 300,
  "type": "GROUP",
  "context": "TEAM",
  "displayName": "개발팀",
  "displayImage": "https://cdn.hyfata.com/teams/dev-team.jpg",
  "name": "개발팀",
  "profileImage": "https://cdn.hyfata.com/teams/dev-team.jpg",
  "teamId": 1,
  "teamName": "개발팀",
  "participantCount": 5,
  "participants": [
    {
      "userId": 100,
      "displayName": "관리자",
      "profileImage": "https://cdn.hyfata.com/profiles/admin.jpg",
      "identifier": null
    },
    {
      "userId": 101,
      "displayName": "김개발",
      "profileImage": "https://cdn.hyfata.com/profiles/dev1.jpg",
      "identifier": null
    }
  ],
  "otherParticipant": null,
  "lastMessageAt": "2025-01-15T10:30:00",
  "createdAt": "2025-01-01T10:00:00",
  "updatedAt": "2025-01-15T10:30:00"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 404 | TEAM_NOT_FOUND | 팀을 찾을 수 없습니다 |
| 403 | NOT_TEAM_MEMBER | 팀의 멤버가 아닙니다 |
| 404 | CHAT_NOT_FOUND | 팀 그룹 채팅을 찾을 수 없습니다 |

---

## 팀 그룹 채팅 자동 관리

### 자동 생성
- 팀을 생성하면 해당 팀의 그룹 채팅이 **자동으로 생성**됩니다
- 생성자는 자동으로 채팅 참여자로 추가됩니다

### 자동 동기화
- **멤버 추가**: 팀에 새 멤버가 추가되면 자동으로 팀 그룹 채팅에 참여자로 추가됩니다
- **멤버 제거**: 팀에서 멤버가 제거되면 자동으로 팀 그룹 채팅에서도 제거됩니다

```
팀 생성 → TeamCreatedEvent 발행 → 팀 그룹 채팅 생성
팀 멤버 추가 → TeamMemberAddedEvent 발행 → 채팅 참여자 추가
팀 멤버 제거 → TeamMemberRemovedEvent 발행 → 채팅 참여자 제거
```

---

## 팀 초대 상태

| Status | 설명 |
|--------|------|
| PENDING | 대기 중 |
| ACCEPTED | 수락됨 |
| REJECTED | 거절됨 |

---

## 주의사항

1. **팀 생성자**: 팀을 생성한 사용자만 팀 수정/삭제 가능
2. **멤버 관리**: 생성자만 멤버 초대/제거/역할 변경 가능
3. **팀 프로필**: 팀원들이 팀 내에서 사용할 프로필 설정은 별도의 팀 프로필 API 사용
4. **팀 그룹 채팅**: 팀 생성 시 자동 생성되며, 별도로 생성/삭제 불가

### 팀 초대 플로우

1. **초대 생성**: 팀 생성자가 agoraId로 초대 전송 (`POST /{teamId}/invitations`)
2. **초대 알림**: 초대받은 사용자는 받은 초대 목록에서 확인 (`GET /invitations/received`)
3. **초대 수락/거절**: 초대받은 사람이 수락 또는 거절
   - **수락**: `POST /invitations/{invitationId}/accept`
   - **거절**: `POST /invitations/{invitationId}/reject`
4. **TeamProfile 필수**: 초대 수락 시 TeamProfile이 없으면 에러 반환 (`400 TEAM_PROFILE_REQUIRED`)
   - 앱에서는 이 에러를 받으면 TeamProfile 생성 화면을 표시해야 함
5. **프로필 표시**: 초대 목록에서 TeamProfile 정보가 표시됨 (없으면 agoraId만 표시)
