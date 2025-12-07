# 알림 & FCM API

## Base URL
`/api/agora/notifications`

## 인증
Bearer Token (OAuth 2.0)

---

## 1. GET / - 알림 목록

```http
GET /api/agora/notifications
Authorization: Bearer {access_token}
```

### Response 200
```json
[
  {
    "notificationId": 1,
    "type": "FRIEND_REQUEST",
    "title": "친구 요청",
    "content": "John Doe님이 친구 요청을 보냈습니다",
    "relatedId": 100,
    "isRead": false,
    "createdAt": "2025-01-15T10:30:00"
  },
  {
    "notificationId": 2,
    "type": "MESSAGE",
    "title": "새 메시지",
    "content": "John Doe: 안녕하세요!",
    "relatedId": 200,
    "isRead": true,
    "createdAt": "2025-01-15T10:35:00"
  }
]
```

---

## 2. GET /unread-count - 읽지 않은 알림 수

```http
GET /api/agora/notifications/unread-count
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "unreadCount": 5
}
```

---

## 3. PUT /{id}/read - 알림 읽음 처리

```http
PUT /api/agora/notifications/1/read
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "알림이 읽음 처리되었습니다"
}
```

---

## 4. PUT /read-all - 모든 알림 읽음 처리

```http
PUT /api/agora/notifications/read-all
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "모든 알림이 읽음 처리되었습니다"
}
```

---

## 5. DELETE /{id} - 알림 삭제

```http
DELETE /api/agora/notifications/1
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "알림이 삭제되었습니다"
}
```

---

## 6. POST /fcm-token - FCM 토큰 등록

```http
POST /api/agora/notifications/fcm-token
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "token": "fcm_token_xyz...",
  "deviceName": "iPhone 13",
  "deviceType": "iOS"
}
```

### Response 200
```json
{
  "message": "FCM 토큰이 등록되었습니다"
}
```

---

## 7. DELETE /fcm-token - FCM 토큰 삭제

```http
DELETE /api/agora/notifications/fcm-token
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "token": "fcm_token_xyz..."
}
```

### Response 200
```json
{
  "message": "FCM 토큰이 삭제되었습니다"
}
```

---

## 알림 타입

| Type | 설명 |
|------|------|
| FRIEND_REQUEST | 친구 요청 |
| MESSAGE | 새 메시지 |
| GROUP_INVITE | 그룹 초대 |
| TEAM_INVITE | 팀 초대 |
| NOTICE | 팀 공지 |
| TODO_ASSIGNED | 할일 할당 |
| BIRTHDAY | 생일 |

---

## FCM 알림 수신 (클라이언트)

### JavaScript
```javascript
import { initializeApp } from 'firebase/app';
import { getMessaging, onMessage } from 'firebase/messaging';

const firebaseConfig = { /* ... */ };
const app = initializeApp(firebaseConfig);
const messaging = getMessaging(app);

// 포그라운드 알림
onMessage(messaging, (payload) => {
  console.log('알림 수신:', payload.notification.title);
  // UI 표시
});

// FCM 토큰 등록
const token = await messaging.getToken();
await fetch('/api/agora/notifications/fcm-token', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${accessToken}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    token,
    deviceType: 'web'
  })
});
```

---

## 주의사항

1. **FCM 토큰**: 앱 업데이트/재설치 시 새 토큰 발급
2. **중복 등록**: 같은 토큰 재등록 시 자동 업데이트
3. **배경 알림**: 앱이 백그라운드에서도 알림 수신 가능
