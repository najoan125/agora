# OAuth 2.0 Authentication API Reference

Hyfata REST API의 OAuth 2.0 인증 시스템 문서입니다.

---

## 목차

1. [개요](#개요)
2. [인증 흐름](#인증-흐름)
   - [기본 Authorization Code Flow](#기본-authorization-code-flow)
   - [PKCE Flow](#pkce-flow-권장)
3. [OAuth Controller](#oauth-controller)
4. [Auth Controller](#auth-controller)
5. [Client Controller](#client-controller)
6. [Session Controller](#session-controller)
7. [DTO Reference](#dto-reference)
8. [에러 응답](#에러-응답)

---

## 개요

Hyfata REST API는 **OAuth 2.0 Authorization Code Grant**를 지원하며, 선택적으로 **PKCE (Proof Key for Code Exchange)**를 사용하여 보안을 강화할 수 있습니다.

### 아키텍처 개요

```
┌─────────────┐     ┌─────────────────┐     ┌─────────────┐
│   Client    │────▶│  Hyfata API     │────▶│  Database   │
│ Application │◀────│  (OAuth 2.0)    │◀────│  (PostgreSQL)│
└─────────────┘     └─────────────────┘     └─────────────┘
                            │
                            ▼
                    ┌─────────────┐
                    │    Redis    │
                    │ (Token Cache)│
                    └─────────────┘
```

### Base URL

```
https://api.hyfata.kr
```

---

## 인증 흐름

### 기본 Authorization Code Flow

PKCE를 사용하지 않는 기본 OAuth 2.0 흐름입니다.

#### 클라이언트 호출 요약

| 단계       | 엔드포인트 | 호출 주체 | 설명 |
|----------|-----------|----------|------|
| Step 1   | `GET /oauth/authorize` | **클라이언트 앱** | 직접 호출 (브라우저 리다이렉트) |
| Step 2~4 | `POST /oauth/login` | **브라우저** | 로그인 페이지 폼 제출, 클라이언트가 직접 호출 X |
| Step 5   | `POST /oauth/token` | **클라이언트 앱** | 직접 호출 (서버 사이드) |

```
┌──────────┐                              ┌──────────┐                              ┌──────────┐
│  Client  │                              │   API    │                              │   User   │
└────┬─────┘                              └────┬─────┘                              └────┬─────┘
     │                                         │                                         │
     │  1. GET /oauth/authorize                │                                         │
     │    ?client_id=xxx                       │                                         │
     │    &redirect_uri=https://app/callback   │                                         │
     │    &response_type=code                  │                                         │
     │    &state=random123                     │                                         │
     │────────────────────────────────────────▶│                                         │
     │                                         │                                         │
     │         2. 로그인 페이지 표시            │                                         │
     │◀────────────────────────────────────────│                                         │
     │                                         │                                         │
     │                                         │     3. 로그인 정보 입력                  │
     │                                         │◀────────────────────────────────────────│
     │                                         │                                         │
     │  4. Redirect to                         │                                         │
     │     https://app/callback                │                                         │
     │       ?code=AUTH_CODE                   │                                         │
     │       &state=random123                  │                                         │
     │◀────────────────────────────────────────│                                         │
     │                                         │                                         │
     │  5. POST /oauth/token                   │                                         │
     │     grant_type=authorization_code       │                                         │
     │     code=AUTH_CODE                      │                                         │
     │     client_id=xxx                       │                                         │
     │     client_secret=xxx                   │                                         │
     │     redirect_uri=https://app/callback   │                                         │
     │────────────────────────────────────────▶│                                         │
     │                                         │                                         │
     │  6. {access_token, refresh_token, ...}  │                                         │
     │◀────────────────────────────────────────│                                         │
     │                                         │                                         │
```

#### Step 1: Authorization 요청

클라이언트 앱이 직접 호출합니다 (브라우저를 이 URL로 리다이렉트).

| Parameter | Required | Description |
|-----------|----------|-------------|
| `client_id` | O | 등록된 OAuth 클라이언트 ID |
| `redirect_uri` | O | 콜백 URL (등록된 URI여야 함) |
| `response_type` | O | `code` 고정 |
| `state` | X | CSRF 방지용 (없으면 자동 생성) |

```http
GET /oauth/authorize?client_id=client_001&redirect_uri=https://myapp.com/callback&response_type=code&state=xyz123
```

#### Step 2~4: 사용자 로그인 및 Authorization Code 발급

> ⚠️ **클라이언트가 직접 호출하지 않음** - 이 과정은 브라우저에서 자동으로 처리됩니다.

1. API가 로그인 페이지(HTML)를 표시합니다
2. 사용자가 이메일/비밀번호를 입력하고 폼을 제출합니다
3. 브라우저가 `POST /oauth/login`을 호출합니다 (폼 액션)
4. API가 Authorization Code를 생성하고 `redirect_uri`로 리다이렉트합니다

**Callback으로 리다이렉트:**

```
https://myapp.com/callback?code=a1b2c3d4e5f6&state=xyz123
```

클라이언트 앱은 이 callback에서 `code` 파라미터를 추출합니다.

#### Step 5~6: Token 교환

클라이언트 앱이 직접 호출합니다 (서버 사이드 권장).

| Parameter | Required | Description |
|-----------|----------|-------------|
| `grant_type` | O | `authorization_code` 고정 |
| `code` | O | Step 4에서 받은 Authorization Code |
| `client_id` | O | 클라이언트 ID |
| `client_secret` | O | 클라이언트 비밀키 |
| `redirect_uri` | O | Step 1에서 사용한 것과 동일해야 함 |

```http
POST /oauth/token
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code&code=a1b2c3d4e5f6&client_id=client_001&client_secret=secret123&redirect_uri=https://myapp.com/callback
```

**성공 응답:**

```json
{
  "access_token": "eyJhbGciOiJIUzUxMiJ9...",
  "refresh_token": "eyJhbGciOiJIUzUxMiJ9...",
  "token_type": "Bearer",
  "expires_in": 86400000
}
```

---

### PKCE Flow (권장)

Public Client (SPA, Mobile App)의 보안을 강화하기 위한 PKCE 확장 흐름입니다.

#### 클라이언트 호출 요약

| 단계       | 엔드포인트 | 호출 주체 | 설명 |
|----------|-----------|----------|------|
| Step 0   | - | **클라이언트 앱** | code_verifier, code_challenge 생성 |
| Step 1   | `GET /oauth/authorize` | **클라이언트 앱** | 직접 호출 (code_challenge 포함) |
| Step 2~4 | `POST /oauth/login` | **브라우저** | 로그인 페이지 폼 제출, 클라이언트가 직접 호출 X |
| Step 5   | `POST /oauth/token` | **클라이언트 앱** | 직접 호출 (code_verifier 포함) |

```
┌──────────┐                              ┌──────────┐                              ┌──────────┐
│  Client  │                              │   API    │                              │   User   │
└────┬─────┘                              └────┬─────┘                              └────┬─────┘
     │                                         │                                         │
     │  0. code_verifier 생성 (랜덤 문자열)    │                                         │
     │     code_challenge = SHA256(verifier)   │                                         │
     │                                         │                                         │
     │  1. GET /oauth/authorize                │                                         │
     │    ?client_id=xxx                       │                                         │
     │    &redirect_uri=https://app/callback   │                                         │
     │    &response_type=code                  │                                         │
     │    &state=random123                     │                                         │
     │    &code_challenge=E9Mro...            │                                         │
     │    &code_challenge_method=S256          │                                         │
     │────────────────────────────────────────▶│                                         │
     │                                         │                                         │
     │         2. 로그인 페이지 표시            │                                         │
     │◀────────────────────────────────────────│                                         │
     │                                         │                                         │
     │                                         │     3. 로그인 정보 입력                  │
     │                                         │◀────────────────────────────────────────│
     │                                         │                                         │
     │  4. Redirect to                         │                                         │
     │     https://app/callback                │                                         │
     │       ?code=AUTH_CODE                   │                                         │
     │       &state=random123                  │                                         │
     │◀────────────────────────────────────────│                                         │
     │                                         │                                         │
     │  5. POST /oauth/token                   │                                         │
     │     grant_type=authorization_code       │                                         │
     │     code=AUTH_CODE                      │                                         │
     │     client_id=xxx                       │                                         │
     │     client_secret=xxx                   │                                         │
     │     redirect_uri=https://app/callback   │                                         │
     │     code_verifier=original_verifier     │  ◀── PKCE 검증                          │
     │────────────────────────────────────────▶│                                         │
     │                                         │                                         │
     │  6. {access_token, refresh_token, ...}  │                                         │
     │◀────────────────────────────────────────│                                         │
     │                                         │                                         │
```

#### Step 0: PKCE 값 생성

클라이언트 앱에서 Authorization 요청 전에 생성합니다.

```javascript
// 1. code_verifier 생성 (43-128자의 랜덤 문자열)
const code_verifier = generateRandomString(128);

// 2. code_challenge 생성 (SHA256 해시 후 Base64URL 인코딩)
const code_challenge = base64URLEncode(sha256(code_verifier));
```

#### Step 1: Authorization 요청 (PKCE)

| Parameter | Required | Description |
|-----------|----------|-------------|
| `client_id` | O | 등록된 OAuth 클라이언트 ID |
| `redirect_uri` | O | 콜백 URL (등록된 URI여야 함) |
| `response_type` | O | `code` 고정 |
| `state` | X | CSRF 방지용 |
| `code_challenge` | O | SHA256 해시된 code_verifier (Base64URL) |
| `code_challenge_method` | O | `S256` 고정 |

#### Step 2~4: 사용자 로그인

기본 흐름과 동일합니다. 브라우저에서 자동 처리됩니다.

#### Step 5~6: Token 교환 (PKCE)

| Parameter | Required | Description |
|-----------|----------|-------------|
| `grant_type` | O | `authorization_code` 고정 |
| `code` | O | Authorization Code |
| `client_id` | O | 클라이언트 ID |
| `client_secret` | O | 클라이언트 비밀키 |
| `redirect_uri` | O | Step 1에서 사용한 것과 동일 |
| `code_verifier` | O | Step 0에서 생성한 원본 verifier |

서버는 `code_verifier`를 SHA256 해시하여 저장된 `code_challenge`와 비교 검증합니다.

---

### Token 갱신 Flow

Access Token이 만료되면 Refresh Token으로 새 토큰을 발급받습니다.
**Authorization Code는 필요하지 않습니다.**

#### 클라이언트 호출 요약

| 단계   | 엔드포인트 | 호출 주체 | 설명 |
|--------|-----------|----------|------|
| Step 1 | `POST /oauth/token` | **클라이언트 앱** | grant_type=refresh_token으로 직접 호출 |

#### Request Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `grant_type` | O | `refresh_token` 고정 |
| `refresh_token` | O | 기존에 발급받은 Refresh Token |
| `client_id` | O | 클라이언트 ID |
| `client_secret` | O | 클라이언트 비밀키 |

#### Example Request

```http
POST /oauth/token
Content-Type: application/x-www-form-urlencoded

grant_type=refresh_token&refresh_token=eyJhbGciOiJIUzUxMiJ9...&client_id=client_001&client_secret=secret123
```

#### Success Response

```json
{
  "access_token": "eyJhbGciOiJIUzUxMiJ9...(새 토큰)",
  "refresh_token": "eyJhbGciOiJIUzUxMiJ9...(새 토큰)",
  "token_type": "Bearer",
  "expires_in": 86400000
}
```

> **Note:** Refresh Token도 만료되면 다시 로그인 (Authorization Code Flow)이 필요합니다.

---

## OAuth Controller

**Base Path:** `/oauth`

### GET /oauth/authorize

Authorization 요청을 시작합니다. 로그인 페이지로 이동합니다.

#### Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `client_id` | string | O | OAuth 클라이언트 ID |
| `redirect_uri` | string | O | 콜백 URL (등록된 URI여야 함) |
| `response_type` | string | O | 반드시 `code` |
| `state` | string | X | CSRF 방지용 (없으면 자동 생성) |
| `code_challenge` | string | X | PKCE용 code challenge (S256 해싱됨) |
| `code_challenge_method` | string | X | PKCE 메서드 (기본값: `S256`) |

#### Example Request (PKCE 미사용)

```http
GET /oauth/authorize?client_id=client_001&redirect_uri=https://myapp.com/callback&response_type=code&state=abc123
```

#### Example Request (PKCE 사용)

```http
GET /oauth/authorize?client_id=client_001&redirect_uri=https://myapp.com/callback&response_type=code&state=abc123&code_challenge=E9Mrozoa2owUzA7VLHwAIAKllCOvtQyen8P0xWXomaQ&code_challenge_method=S256
```

#### Response

로그인 페이지 (HTML) 또는 에러 페이지로 이동합니다.

---

### POST /oauth/login
> ⚠️ **클라이언트가 직접 호출하지 않음** - 이 과정은 브라우저에서 자동으로 처리됩니다.

사용자 인증 후 Authorization Code를 발급하고 callback URL로 리다이렉트합니다.

#### Request Parameters (application/x-www-form-urlencoded)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `email` | string | O | 사용자 이메일 |
| `password` | string | O | 비밀번호 |
| `client_id` | string | O | 클라이언트 ID |
| `redirect_uri` | string | O | 리다이렉트 URI |
| `state` | string | O | CSRF 토큰 |
| `code_challenge` | string | X | PKCE challenge |
| `code_challenge_method` | string | X | PKCE 메서드 |

#### Success Response

callback URL로 리다이렉트됩니다:

```
HTTP/1.1 302 Found
Location: https://myapp.com/callback?code=a1b2c3d4e5f6g7h8&state=abc123
```

#### Error Response

로그인 페이지로 돌아가며 에러 메시지가 표시됩니다.

---

### POST /oauth/token

Authorization Code를 Access Token으로 교환하거나, Refresh Token으로 새 토큰을 발급받습니다.

#### Grant Type: authorization_code

**Request Parameters (application/x-www-form-urlencoded)**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `grant_type` | string | O | `authorization_code` |
| `code` | string | O | Authorization Code |
| `client_id` | string | O | 클라이언트 ID |
| `client_secret` | string | O | 클라이언트 비밀키 |
| `redirect_uri` | string | O | 리다이렉트 URI |
| `code_verifier` | string | X | PKCE verifier (PKCE 사용 시 필수) |

**Example Request (PKCE 미사용)**

```http
POST /oauth/token
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code&code=a1b2c3d4e5f6g7h8&client_id=client_001&client_secret=secret123&redirect_uri=https://myapp.com/callback
```

**Example Request (PKCE 사용)**

```http
POST /oauth/token
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code&code=a1b2c3d4e5f6g7h8&client_id=client_001&client_secret=secret123&redirect_uri=https://myapp.com/callback&code_verifier=dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk
```

#### Grant Type: refresh_token

Access Token이 만료되었을 때 사용합니다. **Authorization Code 없이** Refresh Token만으로 새 토큰을 발급받습니다.

**Request Parameters (application/x-www-form-urlencoded)**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `grant_type` | string | O | `refresh_token` |
| `refresh_token` | string | O | Refresh Token |
| `client_id` | string | O | 클라이언트 ID |
| `client_secret` | string | O | 클라이언트 비밀키 |

**Example Request**

```http
POST /oauth/token
Content-Type: application/x-www-form-urlencoded

grant_type=refresh_token&refresh_token=eyJhbGciOiJIUzUxMiJ9...&client_id=client_001&client_secret=secret123
```

#### Success Response

```json
{
  "access_token": "eyJhbGciOiJIUzUxMiJ9...",
  "refresh_token": "eyJhbGciOiJIUzUxMiJ9...",
  "token_type": "Bearer",
  "expires_in": 86400000,
  "scope": "user:email user:profile"
}
```

#### Error Response

```json
{
  "error": "invalid_grant",
  "error_description": "Authorization code is invalid or expired"
}
```

| HTTP Status | Error | Description |
|-------------|-------|-------------|
| 400 | `invalid_grant` | 잘못된 코드/토큰 |
| 400 | `invalid_request` | 잘못된 요청 파라미터 |
| 500 | `server_error` | 서버 오류 |

---

### POST /oauth/logout

OAuth 세션을 종료합니다.

**Authentication Required:** Bearer Token

#### Request

**Query Parameter 방식:**
```http
POST /oauth/logout?refresh_token=eyJhbGciOiJIUzUxMiJ9...
Authorization: Bearer {access_token}
```

**Request Body 방식:**
```http
POST /oauth/logout
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "refresh_token": "eyJhbGciOiJIUzUxMiJ9..."
}
```

#### Success Response

```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

#### Error Response

```json
{
  "success": false,
  "error": "refresh_token is required"
}
```

---

## Auth Controller

**Base Path:** `/api/auth`

### POST /api/auth/register

새 사용자를 등록합니다.

#### Request Body

```json
{
  "email": "user@example.com",
  "username": "johndoe",
  "password": "SecurePass123!",
  "firstName": "John",
  "lastName": "Doe",
  "clientId": "client_001"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | O | 이메일 주소 |
| `username` | string | O | 사용자명 |
| `password` | string | O | 비밀번호 |
| `firstName` | string | O | 이름 |
| `lastName` | string | O | 성 |
| `clientId` | string | X | 클라이언트 ID |

#### Success Response (201 Created)

```json
{
  "message": "Registration successful. Please check your email to verify your account."
}
```

#### Error Response (400 Bad Request)

```json
{
  "error": "Email already exists"
}
```

---

### POST /api/auth/login (Deprecated)

> ⚠️ **Deprecated**: OAuth 2.0 (`/oauth/authorize`)을 사용하세요.

직접 로그인합니다.

#### Request Body

```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "clientId": "client_001"
}
```

#### Success Response (200 OK)

```json
{
  "accessToken": "eyJhbGciOiJIUzUxMiJ9...",
  "refreshToken": "eyJhbGciOiJIUzUxMiJ9...",
  "tokenType": "Bearer",
  "expiresIn": 86400000,
  "twoFactorRequired": false,
  "message": "Login successful",
  "deprecationWarning": "This endpoint is deprecated. Please use OAuth 2.0 (/oauth/authorize) for better security."
}
```

**Response Headers:**
```
Deprecation: true
Link: </oauth/authorize>; rel="successor-version"
```

---

### POST /api/auth/verify-2fa

2단계 인증 코드를 검증합니다.

#### Request Body

```json
{
  "email": "user@example.com",
  "code": "123456"
}
```

#### Success Response (200 OK)

```json
{
  "accessToken": "eyJhbGciOiJIUzUxMiJ9...",
  "refreshToken": "eyJhbGciOiJIUzUxMiJ9...",
  "tokenType": "Bearer",
  "expiresIn": 86400000
}
```

---

### POST /api/auth/refresh (Deprecated)

> ⚠️ **Deprecated**: `/oauth/token` (grant_type=refresh_token)을 사용하세요.

토큰을 갱신합니다.

#### Request Body

```json
{
  "refreshToken": "eyJhbGciOiJIUzUxMiJ9..."
}
```

#### Success Response (200 OK)

```json
{
  "accessToken": "eyJhbGciOiJIUzUxMiJ9...",
  "refreshToken": "eyJhbGciOiJIUzUxMiJ9...",
  "tokenType": "Bearer",
  "expiresIn": 86400000
}
```

---

### POST /api/auth/logout

**Authentication Required:** Bearer Token

현재 세션을 로그아웃합니다.

#### Request Body

```json
{
  "refreshToken": "eyJhbGciOiJIUzUxMiJ9...",
  "logoutAll": false
}
```

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `refreshToken` | string | X | - | Refresh Token |
| `logoutAll` | boolean | X | `false` | 모든 세션 로그아웃 여부 |

#### Success Response (200 OK)

```json
{
  "message": "Logged out successfully"
}
```

---

### POST /api/auth/request-password-reset

비밀번호 재설정 이메일을 요청합니다.

#### Request Body

```json
{
  "email": "user@example.com",
  "clientId": "client_001"
}
```

#### Success Response (200 OK)

```json
{
  "message": "Password reset link has been sent to your email"
}
```

---

### POST /api/auth/reset-password

비밀번호를 재설정합니다.

#### Request Body

```json
{
  "email": "user@example.com",
  "token": "reset_token_from_email",
  "newPassword": "NewSecurePass123!",
  "confirmPassword": "NewSecurePass123!"
}
```

#### Success Response (200 OK)

```json
{
  "message": "Password reset successful"
}
```

---

### GET /api/auth/verify-email

이메일 주소를 검증합니다.

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `token` | string | O | 이메일 검증 토큰 |

#### Example Request

```http
GET /api/auth/verify-email?token=verification_token_from_email
```

#### Success Response (200 OK)

```json
{
  "message": "Email verified successfully"
}
```

---

### POST /api/auth/enable-2fa

**Authentication Required:** Bearer Token

2단계 인증을 활성화합니다.

#### Success Response (200 OK)

```json
{
  "message": "Two-factor authentication enabled"
}
```

---

### POST /api/auth/disable-2fa

**Authentication Required:** Bearer Token

2단계 인증을 비활성화합니다.

#### Success Response (200 OK)

```json
{
  "message": "Two-factor authentication disabled"
}
```

---

## Client Controller

**Base Path:** `/api/clients`

OAuth 클라이언트 애플리케이션을 관리합니다.

### POST /api/clients/register

새 OAuth 클라이언트를 등록합니다.

#### Request Body

```json
{
  "name": "My Application",
  "description": "A sample OAuth client application",
  "frontendUrl": "https://myapp.com",
  "redirectUris": [
    "https://myapp.com/callback",
    "https://myapp.com/auth/callback"
  ],
  "maxTokensPerUser": 5
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | O | 클라이언트 이름 |
| `description` | string | X | 설명 |
| `frontendUrl` | string | O | 프론트엔드 URL |
| `redirectUris` | string[] | O | 허용된 리다이렉트 URI 목록 (최소 1개) |
| `maxTokensPerUser` | integer | X | 사용자당 최대 토큰 수 |

#### Success Response (201 Created)

```json
{
  "message": "Client registered successfully",
  "client": {
    "id": 1,
    "clientId": "client_a1b2c3d4e5f6",
    "clientSecret": "secret_x9y8z7w6v5u4",
    "name": "My Application",
    "description": "A sample OAuth client application",
    "frontendUrl": "https://myapp.com",
    "redirectUris": [
      "https://myapp.com/callback",
      "https://myapp.com/auth/callback"
    ],
    "enabled": true,
    "maxTokensPerUser": 5,
    "ownerEmail": null,
    "createdAt": "2025-12-03T10:00:00",
    "updatedAt": "2025-12-03T10:00:00"
  }
}
```

> ⚠️ **중요**: `clientSecret`은 이 응답에서만 확인할 수 있습니다. 안전하게 저장하세요.

---

### GET /api/clients/{clientId}

클라이언트 정보를 조회합니다.

#### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `clientId` | string | O | OAuth 클라이언트 ID |

#### Example Request

```http
GET /api/clients/client_a1b2c3d4e5f6
```

#### Success Response (200 OK)

```json
{
  "client": {
    "id": 1,
    "clientId": "client_a1b2c3d4e5f6",
    "name": "My Application",
    "description": "A sample OAuth client application",
    "frontendUrl": "https://myapp.com",
    "redirectUris": [
      "https://myapp.com/callback"
    ],
    "enabled": true,
    "maxTokensPerUser": 5,
    "ownerEmail": null,
    "createdAt": "2025-12-03T10:00:00",
    "updatedAt": "2025-12-03T10:00:00"
  }
}
```

> **Note:** `clientSecret`은 보안상 조회 API에서 반환되지 않습니다. 클라이언트 등록 시에만 한 번 확인할 수 있습니다.

#### Error Response (404 Not Found)

```json
{
  "error": "Client not found"
}
```

---

### GET /api/clients/exists/{clientId}

클라이언트 존재 여부를 확인합니다.

#### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `clientId` | string | O | OAuth 클라이언트 ID |

#### Example Request

```http
GET /api/clients/exists/client_a1b2c3d4e5f6
```

#### Success Response (200 OK)

```json
{
  "exists": true
}
```

---

## Session Controller

**Base Path:** `/api/sessions`

**Authentication Required:** 모든 엔드포인트에 Bearer Token 필요

사용자의 활성 세션을 관리합니다.

### GET /api/sessions

활성 세션 목록을 조회합니다.

#### Request Headers

| Header | Required | Description |
|--------|----------|-------------|
| `Authorization` | O | `Bearer {access_token}` |
| `X-Refresh-Token` | X | 현재 세션 식별용 Refresh Token |

#### Success Response (200 OK)

```json
{
  "totalSessions": 2,
  "sessions": [
    {
      "sessionId": "sess_abc123def456",
      "deviceType": "Desktop",
      "deviceName": "Chrome on Windows",
      "ipAddress": "192.168.1.100",
      "location": "Seoul, South Korea",
      "lastActiveAt": "2025-12-03T10:30:00",
      "createdAt": "2025-12-03T09:00:00",
      "expiresAt": "2025-12-10T09:00:00",
      "isCurrent": true
    },
    {
      "sessionId": "sess_xyz789uvw012",
      "deviceType": "Mobile",
      "deviceName": "Safari on iPhone",
      "ipAddress": "192.168.1.101",
      "location": "Seoul, South Korea",
      "lastActiveAt": "2025-12-02T15:00:00",
      "createdAt": "2025-12-02T14:00:00",
      "expiresAt": "2025-12-09T14:00:00",
      "isCurrent": false
    }
  ]
}
```

---

### DELETE /api/sessions/{sessionId}

특정 세션을 무효화합니다 (원격 로그아웃).

#### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `sessionId` | string | O | 세션 ID |

#### Example Request

```http
DELETE /api/sessions/sess_xyz789uvw012
Authorization: Bearer {access_token}
```

#### Success Response (200 OK)

```json
{
  "message": "Session revoked successfully"
}
```

---

### POST /api/sessions/revoke-others

현재 세션을 제외한 모든 세션을 무효화합니다.

#### Request Headers

| Header | Required | Description |
|--------|----------|-------------|
| `Authorization` | O | `Bearer {access_token}` |
| `X-Refresh-Token` | O | 현재 세션의 Refresh Token |

#### Example Request

```http
POST /api/sessions/revoke-others
Authorization: Bearer {access_token}
X-Refresh-Token: {refresh_token}
```

#### Success Response (200 OK)

```json
{
  "message": "Other sessions revoked successfully"
}
```

---

### POST /api/sessions/revoke-all

모든 세션을 무효화합니다 (전체 로그아웃).

#### Example Request

```http
POST /api/sessions/revoke-all
Authorization: Bearer {access_token}
```

#### Success Response (200 OK)

```json
{
  "message": "All sessions revoked successfully"
}
```

---

## DTO Reference

### Request DTOs

| DTO | Fields |
|-----|--------|
| **RegisterRequest** | `email`, `username`, `password`, `firstName`, `lastName`, `clientId` |
| **AuthRequest** | `email`, `password`, `clientId` |
| **TwoFactorRequest** | `email`, `code` |
| **RefreshTokenRequest** | `refreshToken` |
| **LogoutRequest** | `refreshToken`, `logoutAll` |
| **PasswordResetRequest** | `email`, `token`, `newPassword`, `confirmPassword` |
| **ClientRegistrationRequest** | `name`, `description`, `frontendUrl`, `redirectUris`, `maxTokensPerUser` |

### Response DTOs

| DTO | Fields |
|-----|--------|
| **AuthResponse** | `accessToken`, `refreshToken`, `tokenType`, `expiresIn`, `twoFactorRequired`, `message`, `deprecationWarning` |
| **OAuthTokenResponse** | `access_token`, `refresh_token`, `token_type`, `expires_in`, `scope` |
| **ClientResponse** | `id`, `clientId`, `clientSecret`, `name`, `description`, `frontendUrl`, `redirectUris`, `enabled`, `maxTokensPerUser`, `ownerEmail`, `createdAt`, `updatedAt` |
| **SessionListResponse** | `totalSessions`, `sessions` |
| **UserSessionDTO** | `sessionId`, `deviceType`, `deviceName`, `ipAddress`, `location`, `lastActiveAt`, `createdAt`, `expiresAt`, `isCurrent` |

---

## 에러 응답

### 일반 에러 형식

```json
{
  "error": "error_code",
  "error_description": "Human readable error message"
}
```

또는

```json
{
  "message": "Error message"
}
```

### HTTP 상태 코드

| Status Code | Description |
|-------------|-------------|
| 200 | 성공 |
| 201 | 생성 성공 |
| 400 | 잘못된 요청 (파라미터 오류, 검증 실패) |
| 401 | 인증 실패 (토큰 만료, 잘못된 자격 증명) |
| 403 | 권한 없음 |
| 404 | 리소스를 찾을 수 없음 |
| 500 | 서버 오류 |

### OAuth 에러 코드

| Error Code | Description |
|------------|-------------|
| `invalid_request` | 요청 파라미터 오류 |
| `invalid_grant` | Authorization Code 또는 Refresh Token 오류 |
| `invalid_client` | 클라이언트 인증 실패 |
| `unauthorized_client` | 클라이언트가 해당 grant type을 사용할 수 없음 |
| `unsupported_grant_type` | 지원하지 않는 grant type |
| `server_error` | 서버 내부 오류 |

---

## 보안 고려사항

1. **PKCE 사용 권장**: Public Client (SPA, Mobile)에서는 반드시 PKCE를 사용하세요.
2. **HTTPS 필수**: 모든 API 호출은 HTTPS를 통해 이루어져야 합니다.
3. **토큰 저장**: Access Token은 메모리에, Refresh Token은 Secure Cookie 또는 Secure Storage에 저장하세요.
4. **세션 제한**: 사용자당 최대 5개의 동시 세션이 허용됩니다.
5. **Token Rotation**: 토큰 갱신 시 기존 Refresh Token은 무효화됩니다.
