# 팀 부가 기능 API (공지/할일/일정)

## 인증
Bearer Token (OAuth 2.0)

---

## 팀 공지 (Notice) API

### Base URL
`/api/agora/teams/{teamId}/notices`

#### 1. GET / - 공지 목록
```http
GET /api/agora/teams/1/notices
Authorization: Bearer {access_token}
```

**응답:**
```json
[
  {
    "noticeId": 1,
    "teamId": 1,
    "authorEmail": "admin@example.com",
    "title": "공지사항",
    "content": "내용",
    "isPinned": true,
    "createdAt": "2025-01-10T10:00:00"
  }
]
```

#### 2. GET /{id} - 공지 상세
```http
GET /api/agora/teams/1/notices/1
Authorization: Bearer {access_token}
```

#### 3. POST / - 공지 작성 (관리자만)
```http
POST /api/agora/teams/1/notices
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "title": "중요 공지",
  "content": "내용",
  "isPinned": false
}
```

#### 4. PUT /{id} - 공지 수정 (관리자만)
```http
PUT /api/agora/teams/1/notices/1
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "title": "수정된 제목",
  "content": "수정된 내용",
  "isPinned": true
}
```

#### 5. DELETE /{id} - 공지 삭제 (관리자만)
```http
DELETE /api/agora/teams/1/notices/1
Authorization: Bearer {access_token}
```

---

## 팀 할일 (Todo) API

### Base URL
`/api/agora/teams/{teamId}/todos`

#### 1. GET / - 할일 목록
```http
GET /api/agora/teams/1/todos
Authorization: Bearer {access_token}
```

**응답:**
```json
[
  {
    "todoId": 1,
    "teamId": 1,
    "createdByEmail": "admin@example.com",
    "assignedToEmail": "user@example.com",
    "title": "문서 작성",
    "description": "API 문서 작성",
    "status": "TODO",
    "priority": "HIGH",
    "dueDate": "2025-01-20T23:59:59",
    "completedAt": null,
    "createdAt": "2025-01-10T10:00:00"
  }
]
```

#### 2. GET /{id} - 할일 상세
```http
GET /api/agora/teams/1/todos/1
Authorization: Bearer {access_token}
```

#### 3. POST / - 할일 생성
```http
POST /api/agora/teams/1/todos
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "title": "버그 수정",
  "description": "로그인 버그 해결",
  "assignedToId": 101,
  "priority": "HIGH",
  "dueDate": "2025-01-25T23:59:59"
}
```

#### 4. PUT /{id} - 할일 수정
```http
PUT /api/agora/teams/1/todos/1
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "title": "버그 수정 (긴급)",
  "priority": "HIGH",
  "dueDate": "2025-01-22T23:59:59"
}
```

#### 5. PUT /{id}/complete - 할일 완료
```http
PUT /api/agora/teams/1/todos/1/complete
Authorization: Bearer {access_token}
```

**응답:**
```json
{
  "status": "DONE",
  "completedAt": "2025-01-15T14:30:00"
}
```

#### 6. DELETE /{id} - 할일 삭제
```http
DELETE /api/agora/teams/1/todos/1
Authorization: Bearer {access_token}
```

---

## 팀 일정 (Event) API

### Base URL
`/api/agora/teams/{teamId}/events`

#### 1. GET / - 일정 목록
```http
GET /api/agora/teams/1/events
Authorization: Bearer {access_token}
```

**응답:**
```json
[
  {
    "eventId": 1,
    "teamId": 1,
    "createdByEmail": "admin@example.com",
    "title": "팀 회의",
    "description": "주간 회의",
    "location": "회의실 A",
    "startTime": "2025-01-20T14:00:00",
    "endTime": "2025-01-20T15:00:00",
    "isAllDay": false,
    "createdAt": "2025-01-10T10:00:00"
  }
]
```

#### 2. GET /{id} - 일정 상세
```http
GET /api/agora/teams/1/events/1
Authorization: Bearer {access_token}
```

#### 3. POST / - 일정 생성 (관리자만)
```http
POST /api/agora/teams/1/events
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "title": "팀 OT",
  "description": "새로운 프로젝트 소개",
  "location": "온라인",
  "startTime": "2025-01-25T10:00:00",
  "endTime": "2025-01-25T11:00:00",
  "isAllDay": false
}
```

#### 4. PUT /{id} - 일정 수정 (관리자만)
```http
PUT /api/agora/teams/1/events/1
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "title": "팀 회의 (변경됨)",
  "startTime": "2025-01-20T15:00:00",
  "endTime": "2025-01-20T16:00:00"
}
```

#### 5. DELETE /{id} - 일정 삭제 (관리자만)
```http
DELETE /api/agora/teams/1/events/1
Authorization: Bearer {access_token}
```

---

## 상태 및 우선순위

### 할일 상태
| Status | 설명 |
|--------|------|
| TODO | 시작 전 |
| IN_PROGRESS | 진행 중 |
| DONE | 완료 |

### 할일 우선순위
| Priority | 설명 |
|----------|------|
| LOW | 낮음 |
| MEDIUM | 중간 |
| HIGH | 높음 |

---

## 권한 관리

| 기능 | 팀 생성자 | 팀원 |
|------|----------|------|
| 공지 작성/수정/삭제 | O | X |
| 할일 생성 | O | O |
| 할일 수정/삭제 | O | O (자신의 할일만) |
| 할일 완료 | O | O (할당받은 할일만) |
| 일정 작성/수정/삭제 | O | X |
