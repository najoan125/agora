# 사용자 설정 API

## Base URL
`/api/agora/settings`

## 인증
Bearer Token (OAuth 2.0)

---

## 1. GET /notifications - 알림 설정 조회

현재 알림 설정을 조회합니다.

### Request
```http
GET /api/agora/settings/notifications
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "pushEnabled": true,
  "messageNotification": true,
  "friendRequestNotification": true,
  "teamNotification": true,
  "noticeNotification": true,
  "soundEnabled": true,
  "vibrationEnabled": true,
  "doNotDisturbStart": "22:00:00",
  "doNotDisturbEnd": "08:00:00",
  "loginNotification": true
}
```

---

## 2. PUT /notifications - 알림 설정 수정

알림 설정을 수정합니다.

### Request
```http
PUT /api/agora/settings/notifications
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "pushEnabled": false,
  "messageNotification": true,
  "friendRequestNotification": false,
  "teamNotification": true,
  "noticeNotification": true,
  "soundEnabled": true,
  "vibrationEnabled": false,
  "doNotDisturbStart": "23:00:00",
  "doNotDisturbEnd": "07:00:00",
  "loginNotification": false
}
```

### Response 200
```json
{
  "pushEnabled": false,
  "messageNotification": true,
  "friendRequestNotification": false,
  "teamNotification": true,
  "noticeNotification": true,
  "soundEnabled": true,
  "vibrationEnabled": false,
  "doNotDisturbStart": "23:00:00",
  "doNotDisturbEnd": "07:00:00",
  "loginNotification": false
}
```

### Request Fields
모든 필드는 선택사항입니다. 변경하고 싶은 필드만 포함하세요.

| Field | Type | Description |
|-------|------|-------------|
| pushEnabled | boolean | 푸시 알림 활성화 |
| messageNotification | boolean | 메시지 알림 |
| friendRequestNotification | boolean | 친구 요청 알림 |
| teamNotification | boolean | 팀 관련 알림 |
| noticeNotification | boolean | 공지 알림 |
| soundEnabled | boolean | 알림음 활성화 |
| vibrationEnabled | boolean | 진동 활성화 |
| doNotDisturbStart | time | 방해금지 시작 시간 (HH:mm:ss) |
| doNotDisturbEnd | time | 방해금지 종료 시간 (HH:mm:ss) |
| loginNotification | boolean | 로그인 알림 |

---

## 3. GET /privacy - 개인정보 설정 조회

현재 개인정보 설정을 조회합니다.

### Request
```http
GET /api/agora/settings/privacy
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "profileVisibility": "FRIENDS",
  "phoneVisibility": "NONE",
  "birthdayVisibility": "FRIENDS",
  "allowFriendRequests": true,
  "allowGroupInvites": true,
  "showOnlineStatus": true,
  "sessionTimeout": 30
}
```

---

## 4. PUT /privacy - 개인정보 설정 수정

개인정보 설정을 수정합니다.

### Request
```http
PUT /api/agora/settings/privacy
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "profileVisibility": "PUBLIC",
  "phoneVisibility": "FRIENDS",
  "birthdayVisibility": "NONE",
  "allowFriendRequests": true,
  "allowGroupInvites": false,
  "showOnlineStatus": false,
  "sessionTimeout": 60
}
```

### Response 200
```json
{
  "profileVisibility": "PUBLIC",
  "phoneVisibility": "FRIENDS",
  "birthdayVisibility": "NONE",
  "allowFriendRequests": true,
  "allowGroupInvites": false,
  "showOnlineStatus": false,
  "sessionTimeout": 60
}
```

### Request Fields
모든 필드는 선택사항입니다.

| Field | Type | Description |
|-------|------|-------------|
| profileVisibility | string | 프로필 공개 범위 (PUBLIC, FRIENDS, NONE) |
| phoneVisibility | string | 전화번호 공개 범위 (PUBLIC, FRIENDS, NONE) |
| birthdayVisibility | string | 생일 공개 범위 (PUBLIC, FRIENDS, NONE) |
| allowFriendRequests | boolean | 친구 요청 허용 |
| allowGroupInvites | boolean | 그룹 초대 허용 |
| showOnlineStatus | boolean | 온라인 상태 표시 |
| sessionTimeout | integer | 세션 타임아웃 (분) |

---

## 5. PUT /birthday-reminder - 생일 알림 설정 수정

생일 알림 설정을 수정합니다.

### Request
```http
PUT /api/agora/settings/birthday-reminder
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "birthdayReminderEnabled": true,
  "birthdayReminderDaysBefore": 7
}
```

### Response 200
```json
{
  "pushEnabled": true,
  "messageNotification": true,
  "friendRequestNotification": true,
  "teamNotification": true,
  "noticeNotification": true,
  "soundEnabled": true,
  "vibrationEnabled": true,
  "doNotDisturbStart": "22:00:00",
  "doNotDisturbEnd": "08:00:00",
  "loginNotification": true,
  "birthdayReminderEnabled": true,
  "birthdayReminderDaysBefore": 7
}
```

### Request Fields
| Field | Type | Description |
|-------|------|-------------|
| birthdayReminderEnabled | boolean | 생일 알림 활성화 |
| birthdayReminderDaysBefore | integer | 며칠 전에 알림 (1-30) |

---

## 공개 범위 (Visibility)

| Value | 설명 |
|-------|------|
| PUBLIC | 모든 사용자가 볼 수 있음 |
| FRIENDS | 친구만 볼 수 있음 |
| NONE | 아무도 볼 수 없음 (자신만 볼 수 있음) |

---

## 기본값

| 설정 | 기본값 |
|------|--------|
| pushEnabled | true |
| messageNotification | true |
| friendRequestNotification | true |
| teamNotification | true |
| noticeNotification | true |
| soundEnabled | true |
| vibrationEnabled | true |
| loginNotification | true |
| profileVisibility | FRIENDS |
| phoneVisibility | NONE |
| birthdayVisibility | FRIENDS |
| allowFriendRequests | true |
| allowGroupInvites | true |
| showOnlineStatus | true |
| sessionTimeout | 30분 |
| birthdayReminderEnabled | true |
| birthdayReminderDaysBefore | 3일 |

---

## 주의사항

1. **방해금지 시간**: 이 시간대에 알림이 오지 않습니다.
2. **세션 타임아웃**: 웹/앱에서 사용하지 않은 시간이 초과되면 자동 로그아웃됩니다.
3. **생일 알림**: 생일 알림이 활성화되어도 `birthdayVisibility`가 NONE이면 알림을 받지 않습니다.
4. **프라이버시**: 개인정보 설정은 다른 사용자의 프로필 조회 시 적용됩니다.
