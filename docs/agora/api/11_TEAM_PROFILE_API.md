# 팀 프로필 API

## Base URL
`/api/agora/team-profile`

## 인증
Bearer Token (OAuth 2.0)

---

## 개요

Agora에는 두 가지 프로필이 있습니다:
- **개인 프로필 (AgoraUserProfile)**: 친구 컨텍스트에서 사용 (`/api/agora/profile`)
- **팀 프로필 (TeamProfile)**: 팀 컨텍스트에서 사용 (`/api/agora/team-profile`)

사용자당 각각 1개씩 생성 가능합니다.

---

## 1. GET / - 내 팀 프로필 조회

현재 로그인한 사용자의 팀 프로필을 조회합니다.

### Request
```http
GET /api/agora/team-profile
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "userId": 100,
  "userEmail": "user@example.com",
  "displayName": "John (Team)",
  "profileImage": "https://cdn.hyfata.com/profiles/team_john.jpg",
  "bio": "백엔드 개발자입니다",
  "createdAt": "2025-01-10T10:00:00",
  "updatedAt": "2025-01-15T10:00:00"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 400 | PROFILE_NOT_FOUND | 팀 프로필이 없습니다 |

---

## 2. POST / - 팀 프로필 생성

팀 컨텍스트에서 사용할 프로필을 생성합니다.

### Request
```http
POST /api/agora/team-profile
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "displayName": "John (Team)",
  "profileImage": "https://cdn.hyfata.com/profiles/team_john.jpg"
}
```

### Response 200
```json
{
  "userId": 100,
  "userEmail": "user@example.com",
  "displayName": "John (Team)",
  "profileImage": "https://cdn.hyfata.com/profiles/team_john.jpg",
  "bio": null,
  "createdAt": "2025-01-15T10:30:00",
  "updatedAt": "2025-01-15T10:30:00"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 400 | PROFILE_ALREADY_EXISTS | 이미 팀 프로필이 있습니다 |

---

## 3. PUT / - 팀 프로필 수정

```http
PUT /api/agora/team-profile?displayName=Kim팀장&bio=프론트엔드 개발자
Authorization: Bearer {access_token}
```

### Query Parameters
| Name | Type | Required | Description |
|------|------|----------|-------------|
| displayName | string | No | 표시 이름 |
| profileImage | string | No | 프로필 이미지 URL |
| bio | string | No | 자기소개 |

### Response 200
```json
{
  "userId": 100,
  "userEmail": "user@example.com",
  "displayName": "Kim팀장",
  "profileImage": "https://cdn.hyfata.com/profiles/team_kim.jpg",
  "bio": "프론트엔드 개발자",
  "createdAt": "2025-01-01T10:00:00",
  "updatedAt": "2025-01-15T11:00:00"
}
```

---

## 4. PUT /image - 프로필 이미지 변경

```http
PUT /api/agora/team-profile/image?profileImage=https://cdn.hyfata.com/profiles/new.jpg
Authorization: Bearer {access_token}
```

### Query Parameters
| Name | Type | Required | Description |
|------|------|----------|-------------|
| profileImage | string | Yes | 프로필 이미지 URL |

### Response 200
```json
{
  "userId": 100,
  "userEmail": "user@example.com",
  "displayName": "Kim팀장",
  "profileImage": "https://cdn.hyfata.com/profiles/new.jpg",
  "bio": "프론트엔드 개발자",
  "createdAt": "2025-01-01T10:00:00",
  "updatedAt": "2025-01-15T11:05:00"
}
```

---

## 5. GET /users/{userId} - 다른 사용자 팀 프로필 조회

다른 사용자의 팀 프로필을 조회합니다.

### Request
```http
GET /api/agora/team-profile/users/101
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "userId": 101,
  "userEmail": "john@example.com",
  "displayName": "John (Team Lead)",
  "profileImage": "https://cdn.hyfata.com/profiles/team_john_lead.jpg",
  "bio": "팀 리더입니다",
  "createdAt": "2025-01-10T10:00:00",
  "updatedAt": "2025-01-12T10:00:00"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 400 | PROFILE_NOT_FOUND | 팀 프로필을 찾을 수 없습니다 |

---

## 6. GET /exists - 팀 프로필 존재 여부 확인

현재 사용자의 팀 프로필 존재 여부를 확인합니다.

### Request
```http
GET /api/agora/team-profile/exists
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "exists": true
}
```

---

## 프로필 필드

| 필드 | 타입 | 요구사항 |
|------|------|---------|
| displayName | string | 필수, 1-100자 |
| profileImage | URL | 선택 |
| bio | string | 선택, 최대 500자 |

---

## 프로필 비교

| 항목 | 개인 프로필 (AgoraUserProfile) | 팀 프로필 (TeamProfile) |
|------|-------------------------------|------------------------|
| 용도 | 친구 컨텍스트 | 팀 컨텍스트 |
| 식별자 | agoraId (고유) | userId |
| 필드 | displayName, profileImage, bio, phone, birthday | displayName, profileImage, bio |
| API | `/api/agora/profile` | `/api/agora/team-profile` |

---

## 사용 시나리오

1. **친구와 채팅할 때**: 개인 프로필 (AgoraUserProfile) 표시
2. **팀 채팅/팀 활동할 때**: 팀 프로필 (TeamProfile) 표시
3. **두 프로필 모두 없으면**: 해당 컨텍스트 기능 사용 불가
