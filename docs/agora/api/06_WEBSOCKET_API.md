# WebSocket 실시간 채팅 API (STOMP)

## 연결 정보

**WebSocket URL:**
```
wss://api.hyfata.com/ws/agora/chat
```

**인증:**
```
Authorization: Bearer {access_token}
```

---

## STOMP 프로토콜

### 연결 (CONNECT)

```javascript
const client = new StompJs.Client({
  brokerURL: 'wss://api.hyfata.com/ws/agora/chat',
  connectHeaders: {
    Authorization: `Bearer ${access_token}`
  }
});

client.onConnect = () => {
  console.log('Connected');
};

client.activate();
```

---

## 구독 (SUBSCRIBE)

### 채팅방 메시지 구독

특정 채팅방의 모든 메시지와 이벤트를 수신합니다.

```javascript
client.subscribe(`/topic/agora/chat/{chatId}`, (message) => {
  const data = JSON.parse(message.body);
  console.log('Event Type:', data.eventType);
});
```

**수신 가능한 이벤트:**

#### MESSAGE - 새 메시지
```json
{
  "eventType": "MESSAGE",
  "messageId": 1000,
  "chatId": 100,
  "senderEmail": "user@example.com",
  "senderAgoraId": "john_doe",
  "senderProfileImage": "https://...",
  "content": "안녕하세요!",
  "type": "TEXT",
  "createdAt": "2025-01-15T10:35:00"
}
```

#### READ - 읽음 처리
```json
{
  "eventType": "READ",
  "chatId": 100,
  "readerEmail": "user@example.com",
  "readAt": "2025-01-15T10:36:00"
}
```

#### USER_JOIN - 사용자 입장 (그룹 채팅)
```json
{
  "eventType": "USER_JOIN",
  "chatId": 100,
  "userId": 100,
  "userEmail": "user@example.com"
}
```

#### USER_LEAVE - 사용자 퇴장 (그룹 채팅)
```json
{
  "eventType": "USER_LEAVE",
  "chatId": 100,
  "userId": 100,
  "userEmail": "user@example.com"
}
```

---

## 발행 (SEND)

### 메시지 전송

특정 채팅방에 메시지를 전송합니다.

```javascript
client.publish({
  destination: `/app/agora/chat/{chatId}/send`,
  body: JSON.stringify({
    content: "안녕하세요!",
    type: "TEXT"
  })
});
```

**메시지 본문:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| content | string | Yes | 메시지 내용 |
| type | string | Yes | TEXT, IMAGE, FILE |
| replyToId | long | No | 답장할 메시지 ID |

---

### 읽음 처리

채팅방의 메시지를 읽음 처리합니다.

```javascript
client.publish({
  destination: `/app/agora/chat/{chatId}/read`,
  body: JSON.stringify({})
});
```

---

## 개인 메시지 큐 (선택사항)

에러 메시지 등을 개인적으로 수신합니다.

```javascript
client.subscribe(`/user/queue/errors`, (message) => {
  const error = JSON.parse(message.body);
  console.error('Error:', error.message);
});
```

---

## 연결 해제 (DISCONNECT)

```javascript
client.deactivate();
```

---

## 완전한 예제 (React)

```javascript
import React, { useEffect, useState } from 'react';
import StompJs from '@stomp/stompjs';

function ChatComponent({ chatId, accessToken }) {
  const [messages, setMessages] = useState([]);
  const [client, setClient] = useState(null);

  useEffect(() => {
    const socketClient = new StompJs.Client({
      brokerURL: 'wss://api.hyfata.com/ws/agora/chat',
      connectHeaders: {
        Authorization: `Bearer ${accessToken}`
      }
    });

    socketClient.onConnect = () => {
      // 채팅방 구독
      socketClient.subscribe(`/topic/agora/chat/${chatId}`, (message) => {
        const event = JSON.parse(message.body);

        if (event.eventType === 'MESSAGE') {
          setMessages(prev => [...prev, event]);
        } else if (event.eventType === 'READ') {
          console.log('User read messages:', event.readerEmail);
        }
      });

      // 에러 큐 구독
      socketClient.subscribe('/user/queue/errors', (message) => {
        const error = JSON.parse(message.body);
        console.error('Error:', error.message);
      });
    };

    socketClient.activate();
    setClient(socketClient);

    return () => socketClient.deactivate();
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

  const markAsRead = () => {
    if (client && client.connected) {
      client.publish({
        destination: `/app/agora/chat/${chatId}/read`,
        body: '{}'
      });
    }
  };

  return (
    <div>
      <div className="messages">
        {messages.map(msg => (
          <div key={msg.messageId}>
            <strong>{msg.senderAgoraId}:</strong> {msg.content}
          </div>
        ))}
      </div>
      <input
        onKeyPress={(e) => {
          if (e.key === 'Enter' && e.target.value) {
            sendMessage(e.target.value);
            e.target.value = '';
            markAsRead();
          }
        }}
        placeholder="메시지 입력..."
      />
    </div>
  );
}

export default ChatComponent;
```

---

## 필요한 라이브러리

```bash
npm install @stomp/stompjs sockjs-client
```

---

## 주의사항

1. **연결 유지**: 백그라운드 전환 시 자동 재연결 구현 권장
2. **구독 관리**: 채팅방 퇴장 시 구독 해제
3. **하트비트**: 30초마다 연결 확인 (자동)
4. **메시지 순서**: WebSocket 메시지 순서 보장
5. **오프라인 처리**: 연결 끊김 시 REST API로 이전 메시지 조회
