# Agora 프로필 API

## Base URL
`/api/agora/profile`

## 인증
Bearer Token (OAuth 2.0)

---

## 1. GET / - 내 프로필 조회

현재 로그인한 사용자의 Agora 프로필을 조회합니다.

### Request
```http
GET /api/agora/profile
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "agoraId": "john_doe",
  "displayName": "John Doe",
  "profileImage": "https://cdn.hyfata.com/profiles/john_doe.jpg",
  "bio": "안녕하세요!",
  "phone": "+82-10-1234-5678",
  "birthday": "1990-01-15",
  "createdAt": "2025-01-10T15:30:00",
  "updatedAt": "2025-01-15T10:20:00"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 401 | UNAUTHORIZED | 인증 토큰이 없거나 만료됨 |
| 404 | PROFILE_NOT_FOUND | 프로필이 아직 생성되지 않음 |

---

## 2. POST / - 프로필 생성

첫 번째 Agora 프로필을 생성합니다.

### Request
```http
POST /api/agora/profile
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "agoraId": "john_doe",
  "displayName": "John Doe",
  "bio": "안녕하세요!",
  "phone": "+82-10-1234-5678",
  "birthday": "1990-01-15",
  "profileImage": "https://cdn.hyfata.com/profiles/john_doe.jpg"
}
```

### Response 200
```json
{
  "agoraId": "john_doe",
  "displayName": "John Doe",
  "profileImage": "https://cdn.hyfata.com/profiles/john_doe.jpg",
  "bio": "안녕하세요!",
  "phone": "+82-10-1234-5678",
  "birthday": "1990-01-15",
  "createdAt": "2025-01-15T10:30:00",
  "updatedAt": "2025-01-15T10:30:00"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 400 | INVALID_AGORA_ID | agoraId 형식이 올바르지 않습니다 |
| 409 | AGORA_ID_ALREADY_EXISTS | 이미 사용 중인 agoraId입니다 |
| 400 | PROFILE_ALREADY_EXISTS | 이미 프로필이 있습니다 |

---

## 3. PUT / - 프로필 수정

Agora 프로필을 수정합니다.

### Request
```http
PUT /api/agora/profile
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "displayName": "John Doe Updated",
  "bio": "새로운 소개",
  "phone": "+82-10-9876-5432",
  "birthday": "1990-01-15",
  "profileImage": "https://cdn.hyfata.com/profiles/john_doe_new.jpg"
}
```

### Response 200
```json
{
  "agoraId": "john_doe",
  "displayName": "John Doe Updated",
  "profileImage": "https://cdn.hyfata.com/profiles/john_doe_new.jpg",
  "bio": "새로운 소개",
  "phone": "+82-10-9876-5432",
  "birthday": "1990-01-15",
  "createdAt": "2025-01-15T10:30:00",
  "updatedAt": "2025-01-15T11:00:00"
}
```

---

## 4. PUT /image - 프로필 이미지 변경

프로필 이미지만 변경합니다.

### Request
```http
PUT /api/agora/profile/image
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "profileImage": "https://cdn.hyfata.com/profiles/john_doe_avatar.jpg"
}
```

### Response 200
```json
{
  "agoraId": "john_doe",
  "displayName": "John Doe",
  "profileImage": "https://cdn.hyfata.com/profiles/john_doe_avatar.jpg",
  "bio": "안녕하세요!",
  "phone": "+82-10-1234-5678",
  "birthday": "1990-01-15",
  "createdAt": "2025-01-15T10:30:00",
  "updatedAt": "2025-01-15T11:05:00"
}
```

---

## 5. GET /{agoraId} - 다른 사용자 프로필 조회

다른 사용자의 공개 프로필을 조회합니다.

### Request
```http
GET /api/agora/profile/john_doe
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "agoraId": "john_doe",
  "displayName": "John Doe",
  "profileImage": "https://cdn.hyfata.com/profiles/john_doe.jpg",
  "bio": "안녕하세요!",
  "createdAt": "2025-01-10T15:30:00"
}
```

**주의**: 전화번호와 생일은 공개 설정이 아닐 수 있습니다.

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 404 | PROFILE_NOT_FOUND | 프로필을 찾을 수 없습니다 |

---

## 6. GET /search - 사용자 검색

agoraId 또는 displayName으로 사용자를 검색합니다.

### Request
```http
GET /api/agora/profile/search?keyword=john
Authorization: Bearer {access_token}
```

### Response 200
```json
[
  {
    "agoraId": "john_doe",
    "displayName": "John Doe",
    "profileImage": "https://cdn.hyfata.com/profiles/john_doe.jpg"
  },
  {
    "agoraId": "john_smith",
    "displayName": "John Smith",
    "profileImage": "https://cdn.hyfata.com/profiles/john_smith.jpg"
  }
]
```

### Query Parameters
| Name | Type | Required | Description |
|------|------|----------|-------------|
| keyword | string | Yes | 검색 키워드 (최소 2글자) |

---

## 7. GET /check-id - agoraId 중복 확인

agoraId의 사용 가능 여부를 확인합니다.

### Request
```http
GET /api/agora/profile/check-id?agoraId=john_doe
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "available": true
}
```

### Query Parameters
| Name | Type | Required | Description |
|------|------|----------|-------------|
| agoraId | string | Yes | 확인할 agoraId |

---

## 프로필 필드 요구사항

| 필드 | 타입 | 요구사항 |
|------|------|---------|
| agoraId | string | 필수, 3-20자, 영문/숫자/언더스코어만 가능 |
| displayName | string | 필수, 1-50자 |
| bio | string | 선택, 최대 200자 |
| phone | string | 선택, E.164 형식 |
| birthday | date | 선택, YYYY-MM-DD |
| profileImage | URL | 선택 |

---

## agoraId 규칙

- 3-20자 길이
- 영문 소문자, 숫자, 언더스코어(_) 만 사용
- 예: `john_doe`, `user123`, `dev_team`
