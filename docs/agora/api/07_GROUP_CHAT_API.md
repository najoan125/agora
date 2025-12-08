# 그룹 채팅 API

## Base URL
- 기존: `/api/agora/chats/groups`
- 신규: `/api/agora/chats/group`

## 인증
Bearer Token (OAuth 2.0)

---

## ChatContext 설명

그룹 채팅도 **컨텍스트(Context)**에 따라 구분됩니다:

| Context | 설명 | 생성 방식 |
|---------|------|-----------|
| `FRIEND` | 친구 그룹 채팅 | 사용자가 직접 생성 |
| `TEAM` | 팀 그룹 채팅 | 팀 생성 시 자동 생성 |

---

# 신규 API (Context 기반)

## POST /group - 친구 그룹 채팅 생성

친구들과의 그룹 채팅을 생성합니다.

### Request
```http
POST /api/agora/chats/group
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "name": "친구 모임",
  "profileImage": "https://cdn.hyfata.com/groups/friends.jpg",
  "memberAgoraIds": ["john_doe", "jane_smith"]
}
```

### Request (userId로 멤버 지정)
```http
POST /api/agora/chats/group
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "name": "친구 모임",
  "profileImage": "https://cdn.hyfata.com/groups/friends.jpg",
  "memberUserIds": [123, 456]
}
```

### Request Body
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | string | Yes | 채팅방 이름 |
| profileImage | string | No | 채팅방 이미지 URL |
| memberAgoraIds | array | 둘 중 하나 필수 | 초대할 멤버 아고라 ID 목록 |
| memberUserIds | array | 둘 중 하나 필수 | 초대할 멤버 사용자 ID 목록 |
| context | string | No | 컨텍스트 (기본값: `FRIEND`) |

### Response 200
```json
{
  "chatId": 200,
  "type": "GROUP",
  "context": "FRIEND",
  "displayName": "친구 모임",
  "displayImage": "https://cdn.hyfata.com/groups/friends.jpg",
  "name": "친구 모임",
  "profileImage": "https://cdn.hyfata.com/groups/friends.jpg",
  "teamId": null,
  "teamName": null,
  "participantCount": 3,
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
      "identifier": "john_doe"
    },
    {
      "userId": 456,
      "displayName": "김철수",
      "profileImage": "https://cdn.hyfata.com/profiles/user456.jpg",
      "identifier": "jane_smith"
    }
  ],
  "otherParticipant": null,
  "lastMessageAt": null,
  "createdAt": "2025-01-15T10:30:00",
  "updatedAt": "2025-01-15T10:30:00"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 400 | INVALID_NAME | 채팅방 이름이 유효하지 않습니다 |
| 400 | NO_MEMBERS | 최소 1명의 멤버를 지정해야 합니다 |
| 404 | USER_NOT_FOUND | 지정된 멤버를 찾을 수 없습니다 |

---

## GET /group - 그룹 채팅 목록 조회

사용자의 친구 그룹 채팅 목록을 조회합니다 (팀 그룹 채팅 제외).

### Request
```http
GET /api/agora/chats/group
Authorization: Bearer {access_token}
```

### Response 200
```json
[
  {
    "chatId": 200,
    "type": "GROUP",
    "context": "FRIEND",
    "displayName": "친구 모임",
    "displayImage": "https://cdn.hyfata.com/groups/friends.jpg",
    "name": "친구 모임",
    "profileImage": "https://cdn.hyfata.com/groups/friends.jpg",
    "participantCount": 5,
    "lastMessageAt": "2025-01-15T10:30:00",
    "createdAt": "2025-01-10T15:30:00"
  }
]
```

---

# 기존 API (하위 호환)

## 1. POST / - 그룹 생성

```http
POST /api/agora/chats/groups
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "name": "개발팀 채팅",
  "memberAgoraIds": ["john_doe", "jane_smith"]
}
```

### Response 200
```json
{
  "chatId": 101,
  "name": "개발팀 채팅",
  "creatorAgoraId": "admin",
  "memberAgoraIds": ["admin", "john_doe"],
  "createdAt": "2025-01-15T10:30:00"
}
```

---

## 2. GET /{id} - 그룹 정보 조회

```http
GET /api/agora/chats/groups/101
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "chatId": 101,
  "name": "개발팀 채팅",
  "creatorAgoraId": "admin",
  "memberAgoraIds": ["admin", "john_doe"],
  "createdAt": "2025-01-15T10:30:00"
}
```

---

## 3. PUT /{id} - 그룹 정보 수정

그룹 이름을 수정합니다. 생성자만 가능합니다.

```http
PUT /api/agora/chats/groups/101
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "name": "개발팀 공용 채팅"
}
```

### Response 200
```json
{
  "chatId": 101,
  "name": "개발팀 공용 채팅",
  "creatorAgoraId": "admin",
  "memberAgoraIds": ["admin", "john_doe"],
  "createdAt": "2025-01-15T10:30:00",
  "updatedAt": "2025-01-15T11:00:00"
}
```

---

## 4. POST /{id}/members - 멤버 초대

```http
POST /api/agora/chats/groups/101/members
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "memberAgoraIds": ["new_user", "another_user"]
}
```

### Response 200
```json
{
  "chatId": 101,
  "name": "개발팀 채팅",
  "creatorAgoraId": "admin",
  "memberAgoraIds": ["admin", "john_doe", "new_user", "another_user"],
  "createdAt": "2025-01-15T10:30:00",
  "updatedAt": "2025-01-15T11:30:00"
}
```

---

## 5. DELETE /{id}/members/{userId} - 멤버 제거

생성자만 멤버를 제거할 수 있습니다.

```http
DELETE /api/agora/chats/groups/101/members/101
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "멤버가 제거되었습니다"
}
```

---

## 6. DELETE /{id}/leave - 그룹 나가기

그룹에서 나갑니다.

```http
DELETE /api/agora/chats/groups/101/leave
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "그룹을 나갔습니다"
}
```

**주의**: 생성자가 나가면 다른 멤버가 자동으로 생성자가 됩니다.

---

## 그룹 채팅 메시지

그룹 채팅의 메시지는 1:1 채팅과 동일한 WebSocket STOMP를 사용합니다.

```javascript
// 그룹 채팅방 구독
client.subscribe(`/topic/agora/chat/101`, (message) => {
  const event = JSON.parse(message.body);
  // 모든 멤버가 메시지 수신
});

// 메시지 전송
client.publish({
  destination: `/app/agora/chat/101/send`,
  body: JSON.stringify({
    content: "안녕하세요!",
    type: "TEXT"
  })
});
```

---

## 권한 관리

| 권한 | 생성자 | 멤버 |
|------|--------|------|
| 메시지 전송 | O | O |
| 메시지 삭제 | O | O (자신의 메시지만) |
| 멤버 초대 | O | X |
| 멤버 제거 | O | X |
| 그룹 정보 수정 | O | X |
| 그룹 나가기 | O | O |
