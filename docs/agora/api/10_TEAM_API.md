# 팀 관리 API

## Base URL
`/api/agora/teams`

## 인증
Bearer Token (OAuth 2.0)

---

## 1. GET / - 팀 목록 조회

사용자가 속한 팀 목록을 조회합니다.

### Request
```http
GET /api/agora/teams
Authorization: Bearer {access_token}
```

### Response 200
```json
[
  {
    "teamId": 1,
    "name": "개발팀",
    "description": "백엔드 개발 팀",
    "profileImage": "https://cdn.hyfata.com/teams/dev-team.jpg",
    "isMain": false,
    "creatorEmail": "admin@example.com",
    "memberCount": 5,
    "createdAt": "2025-01-01T10:00:00",
    "updatedAt": "2025-01-15T10:00:00"
  }
]
```

---

## 2. POST / - 팀 생성

새로운 팀을 생성합니다. 생성자는 자동으로 ADMIN 역할을 부여받습니다.

### Request
```http
POST /api/agora/teams
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "name": "개발팀",
  "description": "백엔드 개발 팀",
  "profileImage": "https://cdn.hyfata.com/teams/dev-team.jpg"
}
```

### Response 200
```json
{
  "teamId": 1,
  "name": "개발팀",
  "description": "백엔드 개발 팀",
  "profileImage": "https://cdn.hyfata.com/teams/dev-team.jpg",
  "isMain": false,
  "creatorEmail": "admin@example.com",
  "memberCount": 1,
  "createdAt": "2025-01-15T10:30:00",
  "updatedAt": "2025-01-15T10:30:00"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 400 | INVALID_NAME | 팀 이름이 유효하지 않습니다 |

---

## 3. GET /{id} - 팀 상세 조회

팀의 상세 정보를 조회합니다.

### Request
```http
GET /api/agora/teams/1
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "teamId": 1,
  "name": "개발팀",
  "description": "백엔드 개발 팀",
  "profileImage": "https://cdn.hyfata.com/teams/dev-team.jpg",
  "isMain": false,
  "creatorEmail": "admin@example.com",
  "memberCount": 5,
  "createdAt": "2025-01-01T10:00:00",
  "updatedAt": "2025-01-15T10:00:00"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 404 | TEAM_NOT_FOUND | 팀을 찾을 수 없습니다 |
| 403 | NOT_TEAM_MEMBER | 팀의 멤버가 아닙니다 |

---

## 4. PUT /{id} - 팀 정보 수정

팀의 정보를 수정합니다. **팀 생성자만 가능합니다.**

### Request
```http
PUT /api/agora/teams/1
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "name": "개발팀 (수정)",
  "description": "백엔드 및 프론트엔드 개발 팀",
  "profileImage": "https://cdn.hyfata.com/teams/dev-team-updated.jpg"
}
```

### Response 200
```json
{
  "teamId": 1,
  "name": "개발팀 (수정)",
  "description": "백엔드 및 프론트엔드 개발 팀",
  "profileImage": "https://cdn.hyfata.com/teams/dev-team-updated.jpg",
  "isMain": false,
  "creatorEmail": "admin@example.com",
  "memberCount": 5,
  "createdAt": "2025-01-01T10:00:00",
  "updatedAt": "2025-01-15T11:00:00"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 403 | FORBIDDEN | 팀 생성자만 수정 가능합니다 |

---

## 5. DELETE /{id} - 팀 삭제

팀을 삭제합니다. **팀 생성자만 가능합니다.**

### Request
```http
DELETE /api/agora/teams/1
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "팀이 삭제되었습니다"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 403 | FORBIDDEN | 팀 생성자만 삭제 가능합니다 |

---

## 6. GET /{id}/members - 팀원 목록 조회

팀의 멤버 목록을 조회합니다.

### Request
```http
GET /api/agora/teams/1/members
Authorization: Bearer {access_token}
```

### Response 200
```json
[
  {
    "memberId": 1,
    "userId": 100,
    "userEmail": "admin@example.com",
    "roleName": "admin",
    "joinedAt": "2025-01-01T10:00:00"
  },
  {
    "memberId": 2,
    "userId": 101,
    "userEmail": "user1@example.com",
    "roleName": "member",
    "joinedAt": "2025-01-05T15:30:00"
  }
]
```

---

## 7. POST /{id}/members - 팀원 초대

팀에 새로운 멤버를 초대합니다. **팀 생성자만 가능합니다.**

### Request
```http
POST /api/agora/teams/1/members?userEmail=newuser@example.com
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "memberId": 3,
  "userId": 102,
  "userEmail": "newuser@example.com",
  "roleName": "member",
  "joinedAt": "2025-01-15T11:30:00"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 404 | USER_NOT_FOUND | 사용자를 찾을 수 없습니다 |
| 409 | ALREADY_MEMBER | 이미 팀의 멤버입니다 |
| 403 | FORBIDDEN | 팀 생성자만 초대 가능합니다 |

### Query Parameters
| Name | Type | Required | Description |
|------|------|----------|-------------|
| userEmail | string | Yes | 초대할 사용자의 이메일 |

---

## 8. DELETE /{id}/members/{memberId} - 팀원 제거

팀에서 멤버를 제거합니다. **팀 생성자만 가능합니다.**

### Request
```http
DELETE /api/agora/teams/1/members/2
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "멤버가 제거되었습니다"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 403 | FORBIDDEN | 팀 생성자만 제거 가능합니다 |
| 403 | CANNOT_REMOVE_CREATOR | 생성자는 제거할 수 없습니다 |

---

## 9. PUT /{id}/members/{memberId}/role - 멤버 역할 변경

멤버의 역할을 변경합니다. **팀 생성자만 가능합니다.**

### Request
```http
PUT /api/agora/teams/1/members/2/role?roleName=admin
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "멤버 역할이 변경되었습니다"
}
```

### Query Parameters
| Name | Type | Required | Description |
|------|------|----------|-------------|
| roleName | string | Yes | 변경할 역할명 (admin, member) |

---

## 팀 역할

| 역할 | 권한 | 설명 |
|------|------|------|
| admin | 모든 권한 | 팀 수정, 멤버 관리, 공지/할일/일정 관리 |
| member | 읽기 및 기본 쓰기 | 채팅, 프로필 조회, 공지 읽기 |

---

## 주의사항

1. **팀 생성자**: 팀을 생성한 사용자만 팀 수정/삭제 가능
2. **멤버 관리**: 생성자만 멤버 초대/제거/역할 변경 가능
3. **팀 프로필**: 팀원들이 팀 내에서 사용할 프로필 설정은 별도의 팀 프로필 API 사용
