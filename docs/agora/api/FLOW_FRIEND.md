# 친구 추가 흐름

## 친구 추가 방식

1. **agoraId 검색**
2. **친구 요청 전송**
3. **요청 수락/거절**
4. **채팅 시작**

---

## 단계 1: 사용자 검색

친구로 추가할 사용자를 검색합니다.

```http
GET /api/agora/profile/search?keyword=john
Authorization: Bearer {access_token}
```

**응답:**
```json
[
  {
    "agoraId": "john_doe",
    "displayName": "John Doe",
    "profileImage": "https://..."
  }
]
```

---

## 단계 2: 친구 요청 전송

검색 결과에서 사용자를 선택하고 친구 요청을 전송합니다.

```http
POST /api/agora/friends/request
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "agoraId": "john_doe"
}
```

**응답:**
```json
{
  "requestId": 1,
  "fromAgoraId": "my_id",
  "status": "PENDING",
  "createdAt": "2025-01-15T10:30:00"
}
```

**에러 처리:**
```json
{
  "error": "ALREADY_FRIENDS",
  "message": "이미 친구입니다"
}
```

또는

```json
{
  "error": "REQUEST_ALREADY_SENT",
  "message": "이미 요청을 보냈습니다"
}
```

---

## 단계 3: 친구 요청 수신 및 관리

### 3-1. 받은 요청 목록 조회

```http
GET /api/agora/friends/requests
Authorization: Bearer {access_token}
```

**응답:**
```json
[
  {
    "requestId": 1,
    "fromAgoraId": "john_doe",
    "fromDisplayName": "John Doe",
    "fromProfileImage": "https://...",
    "status": "PENDING",
    "createdAt": "2025-01-13T15:30:00"
  }
]
```

### 3-2. 친구 요청 수락

```http
POST /api/agora/friends/requests/1/accept
Authorization: Bearer {access_token}
```

**응답:**
```json
{
  "friendId": 1,
  "agoraId": "john_doe",
  "displayName": "John Doe",
  "profileImage": "https://...",
  "isFavorite": false,
  "createdAt": "2025-01-15T10:35:00"
}
```

**결과:**
- 친구 관계 양방향 생성
- 서로 채팅 가능

### 3-3. 친구 요청 거절

```http
DELETE /api/agora/friends/requests/1
Authorization: Bearer {access_token}
```

---

## 단계 4: 친구 목록 확인

```http
GET /api/agora/friends
Authorization: Bearer {access_token}
```

**응답:**
```json
[
  {
    "friendId": 1,
    "agoraId": "john_doe",
    "displayName": "John Doe",
    "profileImage": "https://...",
    "isFavorite": false,
    "createdAt": "2025-01-15T10:35:00"
  }
]
```

---

## 단계 5: 채팅 시작

친구와의 1:1 채팅을 시작합니다.

```http
POST /api/agora/chats
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "targetAgoraId": "john_doe"
}
```

**응답:**
```json
{
  "chatId": 100,
  "participantCount": 2,
  "createdAt": "2025-01-15T10:40:00"
}
```

이후 WebSocket으로 실시간 메시지 송수신 시작.

---

## 친구 관리 기능

### 즐겨찾기 추가

```http
POST /api/agora/friends/1/favorite
Authorization: Bearer {access_token}
```

→ 친구 목록에서 상단에 고정

### 친구 삭제

```http
DELETE /api/agora/friends/1
Authorization: Bearer {access_token}
```

→ 친구 관계 해제 (채팅은 유지)

### 사용자 차단

```http
POST /api/agora/friends/1/block
Authorization: Bearer {access_token}
```

→ 친구 관계 해제 + 메시지 차단

---

## UI/UX 흐름도

```
홈 화면
  ↓
[친구 추가] 버튼
  ↓
검색 화면
  ├─ 사용자 검색
  └─ 검색 결과 표시
      └─ [친구 요청] 버튼
  ↓
요청 전송 완료
  ↓
상대방의 수락/거절 대기
  ↓
(수락 시) 친구 추가 완료
  └─ 채팅 시작 가능
```

---

## 권장사항

1. **검색 최적화**
   - agoraId 기반 정확한 검색 우선
   - displayName도 함께 검색

2. **요청 상태 표시**
   - "대기 중" - 상대방이 아직 수락하지 않음
   - "수락됨" - 친구 추가 완료
   - "거절됨" - 상대방이 거절함

3. **알림**
   - 친구 요청 받으면 PUSH 알림
   - 요청 수락/거절 시 알림
