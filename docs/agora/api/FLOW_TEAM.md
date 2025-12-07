# 팀 생성 및 관리 흐름

## 팀 생성 흐름

```
1. 팀 생성
2. 팀 정보 설정
3. 멤버 초대
4. 팀 프로필 설정
5. 팀 공지/할일/일정 작성
```

---

## 단계 1: 팀 생성

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

**응답:**
```json
{
  "teamId": 1,
  "name": "개발팀",
  "description": "백엔드 개발 팀",
  "profileImage": "https://...",
  "isMain": false,
  "creatorEmail": "admin@example.com",
  "memberCount": 1,
  "createdAt": "2025-01-15T10:30:00"
}
```

**결과:**
- 팀 생성 완료
- 생성자는 자동으로 ADMIN 역할

---

## 단계 2: 팀 멤버 초대

```http
POST /api/agora/teams/1/members?userEmail=john@example.com
Authorization: Bearer {access_token}
```

**응답:**
```json
{
  "memberId": 2,
  "userId": 101,
  "userEmail": "john@example.com",
  "roleName": "member",
  "joinedAt": "2025-01-15T10:35:00"
}
```

**반복:** 추가할 멤버 수만큼 반복

---

## 단계 3: 멤버 역할 관리 (선택)

```http
PUT /api/agora/teams/1/members/2/role?roleName=admin
Authorization: Bearer {access_token}
```

---

## 단계 4: 팀 프로필 설정

각 멤버가 팀 내에서 사용할 프로필을 설정합니다.

```http
POST /api/agora/teams/1/profile
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "displayName": "John (Team Lead)",
  "profileImage": "https://..."
}
```

---

## 단계 5: 팀 공지 작성

```http
POST /api/agora/teams/1/notices
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "title": "팀 창설 안내",
  "content": "개발팀이 정식으로 출범했습니다",
  "isPinned": true
}
```

---

## 단계 6: 할일 및 일정 등록

### 할일 등록
```http
POST /api/agora/teams/1/todos
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "title": "프로젝트 계획 수립",
  "description": "2주 단위 개발 계획 수립",
  "assignedToId": 101,
  "priority": "HIGH",
  "dueDate": "2025-01-20T23:59:59"
}
```

### 일정 등록
```http
POST /api/agora/teams/1/events
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "title": "팀 미팅",
  "description": "주간 회의",
  "location": "회의실 A",
  "startTime": "2025-01-20T14:00:00",
  "endTime": "2025-01-20T15:00:00"
}
```

---

## 팀 관리

### 팀 정보 수정

```http
PUT /api/agora/teams/1
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "name": "개발팀 (Updated)",
  "description": "백엔드/프론트엔드 개발 팀"
}
```

### 멤버 제거

```http
DELETE /api/agora/teams/1/members/2
Authorization: Bearer {access_token}
```

### 팀 목록 확인

```http
GET /api/agora/teams
Authorization: Bearer {access_token}
```

---

## 팀 채팅

팀 전용 그룹 채팅:

```http
POST /api/agora/chats/groups
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "name": "개발팀 공용 채팅",
  "memberAgoraIds": ["john_doe", "jane_smith"]
}
```

---

## 권한 정리

| 기능 | 생성자 | ADMIN | MEMBER |
|------|--------|-------|--------|
| 팀 정보 수정 | O | X | X |
| 팀 삭제 | O | X | X |
| 멤버 초대/제거 | O | X | X |
| 역할 변경 | O | X | X |
| 공지 작성 | O | X | X |
| 일정 작성 | O | X | X |
| 할일 생성 | O | O | O |
| 채팅 | O | O | O |

---

## 팀 삭제

```http
DELETE /api/agora/teams/1
Authorization: Bearer {access_token}
```

**주의:** 생성자만 삭제 가능하며, 모든 팀 데이터(공지, 할일, 일정 등)가 삭제됩니다.

---

## 권장사항

1. **팀 구조 계획**
   - 팀 이름과 설명을 명확하게
   - 팀 이미지(로고) 설정

2. **멤버 관리**
   - 초대 순서 결정
   - 역할 배분 (리더, 멤버 등)

3. **초기 설정**
   - 팀 공지로 팀 설립 공고
   - 기본 규칙 안내
   - 첫 할일/일정 등록

4. **커뮤니케이션**
   - 팀 채팅방 활성화
   - 정기적인 회의 일정 등록
