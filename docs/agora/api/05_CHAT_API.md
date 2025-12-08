# 1:1 채팅 REST API

## Base URL
`/api/agora/chats`

## 인증
Bearer Token (OAuth 2.0)

---

## ChatContext 설명

채팅은 **컨텍스트(Context)**에 따라 다른 프로필 정보를 표시합니다:

| Context | 설명 | 프로필 소스 |
|---------|------|-------------|
| `FRIEND` | 친구 컨텍스트 | AgoraUserProfile (아고라 ID, 표시 이름) |
| `TEAM` | 팀 컨텍스트 | TeamProfile (팀 내 닉네임, 팀 프로필 이미지) |

---

## 1. GET / - 채팅방 목록

```http
GET /api/agora/chats
Authorization: Bearer {access_token}
```

### Response 200
```json
[
  {
    "chatId": 100,
    "type": "DIRECT",
    "name": "홍길동",
    "profileImage": "https://cdn.hyfata.com/profiles/user123.jpg",
    "lastMessageContent": "안녕하세요!",
    "lastMessageSenderName": "홍길동",
    "lastMessageTime": "2025-01-15T10:30:00",
    "participantCount": 2,
    "isPinned": false,
    "pinnedAt": null
  }
]
```

---

## 2. POST / - 채팅방 생성 또는 조회

다른 사용자와의 1:1 채팅방을 생성하거나 기존 채팅방을 반환합니다.

### Request
```http
POST /api/agora/chats
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "targetAgoraId": "john_doe"
}
```

### Response 200
```json
{
  "chatId": 100,
  "participantCount": 2,
  "lastMessage": null,
  "lastMessageAt": null,
  "isPinned": false,
  "createdAt": "2025-01-15T10:30:00"
}
```

---

## 3. GET /{chatId} - 채팅방 상세

```http
GET /api/agora/chats/100
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "chatId": 100,
  "participantCount": 2,
  "lastMessage": "안녕하세요!",
  "lastMessageAt": "2025-01-15T10:30:00",
  "isPinned": false,
  "createdAt": "2025-01-10T15:30:00"
}
```

---

## 4. GET /{chatId}/messages - 메시지 조회 (Cursor Pagination)

과거 메시지를 조회합니다.

### Request
```http
GET /api/agora/chats/100/messages?cursor=999&limit=20
Authorization: Bearer {access_token}
```

### Response 200
```json
[
  {
    "messageId": 999,
    "senderId": 123,
    "senderAgoraId": "john_doe",
    "senderName": "홍길동",
    "senderProfileImage": "https://...",
    "content": "반갑습니다!",
    "type": "TEXT",
    "isDeleted": false,
    "isPinned": false,
    "createdAt": "2025-01-15T09:00:00",
    "updatedAt": "2025-01-15T09:00:00"
  }
]
```

### Query Parameters
| Name | Type | Description |
|------|------|-------------|
| cursor | long | 이전 메시지 ID (페이징 용) |
| limit | int | 반환할 메시지 수 (기본 20) |

---

## 5. POST /{chatId}/messages - 메시지 전송

```http
POST /api/agora/chats/100/messages
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "content": "안녕하세요!",
  "type": "TEXT",
  "replyToId": null
}
```

### Response 200
```json
{
  "messageId": 1000,
  "senderId": 100,
  "senderAgoraId": "my_agora_id",
  "senderName": "나",
  "senderProfileImage": "https://cdn.hyfata.com/profiles/me.jpg",
  "content": "안녕하세요!",
  "type": "TEXT",
  "isDeleted": false,
  "isPinned": false,
  "createdAt": "2025-01-15T10:35:00",
  "updatedAt": "2025-01-15T10:35:00"
}
```

---

## 6. DELETE /{chatId}/messages/{msgId} - 메시지 삭제

```http
DELETE /api/agora/chats/100/messages/1000
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "메시지가 삭제되었습니다"
}
```

---

## 7. PUT /{chatId}/read - 읽음 처리

채팅방의 모든 메시지를 읽음 처리합니다.

```http
PUT /api/agora/chats/100/read
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "읽음 처리되었습니다"
}
```

---

## 메시지 타입

| Type | 설명 |
|------|------|
| TEXT | 일반 텍스트 |
| IMAGE | 이미지 |
| FILE | 파일 |

---

# Context 기반 1:1 채팅 API

## 8. POST /direct - 1:1 채팅 생성/조회

컨텍스트(FRIEND/TEAM)를 지정하여 1:1 채팅을 생성하거나 기존 채팅을 반환합니다.

### Request
```http
POST /api/agora/chats/direct
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "targetUserId": 123,
  "context": "FRIEND"
}
```

### Request (팀 컨텍스트)
```http
POST /api/agora/chats/direct
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "targetUserId": 123,
  "context": "TEAM",
  "teamId": 1
}
```

### Request Body
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| targetUserId | long | Yes | 대상 사용자 ID |
| context | string | Yes | 채팅 컨텍스트 (`FRIEND` 또는 `TEAM`) |
| teamId | long | TEAM 컨텍스트 시 필수 | 팀 ID |

### Response 200
```json
{
  "chatId": 100,
  "type": "DIRECT",
  "context": "FRIEND",
  "displayName": "홍길동",
  "displayImage": "https://cdn.hyfata.com/profiles/user123.jpg",
  "name": null,
  "profileImage": null,
  "teamId": null,
  "teamName": null,
  "participantCount": 2,
  "participants": [
    {
      "userId": 100,
      "displayName": "나",
      "profileImage": "https://cdn.hyfata.com/profiles/me.jpg",
      "identifier": "my_agora_id"
    },
    {
      "userId": 123,
      "displayName": "홍길동",
      "profileImage": "https://cdn.hyfata.com/profiles/user123.jpg",
      "identifier": "hong_gildong"
    }
  ],
  "otherParticipant": {
    "userId": 123,
    "displayName": "홍길동",
    "profileImage": "https://cdn.hyfata.com/profiles/user123.jpg",
    "identifier": "hong_gildong"
  },
  "readCount": 0,
  "readEnabled": true,
  "messageCount": 0,
  "lastMessageAt": null,
  "createdAt": "2025-01-15T10:30:00",
  "updatedAt": "2025-01-15T10:30:00"
}
```

### Response (팀 컨텍스트)
```json
{
  "chatId": 101,
  "type": "DIRECT",
  "context": "TEAM",
  "displayName": "김개발",
  "displayImage": "https://cdn.hyfata.com/teams/dev-profile.jpg",
  "name": null,
  "profileImage": null,
  "teamId": 1,
  "teamName": "개발팀",
  "participantCount": 2,
  "participants": [...],
  "otherParticipant": {
    "userId": 123,
    "displayName": "김개발",
    "profileImage": "https://cdn.hyfata.com/teams/dev-profile.jpg",
    "identifier": null
  },
  "lastMessageAt": null,
  "createdAt": "2025-01-15T10:30:00",
  "updatedAt": "2025-01-15T10:30:00"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 400 | INVALID_CONTEXT | 유효하지 않은 컨텍스트입니다 |
| 400 | TEAM_ID_REQUIRED | TEAM 컨텍스트에서 teamId는 필수입니다 |
| 404 | USER_NOT_FOUND | 대상 사용자를 찾을 수 없습니다 |
| 403 | NOT_TEAM_MEMBER | 팀의 멤버가 아닙니다 |

---

## 9. GET /direct - 1:1 채팅 목록 (컨텍스트별)

지정된 컨텍스트의 1:1 채팅 목록을 조회합니다.

### Request
```http
GET /api/agora/chats/direct?context=FRIEND
Authorization: Bearer {access_token}
```

### Query Parameters
| Name | Type | Required | Description |
|------|------|----------|-------------|
| context | string | Yes | 채팅 컨텍스트 (`FRIEND` 또는 `TEAM`) |

### Response 200
```json
[
  {
    "chatId": 100,
    "type": "DIRECT",
    "context": "FRIEND",
    "displayName": "홍길동",
    "displayImage": "https://cdn.hyfata.com/profiles/user123.jpg",
    "participantCount": 2,
    "otherParticipant": {
      "userId": 123,
      "displayName": "홍길동",
      "profileImage": "https://cdn.hyfata.com/profiles/user123.jpg",
      "identifier": "hong_gildong"
    },
    "lastMessageAt": "2025-01-15T10:30:00",
    "createdAt": "2025-01-10T15:30:00"
  }
]
```

---

## ChatResponse 스키마

| Field | Type | Description |
|-------|------|-------------|
| chatId | long | 채팅방 ID |
| type | string | 채팅 타입 (`DIRECT`, `GROUP`) |
| context | string | 채팅 컨텍스트 (`FRIEND`, `TEAM`) |
| displayName | string | 표시 이름 (1:1: 상대방 이름, GROUP: 채팅방 이름) |
| displayImage | string | 표시 이미지 (1:1: 상대방 이미지, GROUP: 채팅방 이미지) |
| name | string | 채팅방 이름 (GROUP만 해당) |
| profileImage | string | 채팅방 이미지 (GROUP만 해당) |
| teamId | long | 팀 ID (TEAM 컨텍스트인 경우) |
| teamName | string | 팀 이름 (TEAM 컨텍스트인 경우) |
| participantCount | long | 참여자 수 |
| participants | array | 참여자 목록 |
| otherParticipant | object | 1:1 채팅 상대방 프로필 |
| readCount | long | 읽은 메시지 수 |
| readEnabled | boolean | 읽음 확인 활성화 여부 |
| messageCount | long | 전체 메시지 수 |
| lastMessageAt | datetime | 마지막 메시지 시간 |
| createdAt | datetime | 생성 시간 |
| updatedAt | datetime | 수정 시간 |

## ParticipantProfile 스키마

| Field | Type | Description |
|-------|------|-------------|
| userId | long | 사용자 ID |
| displayName | string | 표시 이름 |
| profileImage | string | 프로필 이미지 URL |
| identifier | string | 식별자 (FRIEND: agoraId, TEAM: null) |
