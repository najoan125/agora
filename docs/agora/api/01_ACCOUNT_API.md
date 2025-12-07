# 계정 API

## Base URL
`/api/account`

## 인증
Bearer Token (OAuth 2.0)

---

## 1. PUT /password - 비밀번호 변경

인증된 사용자의 비밀번호를 변경합니다.

### Request
```http
PUT /api/account/password
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "currentPassword": "현재비밀번호",
  "newPassword": "새비밀번호",
  "confirmPassword": "새비밀번호"
}
```

### Response 200
```json
{
  "message": "비밀번호가 변경되었습니다"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 400 | INVALID_PASSWORD | 비밀번호 형식이 올바르지 않습니다 |
| 401 | WRONG_PASSWORD | 현재 비밀번호가 일치하지 않습니다 |
| 401 | PASSWORD_MISMATCH | 새 비밀번호와 확인이 일치하지 않습니다 |

---

## 2. POST /deactivate - 계정 비활성화

계정을 일시적으로 비활성화합니다. 30일 후 완전히 삭제됩니다.

### Request
```http
POST /api/account/deactivate
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "password": "현재비밀번호",
  "reason": "사용하지 않을 예정"
}
```

### Response 200
```json
{
  "message": "계정이 비활성화되었습니다. 30일 후 완전히 삭제됩니다"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 401 | WRONG_PASSWORD | 비밀번호가 일치하지 않습니다 |
| 400 | ALREADY_DEACTIVATED | 이미 비활성화된 계정입니다 |

---

## 3. DELETE / - 계정 영구 삭제

계정과 모든 데이터를 완전히 삭제합니다. **되돌릴 수 없습니다.**

### Request
```http
DELETE /api/account
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "password": "현재비밀번호",
  "confirmText": "계정을 삭제합니다"
}
```

### Response 200
```json
{
  "message": "계정이 삭제되었습니다"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 401 | WRONG_PASSWORD | 비밀번호가 일치하지 않습니다 |
| 400 | INVALID_CONFIRM_TEXT | 확인 문구가 일치하지 않습니다 |

---

## 4. POST /restore - 비활성화 계정 복구

비활성화된 계정을 복구합니다. 30일 이내에만 가능합니다.

### Request
```http
POST /api/account/restore
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "비밀번호"
}
```

**주의**: 이 엔드포인트는 인증이 필요하지 않습니다.

### Response 200
```json
{
  "message": "계정이 복구되었습니다. 다시 로그인해주세요"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 404 | USER_NOT_FOUND | 사용자를 찾을 수 없습니다 |
| 400 | ACCOUNT_NOT_DEACTIVATED | 비활성화된 계정이 아닙니다 |
| 400 | RESTORE_PERIOD_EXPIRED | 복구 기간이 만료되었습니다 (30일 초과) |
| 401 | WRONG_PASSWORD | 비밀번호가 일치하지 않습니다 |

---

## 계정 상태

| Status | 설명 |
|--------|------|
| ACTIVE | 정상 사용 중 |
| DEACTIVATED | 비활성화됨 (30일 유예) |
| DELETED | 완전히 삭제됨 |

---

## 주의사항

1. **비밀번호 변경 시**: 모든 다른 세션이 무효화될 수 있습니다.
2. **계정 삭제 전**: 중요한 데이터를 백업하세요.
3. **복구 기한**: 비활성화 후 30일 이내에만 복구 가능합니다.
