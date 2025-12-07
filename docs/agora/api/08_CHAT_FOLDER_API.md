# 채팅 폴더 API

## Base URL
`/api/agora/chats/folders`

## 인증
Bearer Token (OAuth 2.0)

---

## 1. GET / - 폴더 목록

```http
GET /api/agora/chats/folders
Authorization: Bearer {access_token}
```

### Response 200
```json
[
  {
    "folderId": 1,
    "name": "업무",
    "orderIndex": 1,
    "chatCount": 3,
    "chats": [
      { "chatId": 100, "lastMessage": "...", "lastMessageAt": "..." }
    ],
    "createdAt": "2025-01-10T10:00:00"
  }
]
```

---

## 2. POST / - 폴더 생성

```http
POST /api/agora/chats/folders
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "name": "업무",
  "orderIndex": 1
}
```

### Response 200
```json
{
  "folderId": 1,
  "name": "업무",
  "orderIndex": 1,
  "chatCount": 0,
  "chats": [],
  "createdAt": "2025-01-15T10:30:00"
}
```

---

## 3. PUT /{id} - 폴더 수정

```http
PUT /api/agora/chats/folders/1
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "name": "업무 채팅",
  "orderIndex": 1
}
```

### Response 200
```json
{
  "folderId": 1,
  "name": "업무 채팅",
  "orderIndex": 1,
  "updatedAt": "2025-01-15T11:00:00"
}
```

---

## 4. DELETE /{id} - 폴더 삭제

```http
DELETE /api/agora/chats/folders/1
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "폴더가 삭제되었습니다"
}
```

**주의**: 폴더 내 채팅방은 자동으로 폴더에서 제거됩니다.

---

## 5. POST /{chatId}/folder/{folderId} - 채팅방을 폴더에 추가

```http
POST /api/agora/chats/100/folder/1
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "채팅방이 폴더에 추가되었습니다"
}
```

**중복 방지**: 이미 다른 폴더에 있으면 이동됩니다.

---

## 6. DELETE /{chatId}/folder - 채팅방을 폴더에서 제거

```http
DELETE /api/agora/chats/100/folder
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "채팅방이 폴더에서 제거되었습니다"
}
```

---

## 정렬 순서

폴더와 채팅방은 `orderIndex`로 정렬됩니다.
