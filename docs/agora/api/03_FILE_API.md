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
  "fileName": "document_abc123.pdf",
  "originalName": "document.pdf",
  "fileUrl": "https://cdn.hyfata.com/files/document_abc123.pdf",
  "thumbnailUrl": null,
  "fileSize": 2048000,
  "mimeType": "application/pdf",
  "fileType": "DOCUMENT",
  "createdAt": "2025-01-15T10:30:00"
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
  "fileName": "profile_xyz456.jpg",
  "originalName": "profile.jpg",
  "fileUrl": "https://cdn.hyfata.com/files/profile_xyz456.jpg",
  "thumbnailUrl": "https://cdn.hyfata.com/files/profile_xyz456_thumb.jpg",
  "fileSize": 512000,
  "mimeType": "image/jpeg",
  "fileType": "IMAGE",
  "createdAt": "2025-01-15T10:35:00"
}
```

---

## 3. GET /meta/{fileId} - 파일 메타데이터 조회

```http
GET /api/agora/files/meta/1
Authorization: Bearer {access_token}
```

### Response 200
```json
{
  "fileId": 1,
  "fileName": "document_abc123.pdf",
  "originalName": "document.pdf",
  "fileUrl": "https://cdn.hyfata.com/files/document_abc123.pdf",
  "thumbnailUrl": null,
  "fileSize": 2048000,
  "mimeType": "application/pdf",
  "fileType": "DOCUMENT",
  "createdAt": "2025-01-15T10:30:00"
}
```

---

## 4. GET /{fileName} - 파일 서빙 (공개)

업로드된 파일을 파일명으로 조회하여 다운로드합니다. 인증 없이 접근 가능합니다.

### Request
```http
GET /api/agora/files/document_abc123.pdf
```

### Response 200
파일 바이너리 데이터 반환

### Query Parameters
없음

### 주의사항
- 공개 접근 가능 (인증 불필요)
- 파일명은 업로드 시 자동 생성된 고유 파일명 사용
- Content-Type 헤더는 파일의 MIME 타입으로 설정됨

---

## 5. GET /{fileId}/download - 파일 다운로드

```http
GET /api/agora/files/1/download
Authorization: Bearer {access_token}
```

**응답**: 파일 바이너리 (Content-Type: 파일 형식)

---

## 6. DELETE /{fileId} - 파일 삭제

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
