# OAuth 2.0 + PKCE 인증 흐름

## 개요

Hyfata API는 OAuth 2.0 + PKCE (Proof Key for Code Exchange) 방식의 인증을 사용합니다.

**특징:**
- 클라이언트 비밀번호 없음 (공개 클라이언트 안전)
- 모바일 앱, SPA에 권장
- Authorization Code + PKCE를 통한 Token 획득

---

## 시퀀스 다이어그램

```
┌─────────┐                                    ┌─────────────┐
│ 클라이언트  │                                    │   서버      │
└────┬────┘                                    └─────┬───────┘
     │                                               │
     │ 1. code_verifier 생성 & hash (code_challenge)
     │─────────────────────────────────────────────>│
     │ POST /oauth/authorize                        │
     │ ?client_id=...                               │
     │ &code_challenge=...                          │
     │ &code_challenge_method=S256                  │
     │                                               │
     │                      로그인 페이지 반환
     │<─────────────────────────────────────────────│
     │                                               │
     │ 2. 사용자 로그인 (아이디/비밀번호 입력)
     │─────────────────────────────────────────────>│
     │ POST /oauth/login                            │
     │ ?email=...&password=...                      │
     │                                               │
     │                  Authorization Code 발급
     │<─────────────────────────────────────────────│
     │                                               │
     │ 3. Authorization Code + code_verifier 교환
     │─────────────────────────────────────────────>│
     │ POST /oauth/token                            │
     │ {code, code_verifier, client_id}             │
     │                                               │
     │                Access Token 발급
     │<─────────────────────────────────────────────│
     │ {access_token, refresh_token, expires_in}   │
     │                                               │
     │ 4. 이후 API 호출 시 토큰 사용
     │─────────────────────────────────────────────>│
     │ GET /api/agora/profile                       │
     │ Authorization: Bearer {access_token}         │
     │                                               │
     │                  프로필 조회 응답
     │<─────────────────────────────────────────────│

```

---

## 단계별 구현

### 1단계: PKCE 준비

클라이언트에서 code_verifier와 code_challenge를 생성합니다.

```
code_verifier = 무작위 문자열 (43-128자)
code_challenge = BASE64URL(SHA256(code_verifier))
code_challenge_method = "S256"
```

**예시 (Node.js):**
```javascript
const crypto = require('crypto');
const base64url = (buf) => buf.toString('base64').replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');

const codeVerifier = base64url(crypto.randomBytes(32));
const codeChallenge = base64url(crypto.createHash('sha256').update(codeVerifier).digest());

console.log('Code Verifier:', codeVerifier);
console.log('Code Challenge:', codeChallenge);
```

---

### 2단계: 로그인 페이지 요청

Authorization Code를 얻기 위해 로그인 페이지로 리다이렉트합니다.

```http
GET /oauth/authorize?client_id=hyfata-app&code_challenge={code_challenge}&code_challenge_method=S256&redirect_uri=http://localhost:3000/callback
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| client_id | string | Yes | 클라이언트 ID (Hyfata 에서 발급) |
| code_challenge | string | Yes | BASE64URL(SHA256(code_verifier)) |
| code_challenge_method | string | Yes | "S256" (고정) |
| redirect_uri | string | No | 로그인 후 리다이렉트 URL |
| scope | string | No | 요청 권한 (기본: openid) |

**응답:**
- 로그인 페이지 HTML 반환
- 사용자가 이메일/비밀번호 입력

---

### 3단계: 로그인 처리

로그인 페이지에서 사용자가 credentials을 입력하면 서버가 검증합니다.

```http
POST /oauth/login
Content-Type: application/x-www-form-urlencoded

email=user@example.com&password=password123
```

**응답:**
- Authorization Code 반환
- URL로 리다이렉트: `http://localhost:3000/callback?code={authorization_code}`

**클라이언트는 이 Authorization Code를 저장합니다.**

---

### 4단계: Token 교환

Authorization Code + code_verifier를 사용하여 Access Token을 얻습니다.

```http
POST /oauth/token
Content-Type: application/json

{
  "grant_type": "authorization_code",
  "code": "{authorization_code}",
  "client_id": "hyfata-app",
  "code_verifier": "{code_verifier}"
}
```

**Response 200:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "openid"
}
```

**클라이언트는 다음 정보를 안전하게 저장합니다:**
- `access_token` - API 호출 시 사용 (1시간 유효)
- `refresh_token` - 토큰 갱신 시 사용 (장기 유효)

---

### 5단계: API 호출

Access Token을 사용하여 API를 호출합니다.

```http
GET /api/agora/profile
Authorization: Bearer {access_token}
```

---

## 토큰 갱신

Access Token이 만료되면 Refresh Token으로 새 토큰을 얻습니다.

```http
POST /oauth/token
Content-Type: application/json

{
  "grant_type": "refresh_token",
  "refresh_token": "{refresh_token}",
  "client_id": "hyfata-app"
}
```

**Response 200:**
```json
{
  "access_token": "새로운_액세스_토큰",
  "refresh_token": "새로운_리프레시_토큰",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

**주의:** 토큰 갱신 시 새로운 세션이 생성되고, 기존 세션은 무효화됩니다 (Token Rotation).

---

## 로그아웃

```http
POST /oauth/logout
Authorization: Bearer {access_token}
```

**효과:**
- 현재 세션 무효화
- Access Token 블랙리스트 등록
- 모든 다른 세션 유지 (또는 모두 무효화 선택 가능)

---

## 에러 처리

### Authorization Code 만료
```
GET /callback?error=invalid_code&error_description=Authorization code has expired
```

**해결:** 처음부터 다시 로그인

### PKCE 검증 실패
```json
{
  "error": "invalid_request",
  "error_description": "code_verifier does not match code_challenge"
}
```

**원인:** code_verifier가 올바르지 않거나, code_challenge와 일치하지 않음

### Token 만료
```json
{
  "error": "unauthorized",
  "error_description": "Token has expired"
}
```

**해결:** Refresh Token으로 새 Access Token 획득

---

## 보안 고려사항

### PKCE 필수
- code_verifier는 절대 네트워크로 전송되지 않음
- code_challenge만 서버에 전송됨
- 중간자 공격 방지

### Refresh Token 보안
- **절대 클라이언트에 노출되지 않아야 함**
- HttpOnly, Secure, SameSite 쿠키에 저장 권장
- 또는 안전한 로컬 스토리지 사용

### Access Token 저장
- 메모리에 저장 (권장)
- 또는 세션 스토리지 (XSS 위험 있음)
- **절대 localStorage에 저장하지 말 것** (XSS 취약)

### 세션 관리
- 최대 5개 동시 세션 허용
- 새 세션 생성 시 가장 오래된 세션 무효화

---

## 클라이언트별 예제

### JavaScript (Browser)

```javascript
// 1. PKCE 준비
const codeVerifier = generateRandomString(128);
const codeChallenge = await generateCodeChallenge(codeVerifier);

// 2. 로그인 페이지로 리다이렉트
window.location.href =
  `https://api.hyfata.com/oauth/authorize?` +
  `client_id=hyfata-app&` +
  `code_challenge=${codeChallenge}&` +
  `code_challenge_method=S256&` +
  `redirect_uri=${window.location.origin}/callback`;

// 3. Callback URL에서 Authorization Code 획득
const urlParams = new URLSearchParams(window.location.search);
const authCode = urlParams.get('code');

// 4. Token 교환
const response = await fetch('https://api.hyfata.com/oauth/token', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    grant_type: 'authorization_code',
    code: authCode,
    client_id: 'hyfata-app',
    code_verifier: codeVerifier
  })
});

const { access_token, refresh_token } = await response.json();
sessionStorage.setItem('access_token', access_token);
// Refresh token은 HttpOnly 쿠키에 저장됨 (자동)
```

---

## 주의사항

1. **code_verifier 저장**: callback 처리 전까지 안전하게 저장 필요
2. **redirect_uri**: 등록된 URI와 정확히 일치해야 함
3. **HTTPS 필수**: 프로덕션 환경에서는 반드시 HTTPS 사용
4. **토큰 갱신**: Access Token 만료 1-2분 전에 미리 갱신 권장
