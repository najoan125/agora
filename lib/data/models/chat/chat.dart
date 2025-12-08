import 'package:json_annotation/json_annotation.dart';

part 'chat.g.dart';

/// 채팅 타입
enum ChatType {
  @JsonValue('DIRECT')
  direct,
  @JsonValue('GROUP')
  group,
}

/// 채팅방 모델
@JsonSerializable()
class Chat {
  @JsonKey(name: 'chatId')
  final dynamic id;
  final ChatType? type;
  final String? name;
  @JsonKey(name: 'profileImage')
  final String? profileImageUrl;
  final int? participantCount;
  @JsonKey(name: 'lastMessageContent')
  final dynamic lastMessageContent;
  @JsonKey(name: 'lastMessageTime')
  final DateTime? lastMessageAt;
  @JsonKey(defaultValue: 0)
  final int unreadCount;
  @JsonKey(defaultValue: false)
  final bool isPinned;
  final String? folderId;
  final DateTime? createdAt;

  const Chat({
    required this.id,
    this.type,
    this.name,
    this.profileImageUrl,
    this.participantCount,
    this.lastMessageContent,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isPinned = false,
    this.folderId,
    this.createdAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
  Map<String, dynamic> toJson() => _$ChatToJson(this);

  /// lastMessage 문자열 접근
  ChatMessage? get lastMessage {
    if (lastMessageContent == null) return null;
    if (lastMessageContent is String) {
      return ChatMessage(
        id: '',
        senderAgoraId: '',
        content: lastMessageContent,
        type: MessageType.text,
        createdAt: lastMessageAt ?? DateTime.now(),
      );
    }
    if (lastMessageContent is Map<String, dynamic>) {
      return ChatMessage.fromJson(lastMessageContent);
    }
    return null;
  }

  /// 표시할 이름
  String getDisplayName(String myAgoraId) {
    return name ?? '채팅';
  }

  /// 표시할 프로필 이미지
  String? getDisplayImage(String myAgoraId) {
    return profileImageUrl;
  }
}

/// 채팅 참여자
@JsonSerializable()
class ChatParticipant {
  final String id;
  final String agoraId;
  final String displayName;
  final String? profileImageUrl;
  final ChatParticipantRole role;
  final DateTime joinedAt;

  const ChatParticipant({
    required this.id,
    required this.agoraId,
    required this.displayName,
    this.profileImageUrl,
    required this.role,
    required this.joinedAt,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) =>
      _$ChatParticipantFromJson(json);
  Map<String, dynamic> toJson() => _$ChatParticipantToJson(this);
}

/// 참여자 역할
enum ChatParticipantRole {
  @JsonValue('ADMIN')
  admin,
  @JsonValue('MEMBER')
  member,
}

/// 채팅방 목록 응답
@JsonSerializable()
class ChatListResponse {
  final List<Chat> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool last;

  const ChatListResponse({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory ChatListResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ChatListResponseToJson(this);
}

/// 채팅 메시지 (간단한 버전 - Chat 모델에 포함)
@JsonSerializable()
class ChatMessage {
  @JsonKey(name: 'messageId')
  final dynamic id;
  final String? chatId;
  final String senderAgoraId;
  final String? senderEmail;
  final String? senderProfileImage;
  final String? senderDisplayName;
  final String content;
  final MessageType type;
  @JsonKey(defaultValue: false)
  final bool isDeleted;
  final String? replyToId;
  final List<MessageAttachment>? attachments;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    this.chatId,
    required this.senderAgoraId,
    this.senderEmail,
    this.senderProfileImage,
    this.senderDisplayName,
    required this.content,
    required this.type,
    this.isDeleted = false,
    this.replyToId,
    this.attachments,
    required this.createdAt,
  });

  /// 표시할 발신자 이름 (senderDisplayName 없으면 senderAgoraId 사용)
  String get displayName => senderDisplayName ?? senderAgoraId;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
}

/// 메시지 타입
enum MessageType {
  @JsonValue('TEXT')
  text,
  @JsonValue('IMAGE')
  image,
  @JsonValue('FILE')
  file,
  @JsonValue('SYSTEM')
  system,
}

/// 메시지 첨부파일
@JsonSerializable()
class MessageAttachment {
  final String id;
  final String fileId;
  final String fileName;
  final String fileUrl;
  final String? thumbnailUrl;
  final int fileSize;
  final String mimeType;

  const MessageAttachment({
    required this.id,
    required this.fileId,
    required this.fileName,
    required this.fileUrl,
    this.thumbnailUrl,
    required this.fileSize,
    required this.mimeType,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) =>
      _$MessageAttachmentFromJson(json);
  Map<String, dynamic> toJson() => _$MessageAttachmentToJson(this);
}

/// 메시지 목록 응답 (커서 페이지네이션)
@JsonSerializable()
class MessageListResponse {
  @JsonKey(name: 'messages')
  final List<ChatMessage> content;
  final dynamic nextCursor;
  @JsonKey(defaultValue: false)
  final bool hasNext;

  const MessageListResponse({
    required this.content,
    this.nextCursor,
    required this.hasNext,
  });

  factory MessageListResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MessageListResponseToJson(this);
}
