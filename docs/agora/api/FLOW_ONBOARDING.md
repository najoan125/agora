# 회원가입 흐름

## 전체 흐름

```
1. OAuth 로그인 (계정 생성)
   ↓
2. Agora 프로필 생성
   ↓
3. 첫 채팅방 추천
   ↓
4. 설정 초기화
   ↓
5. 완료
```

---

## 단계 1: OAuth 로그인 및 계정 생성

기존 플로우 참고: [FLOW_AUTH.md](FLOW_AUTH.md)

**결과:**
- 새로운 User 계정 생성
- Access Token + Refresh Token 발급

---

## 단계 2: Agora 프로필 생성

로그인 후 첫 화면에서 Agora 프로필 생성을 유도합니다.

```http
POST /api/agora/profile
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "agoraId": "user_chosen_id",
  "displayName": "사용자가 입력한 이름",
  "bio": "자기소개",
  "profileImage": "https://cdn.hyfata.com/..."
}
```

**응답:**
```json
{
  "agoraId": "user_chosen_id",
  "displayName": "사용자가 입력한 이름",
  ...
}
```

**주의사항:**
- agoraId는 변경 불가능 (신중히 선택)
- 3-20자, 영문/숫자/언더스코어만 가능

---

## 단계 3: 기본 설정 초기화

사용자 설정을 기본값으로 초기화합니다.

```http
PUT /api/agora/settings/notifications
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "pushEnabled": true,
  "messageNotification": true,
  "friendRequestNotification": true,
  "soundEnabled": true
}
```

---

## 단계 4: 친구 찾기 (선택)

```http
GET /api/agora/profile/search?keyword=friend_name
Authorization: Bearer {access_token}
```

처음부터 친구를 추가할 수 있도록 검색 기능 제공.

---

## 단계 5: 완료

Agora 홈 화면으로 리다이렉트.

---

## UI/UX 권장사항

1. **프로필 설정 단계별 진행**
   - Step 1: 이메일/비밀번호 (OAuth)
   - Step 2: agoraId 선택
   - Step 3: 프로필 이미지 업로드
   - Step 4: 자기소개 입력
   - Step 5: 설정 완료

2. **입력 값 검증**
   - agoraId: 3-20자, 영문/숫자/언더스코어, 실시간 중복 확인
   - displayName: 1-50자
   - 프로필 이미지: 5MB 이하

3. **진행 상황 표시**
   - 프로그래스 바 (5/5 단계)
   - 건너뛰기 옵션 제공

---

## 에러 처리

### agoraId 중복
```json
{
  "error": "AGORA_ID_ALREADY_EXISTS",
  "message": "이미 사용 중인 ID입니다"
}
```

→ 다른 ID 제안 또는 수동 입력

### 프로필 이미지 업로드 실패
```json
{
  "error": "FILE_TOO_LARGE",
  "message": "파일 크기는 5MB 이하여야 합니다"
}
```

→ 파일 크기 감소 유도

---

## 소셜 로그인 연동 (선택)

Google, Apple, Kakao 등을 추가할 수 있습니다.

```javascript
// Google 로그인 예
const { credential } = await google.accounts.id.initialize({
  client_id: 'YOUR_CLIENT_ID'
});

// OAuth 토큰으로 변환
const response = await fetch('/oauth/token', {
  method: 'POST',
  body: JSON.stringify({
    grant_type: 'google_oauth',
    id_token: credential
  })
});
```

---

## 완료 체크리스트

- [ ] User 계정 생성
- [ ] Agora 프로필 생성
- [ ] FCM 토큰 등록 (모바일)
- [ ] 기본 알림 설정
- [ ] 첫 로그인 완료
