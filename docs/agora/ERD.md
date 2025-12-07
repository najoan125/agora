# Agora Module ERD

Agora 모듈 23개 Entity의 ERD (도메인별 분리)

---

## 1. User & Profile

```mermaid
erDiagram
    User ||--|| AgoraUserProfile : has
    AgoraUserProfile ||--o| TeamProfile : has

    AgoraUserProfile {
        Long id PK
        String agoraId UK
        String displayName
        String profileImage
        String bio
        String phone
        LocalDate birthday
    }

    TeamProfile {
        Long id PK
        String displayName
        String profileImage
    }

    User ||--|| UserSettings : has

    UserSettings {
        Long id PK
        Boolean pushEnabled
        Boolean messageNotification
        Boolean friendRequestNotification
        Boolean teamNotification
        Enum profileVisibility
        Enum phoneVisibility
        Enum birthdayVisibility
        Boolean allowFriendRequests
        Boolean showOnlineStatus
    }
```

---

## 2. Chat

```mermaid
erDiagram
    User ||--o{ Chat : creates
    Chat ||--|{ ChatParticipant : has
    User ||--o{ ChatParticipant : participates
    User ||--o{ ChatFolder : owns
    ChatFolder ||--|{ ChatFolderItem : contains
    Chat ||--o{ ChatFolderItem : referenced

    Chat {
        Long id PK
        Enum type "DIRECT, GROUP"
        String name
        String profileImage
        Long readCount
        Boolean readEnabled
    }

    ChatParticipant {
        Long id PK
        Enum role "ADMIN, MEMBER"
        Boolean isPinned
        LocalDateTime joinedAt
    }

    ChatFolder {
        Long id PK
        String name
        Integer orderIndex
    }

    ChatFolderItem {
        Long id PK
        LocalDateTime createdAt
    }
```

---

## 3. Message

```mermaid
erDiagram
    Chat ||--|{ Message : contains
    User ||--o{ Message : sends
    Message ||--o| Message : replyTo
    Message ||--o{ MessageAttachment : has
    AgoraFile ||--o{ MessageAttachment : attached
    Message ||--o{ MessageReadStatus : has
    User ||--o{ MessageReadStatus : reads

    Message {
        Long id PK
        String content
        Enum type "TEXT, IMAGE, FILE, SYSTEM"
        Boolean isDeleted
        Boolean isPinned
    }

    MessageAttachment {
        Long id PK
        Integer orderIndex
    }

    MessageReadStatus {
        Long id PK
    }
```

---

## 4. Team

```mermaid
erDiagram
    User ||--o{ Team : creates
    Team ||--|{ TeamMember : has
    User ||--o{ TeamMember : joins
    TeamRole ||--o{ TeamMember : assigned
    Team ||--|{ TeamRole : defines

    Team {
        Long id PK
        String name
        String description
        String profileImage
        Boolean isMain
    }

    TeamMember {
        Long id PK
        LocalDateTime joinedAt
    }

    TeamRole {
        Long id PK
        String name
        String permissions
    }

    Team ||--o{ Notice : has
    User ||--o{ Notice : writes

    Notice {
        Long id PK
        String title
        String content
        Boolean isPinned
    }

    Team ||--o{ Todo : has
    User ||--o{ Todo : creates
    User ||--o{ Todo : assignedTo

    Todo {
        Long id PK
        String title
        String description
        Enum status "TODO, IN_PROGRESS, DONE"
        Enum priority "LOW, MEDIUM, HIGH"
        LocalDateTime dueDate
    }

    Team ||--o{ Event : has
    User ||--o{ Event : creates

    Event {
        Long id PK
        String title
        String description
        String location
        LocalDateTime startTime
        LocalDateTime endTime
        Boolean isAllDay
    }
```

---

## 5. Social

```mermaid
erDiagram
    User ||--o{ Friend : has
    User ||--o{ Friend : friendOf

    Friend {
        Long id PK
        Boolean isFavorite
        LocalDateTime createdAt
    }

    User ||--o{ FriendRequest : sends
    User ||--o{ FriendRequest : receives

    FriendRequest {
        Long id PK
        Enum status "PENDING, ACCEPTED, REJECTED"
    }

    User ||--o{ BlockedUser : blocks
    User ||--o{ BlockedUser : blockedBy

    BlockedUser {
        Long id PK
        LocalDateTime createdAt
    }
```

---

## 6. File & Notification

```mermaid
erDiagram
    User ||--o{ AgoraFile : uploads
    AgoraFile ||--|| FileMetadata : has

    AgoraFile {
        Long id PK
        String fileName
        String originalName
        String filePath
        String fileUrl
        Long fileSize
        String mimeType
        Enum fileType "IMAGE, VIDEO, DOCUMENT, OTHER"
    }

    FileMetadata {
        Long id PK
        Integer width
        Integer height
        Integer duration
        String metadata
    }

    User ||--o{ Notification : receives

    Notification {
        Long id PK
        String type
        String title
        String content
        Long relatedId
        String relatedType
        Boolean isRead
    }

    User ||--o{ FcmToken : owns

    FcmToken {
        Long id PK
        String token UK
        Enum deviceType "ANDROID, IOS, WEB"
        String deviceId
    }
```

---

## Entity 요약

| 도메인 | Entity | 개수 |
|--------|--------|------|
| User & Profile | AgoraUserProfile, TeamProfile, UserSettings | 3 |
| Chat | Chat, ChatParticipant, ChatFolder, ChatFolderItem | 4 |
| Message | Message, MessageAttachment, MessageReadStatus | 3 |
| Team | Team, TeamMember, TeamRole, Notice, Todo, Event | 6 |
| Social | Friend, FriendRequest, BlockedUser | 3 |
| File & Notification | AgoraFile, FileMetadata, Notification, FcmToken | 4 |
| **합계** | | **23** |
