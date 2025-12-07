# 그룹 채팅 API

## Base URL
`/api/agora/chats/groups`

## 인증
Bearer Token (OAuth 2.0)

---

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
  "groupChatId": 101,
  "name": "개발팀 채팅",
  "creatorEmail": "admin@example.com",
  "memberCount": 3,
  "members": [
    { "userId": 100, "email": "admin@example.com", "agoraId": "admin" },
    { "userId": 101, "email": "john@example.com", "agoraId": "john_doe" }
  ],
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
  "groupChatId": 101,
  "name": "개발팀 채팅",
  "creatorEmail": "admin@example.com",
  "memberCount": 3,
  "members": [
    { "userId": 100, "email": "admin@example.com", "agoraId": "admin", "role": "admin" },
    { "userId": 101, "email": "john@example.com", "agoraId": "john_doe", "role": "member" }
  ],
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
  "groupChatId": 101,
  "name": "개발팀 공용 채팅",
  "creatorEmail": "admin@example.com",
  "memberCount": 3,
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
  "message": "멤버가 추가되었습니다",
  "addedCount": 2
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
