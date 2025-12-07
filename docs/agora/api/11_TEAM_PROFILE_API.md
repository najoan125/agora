# 팀 프로필 API

## Base URL
`/api/agora/teams/{teamId}/profile`

## 인증
Bearer Token (OAuth 2.0)

---

## 1. GET / - 내 팀 프로필 조회

내가 해당 팀에서 사용 중인 프로필을 조회합니다.

### Request
```http
GET /api/agora/teams/1/profile
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "profileId": 1,
  "teamId": 1,
  "userId": 100,
  "userEmail": "user@example.com",
  "displayName": "John (Team Name)",
  "profileImage": "https://cdn.hyfata.com/profiles/team_john.jpg",
  "createdAt": "2025-01-10T10:00:00",
  "updatedAt": "2025-01-15T10:00:00"
}
```

---

## 2. POST / - 팀 프로필 생성

팀 내에서 사용할 프로필을 생성합니다.

### Request
```http
POST /api/agora/teams/1/profile
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "displayName": "John (Development Team)",
  "profileImage": "https://cdn.hyfata.com/profiles/team_john.jpg"
}
```

### Response 200
```json
{
  "profileId": 1,
  "teamId": 1,
  "userId": 100,
  "userEmail": "user@example.com",
  "displayName": "John (Development Team)",
  "profileImage": "https://cdn.hyfata.com/profiles/team_john.jpg",
  "createdAt": "2025-01-15T10:30:00",
  "updatedAt": "2025-01-15T10:30:00"
}
```

---

## 3. PUT / - 팀 프로필 수정

```http
PUT /api/agora/teams/1/profile
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "displayName": "John (Senior Developer)",
  "profileImage": "https://cdn.hyfata.com/profiles/team_john_new.jpg"
}
```

### Response 200
```json
{
  "profileId": 1,
  "teamId": 1,
  "displayName": "John (Senior Developer)",
  "profileImage": "https://cdn.hyfata.com/profiles/team_john_new.jpg",
  "updatedAt": "2025-01-15T11:00:00"
}
```

---

## 4. PUT /image - 프로필 이미지 변경

```http
PUT /api/agora/teams/1/profile/image
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "profileImage": "https://cdn.hyfata.com/profiles/team_john_avatar.jpg"
}
```

### Response 200
```json
{
  "profileId": 1,
  "teamId": 1,
  "displayName": "John (Senior Developer)",
  "profileImage": "https://cdn.hyfata.com/profiles/team_john_avatar.jpg",
  "updatedAt": "2025-01-15T11:05:00"
}
```

---

## 5. GET /members/{userId} - 타 팀원 프로필 조회

다른 팀원의 팀 프로필을 조회합니다.

### Request
```http
GET /api/agora/teams/1/members/101
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "profileId": 2,
  "teamId": 1,
  "userId": 101,
  "userEmail": "john@example.com",
  "displayName": "John (Team Lead)",
  "profileImage": "https://cdn.hyfata.com/profiles/team_john_lead.jpg",
  "createdAt": "2025-01-10T10:00:00",
  "updatedAt": "2025-01-12T10:00:00"
}
```

---

## 특징

- **팀별 프로필**: 같은 사용자도 다른 팀에서는 다른 프로필 사용 가능
- **독립적 설정**: 각 팀의 프로필은 독립적으로 관리됨
- **공개 정보**: 팀원들이 조회 가능
- **개인정보 존중**: 전화번호 등은 공개 설정에 따름
