# 친구 관리 API

## Base URL
`/api/agora/friends`

## 인증
Bearer Token (OAuth 2.0)

---

## 1. GET / - 친구 목록 조회

내 친구 목록을 조회합니다.

### Request
```http
GET /api/agora/friends
Authorization: Bearer {access_token}
```

### Response 200
```json
[
  {
    "friendId": 1,
    "agoraId": "john_doe",
    "displayName": "John Doe",
    "profileImage": "https://cdn.hyfata.com/profiles/john_doe.jpg",
    "isFavorite": true,
    "createdAt": "2025-01-10T15:30:00"
  },
  {
    "friendId": 2,
    "agoraId": "jane_smith",
    "displayName": "Jane Smith",
    "profileImage": "https://cdn.hyfata.com/profiles/jane_smith.jpg",
    "isFavorite": false,
    "createdAt": "2025-01-12T10:15:00"
  }
]
```

---

## 2. POST /request - 친구 요청

다른 사용자에게 친구 요청을 보냅니다.

### Request
```http
POST /api/agora/friends/request
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "agoraId": "john_doe"
}
```

### Response 200
```json
{
  "requestId": 1,
  "fromUserId": 100,
  "fromAgoraId": "my_id",
  "fromDisplayName": "My Name",
  "fromProfileImage": "https://cdn.hyfata.com/profiles/my_id.jpg",
  "toUserId": 200,
  "status": "PENDING",
  "createdAt": "2025-01-15T10:30:00",
  "updatedAt": "2025-01-15T10:30:00"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 404 | USER_NOT_FOUND | 사용자를 찾을 수 없습니다 |
| 409 | ALREADY_FRIENDS | 이미 친구입니다 |
| 409 | REQUEST_ALREADY_SENT | 이미 요청을 보냈습니다 |

---

## 3. GET /requests - 받은 친구 요청 목록

받은 친구 요청 목록을 조회합니다.

### Request
```http
GET /api/agora/friends/requests
Authorization: Bearer {access_token}
```

### Response 200
```json
[
  {
    "requestId": 1,
    "fromUserId": 100,
    "fromAgoraId": "john_doe",
    "fromDisplayName": "John Doe",
    "fromProfileImage": "https://cdn.hyfata.com/profiles/john_doe.jpg",
    "toUserId": 200,
    "status": "PENDING",
    "createdAt": "2025-01-13T15:30:00",
    "updatedAt": "2025-01-13T15:30:00"
  }
]
```

---

## 4. POST /requests/{id}/accept - 친구 요청 수락

받은 친구 요청을 수락합니다.

### Request
```http
POST /api/agora/friends/requests/1/accept
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "friendId": 1,
  "agoraId": "john_doe",
  "displayName": "John Doe",
  "profileImage": "https://cdn.hyfata.com/profiles/john_doe.jpg",
  "isFavorite": false,
  "createdAt": "2025-01-15T10:35:00"
}
```

---

## 5. DELETE /requests/{id} - 친구 요청 거절

받은 친구 요청을 거절합니다.

### Request
```http
DELETE /api/agora/friends/requests/1
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "친구 요청이 거절되었습니다"
}
```

---

## 6. DELETE /{friendId} - 친구 삭제

친구를 삭제합니다.

### Request
```http
DELETE /api/agora/friends/1
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "친구가 삭제되었습니다"
}
```

---

## 7. POST /{friendId}/favorite - 즐겨찾기 추가

친구를 즐겨찾기에 추가합니다.

### Request
```http
POST /api/agora/friends/1/favorite
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "즐겨찾기에 추가되었습니다"
}
```

---

## 8. DELETE /{friendId}/favorite - 즐겨찾기 제거

친구를 즐겨찾기에서 제거합니다.

### Request
```http
DELETE /api/agora/friends/1/favorite
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "즐겨찾기에서 제거되었습니다"
}
```

---

## 9. POST /{friendId}/block - 사용자 차단

사용자를 차단합니다. 차단 시 친구 관계도 자동으로 삭제됩니다.

### Request
```http
POST /api/agora/friends/1/block
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "사용자가 차단되었습니다"
}
```

---

## 10. DELETE /{friendId}/block - 사용자 차단 해제

차단한 사용자를 차단 해제합니다.

### Request
```http
DELETE /api/agora/friends/1/block
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "차단이 해제되었습니다"
}
```

---

## 11. GET /blocked - 차단 목록

차단한 사용자 목록을 조회합니다.

### Request
```http
GET /api/agora/friends/blocked
Authorization: Bearer {access_token}
```

### Response 200
```json
[
  {
    "blockedUserId": 300,
    "agoraId": "blocked_user",
    "displayName": "Blocked User",
    "profileImage": "https://cdn.hyfata.com/profiles/blocked_user.jpg",
    "blockedAt": "2025-01-14T12:00:00"
  }
]
```

---

## 12. GET /birthdays - 생일 목록

7일 이내 생일인 친구 목록을 조회합니다 (현재 달 경계 포함).

### Request
```http
GET /api/agora/friends/birthdays
Authorization: Bearer {access_token}
```

### Response 200
```json
[
  {
    "friendId": 1,
    "agoraId": "john_doe",
    "displayName": "John Doe",
    "profileImage": "https://cdn.hyfata.com/profiles/john_doe.jpg",
    "birthday": "1990-01-18",
    "daysUntilBirthday": 3
  }
]
```

---

## 친구 요청 상태

| Status | 설명 |
|--------|------|
| PENDING | 대기 중 |
| ACCEPTED | 수락됨 |
| REJECTED | 거절됨 |

---

## 주의사항

1. **양방향 친구 관계**: 친구 관계는 양방향입니다.
2. **차단과 친구 관계**: 사용자를 차단하면 자동으로 친구 관계가 삭제됩니다.
3. **생일 조회**: 생일이 공개 설정인 친구만 표시됩니다.
4. **요청 제한**: 중복 요청은 할 수 없습니다.
