# 채팅 흐름 (1:1 & 그룹)

## 개요

Hyfata의 채팅은 REST API와 WebSocket STOMP를 조합하여 제공됩니다.

- **REST API**: 채팅방 관리, 메시지 조회
- **WebSocket**: 실시간 메시지 송수신

---

## 1:1 채팅 흐름

### 단계 1: 친구와 채팅방 생성/조회

```
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
  "lastMessage": "안녕하세요!",
  "lastMessageAt": "2025-01-15T10:30:00",
  "isPinned": false,
  "createdAt": "2025-01-10T15:30:00",
  "updatedAt": "2025-01-15T10:30:00"
}
```

**주의:**
- 이미 존재하는 채팅방이면 기존 채팅방 반환
- 새 채팅방이면 생성 후 반환

---

### 단계 2: WebSocket 연결

채팅 전에 WebSocket 연결을 수립합니다.

```javascript
// STOMP 클라이언트 생성
const client = new StompJs.Client({
  brokerURL: 'wss://api.hyfata.com/ws/agora/chat',
  connectHeaders: {
    Authorization: `Bearer ${access_token}`
  }
});

client.onConnect = () => {
  console.log('Connected');

  // 채팅방 구독
  client.subscribe(`/topic/agora/chat/100`, (message) => {
    const chatMessage = JSON.parse(message.body);
    console.log('Received:', chatMessage);
  });
};

client.activate();
```

---

### 단계 3: 메시지 전송

#### 3-1. REST API로 전송 (메시지 저장)

```http
POST /api/agora/chats/100/messages
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "content": "안녕하세요!",
  "type": "TEXT"
}
```

**응답:**
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

#### 3-2. WebSocket으로 실시간 브로드캐스트

```javascript
client.publish({
  destination: '/app/agora/chat/100/send',
  body: JSON.stringify({
    messageId: 1000,
    chatId: 100,
    senderEmail: 'user@example.com',
    content: '안녕하세요!',
    type: 'MESSAGE',
    eventType: 'MESSAGE',
    createdAt: '2025-01-15T10:35:00'
  })
});
```

**브로드캐스트되는 메시지 형식:**
```json
{
  "eventType": "MESSAGE",
  "messageId": 1000,
  "chatId": 100,
  "senderEmail": "user@example.com",
  "content": "안녕하세요!",
  "type": "TEXT",
  "createdAt": "2025-01-15T10:35:00"
}
```

**구독 중인 모든 클라이언트가 수신:**
```javascript
// /topic/agora/chat/100 구독자가 메시지 수신
{
  "eventType": "MESSAGE",
  "messageId": 1000,
  ...
}
```

---

### 단계 4: 읽음 처리

메시지를 읽으면 읽음 상태를 서버에 전송합니다.

```javascript
// WebSocket으로 읽음 처리
client.publish({
  destination: '/app/agora/chat/100/read',
  body: JSON.stringify({
    chatId: 100
  })
});
```

**브로드캐스트되는 읽음 메시지:**
```json
{
  "eventType": "READ",
  "chatId": 100,
  "readerEmail": "user@example.com",
  "readAt": "2025-01-15T10:36:00"
}
```

---

### 단계 5: 과거 메시지 조회 (Cursor Pagination)

최초 접속 시 또는 스크롤 시 과거 메시지를 조회합니다.

```http
GET /api/agora/chats/100/messages?cursorId=999&limit=20
Authorization: Bearer {access_token}
```

**Response:**
```json
{
  "messages": [
    {
      "messageId": 999,
      "senderEmail": "john@example.com",
      "content": "반갑습니다!",
      "type": "TEXT",
      "createdAt": "2025-01-15T09:00:00"
    },
    ...
  ],
  "hasNext": true,
  "nextCursor": 980
}
```

---

## 그룹 채팅 흐름

### 단계 1: 그룹 채팅방 생성

```http
POST /api/agora/chats/groups
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "name": "개발팀 채팅",
  "memberAgoraIds": ["john_doe", "jane_smith", "bob_lee"]
}
```

**응답:**
```json
{
  "groupChatId": 101,
  "name": "개발팀 채팅",
  "creatorEmail": "admin@example.com",
  "memberCount": 4,
  "members": [
    { "userId": 100, "email": "admin@example.com", "agoraId": "admin" },
    { "userId": 101, "email": "john@example.com", "agoraId": "john_doe" },
    ...
  ],
  "createdAt": "2025-01-15T10:30:00"
}
```

---

### 단계 2: 그룹에 멤버 초대

```http
POST /api/agora/chats/groups/101/members
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "memberAgoraIds": ["new_user"]
}
```

---

### 단계 3: 메시지 송수신

1:1 채팅과 동일하게 REST API + WebSocket 조합

```javascript
// 그룹 채팅방 구독
client.subscribe(`/topic/agora/chat/101`, (message) => {
  const chatMessage = JSON.parse(message.body);
  // 모든 멤버가 수신
});

// 메시지 전송
client.publish({
  destination: '/app/agora/chat/101/send',
  body: JSON.stringify({
    messageId: 2000,
    chatId: 101,
    senderEmail: 'user@example.com',
    content: '안녕하세요!',
    type: 'MESSAGE',
    eventType: 'MESSAGE'
  })
});
```

---

## 메시지 타입

| Type | 설명 |
|------|------|
| TEXT | 일반 텍스트 메시지 |
| IMAGE | 이미지 메시지 |
| FILE | 파일 메시지 |
| NOTICE | 시스템 공지 |

---

## 채팅 폴더 관리

채팅방을 폴더로 정리합니다.

### 폴더 생성
```http
POST /api/agora/chats/folders
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "name": "업무",
  "orderIndex": 1
}
```

### 채팅방을 폴더에 추가
```http
POST /api/agora/chats/100/folder/1
Authorization: Bearer {access_token}
```

### 채팅방을 폴더에서 제거
```http
DELETE /api/agora/chats/100/folder
Authorization: Bearer {access_token}
```

---

## 완전한 실시간 채팅 예제

### JavaScript (React 예시)

```javascript
import React, { useState, useEffect } from 'react';
import SockJS from 'sockjs-client';
import StompJs from '@stomp/stompjs';

function ChatComponent({ chatId, accessToken }) {
  const [messages, setMessages] = useState([]);
  const [client, setClient] = useState(null);

  useEffect(() => {
    // WebSocket 연결
    const socketClient = new StompJs.Client({
      brokerURL: 'wss://api.hyfata.com/ws/agora/chat',
      connectHeaders: {
        Authorization: `Bearer ${accessToken}`
      }
    });

    socketClient.onConnect = () => {
      console.log('Connected to WebSocket');

      // 채팅방 구독
      socketClient.subscribe(`/topic/agora/chat/${chatId}`, (message) => {
        const chatMessage = JSON.parse(message.body);
        setMessages(prev => [...prev, chatMessage]);
      });
    };

    socketClient.activate();
    setClient(socketClient);

    return () => {
      if (socketClient) socketClient.deactivate();
    };
  }, [chatId, accessToken]);

  const sendMessage = (content) => {
    if (client && client.connected) {
      client.publish({
        destination: `/app/agora/chat/${chatId}/send`,
        body: JSON.stringify({
          content,
          type: 'TEXT'
        })
      });
    }
  };

  return (
    <div>
      <div className="messages">
        {messages.map(msg => (
          <div key={msg.messageId}>{msg.content}</div>
        ))}
      </div>
      <input
        onKeyPress={(e) => {
          if (e.key === 'Enter') {
            sendMessage(e.target.value);
            e.target.value = '';
          }
        }}
      />
    </div>
  );
}

export default ChatComponent;
```

---

## 주의사항

1. **WebSocket 연결 유지**: 앱이 백그라운드로 가면 연결 해제 후 복귀 시 재연결
2. **메시지 중복 방지**: REST API로 저장 후 WebSocket으로 브로드캐스트 (정확히 한 번)
3. **읽음 처리**: 대량의 읽음 메시지로 인한 과부하 방지 (배치 처리 권장)
4. **파일 전송**: 파일은 별도 API(`/api/agora/files/upload`)로 업로드 후 URL을 메시지에 포함
5. **오프라인 메시지**: WebSocket이 끊어진 동안의 메시지는 REST API로 조회
