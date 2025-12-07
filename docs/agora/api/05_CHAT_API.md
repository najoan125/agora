# 1:1 채팅 REST API

## Base URL
`/api/agora/chats`

## 인증
Bearer Token (OAuth 2.0)

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
    "participantCount": 2,
    "lastMessage": "안녕하세요!",
    "lastMessageAt": "2025-01-15T10:30:00",
    "isPinned": false,
    "createdAt": "2025-01-10T15:30:00"
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
GET /api/agora/chats/100/messages?cursorId=999&limit=20
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "messages": [
    {
      "messageId": 999,
      "senderEmail": "user@example.com",
      "senderAgoraId": "john_doe",
      "senderProfileImage": "https://...",
      "content": "반갑습니다!",
      "type": "TEXT",
      "createdAt": "2025-01-15T09:00:00"
    }
  ],
  "hasNext": true,
  "nextCursor": 980
}
```

### Query Parameters
| Name | Type | Description |
|------|------|-------------|
| cursorId | long | 이전 메시지 ID (페이징 용) |
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
  "chatId": 100,
  "senderEmail": "user@example.com",
  "content": "안녕하세요!",
  "type": "TEXT",
  "createdAt": "2025-01-15T10:35:00"
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
