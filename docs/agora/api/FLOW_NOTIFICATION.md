# 알림 수신 및 FCM 흐름

## 알림 시스템 개요

```
1. FCM 토큰 등록
   ↓
2. 서버에서 알림 이벤트 감지
   ↓
3. FCM으로 푸시 알림 전송
   ↓
4. 클라이언트가 알림 수신
   ↓
5. 사용자가 알림 탭에서 확인
```

---

## 단계 1: FCM 토큰 등록

### 1-1. Firebase 설정 (클라이언트)

```javascript
import { initializeApp } from 'firebase/app';
import { getMessaging, getToken } from 'firebase/messaging';

const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT.firebaseapp.com",
  projectId: "YOUR_PROJECT",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID"
};

const app = initializeApp(firebaseConfig);
const messaging = getMessaging(app);
```

### 1-2. FCM 토큰 요청

```javascript
getToken(messaging, {
  vapidKey: 'YOUR_VAPID_KEY'
}).then((currentToken) => {
  if (currentToken) {
    console.log('FCM Token:', currentToken);
    // 서버에 토큰 등록
    registerFcmToken(currentToken);
  }
});
```

### 1-3. 서버에 토큰 등록

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

**응답:**
```json
{
  "message": "FCM 토큰이 등록되었습니다"
}
```

---

## 단계 2: 알림 이벤트 발생

서버의 다양한 이벤트에서 알림을 트리거합니다.

### 알림 이벤트 종류

| Event | Trigger | 설명 |
|-------|---------|------|
| FRIEND_REQUEST | 친구 요청 수신 | 친구 요청을 받으면 알림 |
| MESSAGE | 새 메시지 수신 | 채팅방에서 새 메시지 |
| GROUP_INVITE | 그룹 초대 | 그룹 채팅 초대 |
| TEAM_INVITE | 팀 초대 | 팀 멤버 초대 |
| NOTICE | 팀 공지 | 팀 공지 작성 |
| TODO_ASSIGNED | 할일 할당 | 할일이 나에게 할당됨 |
| BIRTHDAY | 생일 | 친구의 생일 |

---

## 단계 3: 서버에서 FCM으로 푸시 발송

내부 로직 예시:

```
사용자 A가 사용자 B에게 친구 요청
  → NotificationService.sendNotification(userB, "FRIEND_REQUEST", ...)
  → FcmService.sendNotificationToUser(userB.id, title, message)
  → Firebase Admin SDK로 FCM 서버에 요청
  → FCM 서버가 사용자 B의 모든 기기로 푸시 발송
```

---

## 단계 4: 클라이언트에서 알림 수신

### 4-1. 포그라운드 알림 (앱이 켜져 있음)

```javascript
import { onMessage } from 'firebase/messaging';

onMessage(messaging, (payload) => {
  console.log('메시지 수신:', payload);
  const { title, body } = payload.notification;

  // UI에 알림 표시 (Toast, Badge 등)
  showNotification(title, body);

  // 또는 상태 업데이트
  setNotifications(prev => [...prev, {
    title,
    body,
    timestamp: new Date()
  }]);
});
```

### 4-2. 백그라운드 알림 (앱이 종료됨)

운영체제가 자동으로 알림 표시. 사용자가 탭하면 앱 실행.

```javascript
// Service Worker에서 처리
self.addEventListener('push', (event) => {
  const data = event.data.json();
  const options = {
    body: data.notification.body,
    icon: '/logo.png',
    badge: '/badge.png',
    tag: data.notification.tag,
    data: data.data
  };

  event.waitUntil(
    self.registration.showNotification(
      data.notification.title,
      options
    )
  );
});
```

---

## 단계 5: 알림 관리

### 5-1. 알림 목록 조회

```http
GET /api/agora/notifications
Authorization: Bearer {access_token}
```

**응답:**
```json
[
  {
    "notificationId": 1,
    "type": "FRIEND_REQUEST",
    "title": "친구 요청",
    "content": "John Doe님이 친구 요청을 보냈습니다",
    "isRead": false,
    "createdAt": "2025-01-15T10:30:00"
  },
  {
    "notificationId": 2,
    "type": "MESSAGE",
    "title": "새 메시지",
    "content": "John Doe: 안녕하세요!",
    "isRead": false,
    "createdAt": "2025-01-15T10:35:00"
  }
]
```

### 5-2. 읽지 않은 알림 수 확인

```http
GET /api/agora/notifications/unread-count
Authorization: Bearer {access_token}
```

**응답:**
```json
{
  "unreadCount": 2
}
```

### 5-3. 알림 읽음 처리

```http
PUT /api/agora/notifications/1/read
Authorization: Bearer {access_token}
```

또는 모두 읽음:

```http
PUT /api/agora/notifications/read-all
Authorization: Bearer {access_token}
```

### 5-4. 알림 삭제

```http
DELETE /api/agora/notifications/1
Authorization: Bearer {access_token}
```

---

## 알림 설정

사용자 설정에서 어떤 알림을 받을지 제어:

```http
PUT /api/agora/settings/notifications
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "pushEnabled": true,
  "messageNotification": true,
  "friendRequestNotification": true,
  "teamNotification": true,
  "soundEnabled": true,
  "vibrationEnabled": true,
  "doNotDisturbStart": "22:00:00",
  "doNotDisturbEnd": "08:00:00"
}
```

---

## 완전한 React 예제

```javascript
import React, { useEffect, useState } from 'react';
import { onMessage, getToken } from 'firebase/messaging';
import { messaging } from './firebase-config';

function NotificationComponent({ accessToken }) {
  const [notifications, setNotifications] = useState([]);
  const [unreadCount, setUnreadCount] = useState(0);

  useEffect(() => {
    // 1. FCM 토큰 등록
    registerFcmToken();

    // 2. 포그라운드 메시지 수신
    const unsubscribe = onMessage(messaging, (payload) => {
      console.log('알림 수신:', payload);
      fetchNotifications(); // 알림 목록 새로고침
      fetchUnreadCount();
    });

    // 3. 초기 알림 목록 로드
    fetchNotifications();
    fetchUnreadCount();

    return () => unsubscribe();
  }, [accessToken]);

  const registerFcmToken = async () => {
    try {
      const token = await getToken(messaging, {
        vapidKey: process.env.REACT_APP_VAPID_KEY
      });

      if (token) {
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
      }
    } catch (error) {
      console.error('FCM 토큰 등록 실패:', error);
    }
  };

  const fetchNotifications = async () => {
    const response = await fetch('/api/agora/notifications', {
      headers: { 'Authorization': `Bearer ${accessToken}` }
    });
    const data = await response.json();
    setNotifications(data);
  };

  const fetchUnreadCount = async () => {
    const response = await fetch('/api/agora/notifications/unread-count', {
      headers: { 'Authorization': `Bearer ${accessToken}` }
    });
    const data = await response.json();
    setUnreadCount(data.unreadCount);
  };

  const markAsRead = async (notificationId) => {
    await fetch(`/api/agora/notifications/${notificationId}/read`, {
      method: 'PUT',
      headers: { 'Authorization': `Bearer ${accessToken}` }
    });
    fetchNotifications();
    fetchUnreadCount();
  };

  return (
    <div>
      <h2>알림 ({unreadCount})</h2>
      {notifications.map(notif => (
        <div key={notif.notificationId}>
          <h4>{notif.title}</h4>
          <p>{notif.content}</p>
          {!notif.isRead && (
            <button onClick={() => markAsRead(notif.notificationId)}>
              읽음 처리
            </button>
          )}
        </div>
      ))}
    </div>
  );
}

export default NotificationComponent;
```

---

## 권장사항

1. **토큰 갱신**: 토큰이 만료되면 자동으로 새 토큰 요청
2. **배경 처리**: 앱이 백그라운드일 때도 알림 수신
3. **방해금지**: 설정된 시간에는 음소거
4. **배치 처리**: 많은 알림이 올 때 성능 최적화
