# 파일 업로드/다운로드 API

## Base URL
`/api/agora/files`

## 인증
Bearer Token (OAuth 2.0)

---

## 1. POST /upload - 파일 업로드

일반 파일을 업로드합니다.

### Request
```http
POST /api/agora/files/upload
Authorization: Bearer {access_token}
Content-Type: multipart/form-data

file: (바이너리 파일)
```

### Response 200
```json
{
  "fileId": 1,
  "fileName": "document.pdf",
  "fileSize": 2048000,
  "mimeType": "application/pdf",
  "url": "https://cdn.hyfata.com/files/document_abc123.pdf",
  "uploadedAt": "2025-01-15T10:30:00"
}
```

### Error Responses
| Status | Error | Description |
|--------|-------|-------------|
| 400 | FILE_TOO_LARGE | 파일이 50MB를 초과합니다 |
| 400 | INVALID_FILE_TYPE | 지원하지 않는 파일 형식입니다 |

---

## 2. POST /upload-image - 이미지 업로드 (썸네일 포함)

이미지를 업로드하고 자동으로 썸네일을 생성합니다.

### Request
```http
POST /api/agora/files/upload-image
Authorization: Bearer {access_token}
Content-Type: multipart/form-data

file: (이미지 바이너리)
```

### Response 200
```json
{
  "fileId": 2,
  "fileName": "profile.jpg",
  "fileSize": 512000,
  "mimeType": "image/jpeg",
  "url": "https://cdn.hyfata.com/files/profile_abc123.jpg",
  "thumbnailUrl": "https://cdn.hyfata.com/files/profile_abc123_thumb.jpg",
  "uploadedAt": "2025-01-15T10:32:00"
}
```

---

## 3. GET /{fileId} - 파일 메타데이터 조회

```http
GET /api/agora/files/1
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "fileId": 1,
  "fileName": "document.pdf",
  "fileSize": 2048000,
  "mimeType": "application/pdf",
  "url": "https://cdn.hyfata.com/files/document_abc123.pdf",
  "uploadedAt": "2025-01-15T10:30:00",
  "uploadedBy": "user@example.com"
}
```

---

## 4. GET /{fileId}/download - 파일 다운로드

```http
GET /api/agora/files/1/download
Authorization: Bearer {access_token}
```

**응답**: 파일 바이너리 (Content-Type: 파일 형식)

---

## 5. DELETE /{fileId} - 파일 삭제

```http
DELETE /api/agora/files/1
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "message": "파일이 삭제되었습니다"
}
```

---

## 지원 파일 형식

### 이미지
- JPEG, PNG, GIF, WebP

### 문서
- PDF, DOC, DOCX, XLS, XLSX, PPT, PPTX

### 기타
- TXT, CSV, JSON, ZIP

---

## 제한사항

| 항목 | 제한 |
|------|------|
| 최대 파일 크기 | 50MB |
| 이미지 썸네일 크기 | 200x200px |
| 저장 기간 | 무제한 |
