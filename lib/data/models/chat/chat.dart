import 'package:json_annotation/json_annotation.dart';

part 'chat.g.dart';

/// 채팅 타입
enum ChatType {
  @JsonValue('DIRECT')
  direct,
  @JsonValue('GROUP')
  group,
}

/// 채팅 컨텍스트
enum ChatContext {
  @JsonValue('FRIEND')
  friend,
  @JsonValue('TEAM')
  team,
}

/// 채팅방 모델
@JsonSerializable()
class Chat {
  @JsonKey(name: 'chatId')
  final dynamic id;
  final ChatType? type;
  final ChatContext? context;
  final String? displayName;
  final String? displayImage;
  final String? name;
  @JsonKey(name: 'profileImage')
  final String? profileImageUrl;
  final int? teamId;
  final String? teamName;
  final int? participantCount;
  final List<ParticipantProfile>? participants;
  final ParticipantProfile? otherParticipant;
  final int? readCount;
  final bool? readEnabled;
  final int? messageCount;
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
  final DateTime? updatedAt;

  const Chat({
    required this.id,
    this.type,
    this.context,
    this.displayName,
    this.displayImage,
    this.name,
    this.profileImageUrl,
    this.teamId,
    this.teamName,
    this.participantCount,
    this.participants,
    this.otherParticipant,
    this.readCount,
    this.readEnabled,
    this.messageCount,
    this.lastMessageContent,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isPinned = false,
    this.folderId,
    this.createdAt,
    this.updatedAt,
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

  /// 표시할 이름 (우선순위: otherParticipant > participants > displayName > name)
  String getDisplayName(String myAgoraId) {
    if (type == ChatType.direct) {
      if (otherParticipant != null) {
        return otherParticipant!.displayName;
      }
      if (participants != null && participants!.isNotEmpty) {
        final other = participants!.firstWhere(
          (p) => p.identifier != myAgoraId,
          orElse: () => participants!.first,
        );
        return other.displayName;
      }
    }
    return displayName ?? name ?? '채팅';
  }

  /// 표시할 프로필 이미지 (우선순위: otherParticipant > participants > displayImage > profileImageUrl)
  String? getDisplayImage(String myAgoraId) {
    if (type == ChatType.direct) {
      if (otherParticipant != null) {
        return otherParticipant!.profileImage;
      }
      if (participants != null && participants!.isNotEmpty) {
        final other = participants!.firstWhere(
          (p) => p.identifier != myAgoraId,
          orElse: () => participants!.first,
        );
        return other.profileImage;
      }
    }
    return displayImage ?? profileImageUrl;
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
  @JsonKey(fromJson: _chatIdFromJson)
  final String? chatId;

  static String? _chatIdFromJson(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }
  @JsonKey(name: 'senderId')
  final int? senderId;
  final String senderAgoraId;
  @JsonKey(name: 'senderName')
  final String? senderName;
  final String? senderEmail;
  final String? senderProfileImage;
  final String? senderDisplayName;
  final String content;
  final MessageType type;
  @JsonKey(defaultValue: false)
  final bool isDeleted;
  @JsonKey(defaultValue: false)
  final bool isPinned;
  final String? replyToId;
  final List<MessageAttachment>? attachments;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    this.chatId,
    this.senderId,
    required this.senderAgoraId,
    this.senderName,
    this.senderEmail,
    this.senderProfileImage,
    this.senderDisplayName,
    required this.content,
    required this.type,
    this.isDeleted = false,
    this.isPinned = false,
    this.replyToId,
    this.attachments,
    required this.createdAt,
  });

  /// 표시할 발신자 이름 (우선순위: senderName > senderDisplayName > senderAgoraId)
  String get displayName => senderName ?? senderDisplayName ?? senderAgoraId;

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

/// 참여자 프로필 (API 응답용)
@JsonSerializable()
class ParticipantProfile {
  final int userId;
  final String displayName;
  final String? profileImage;
  final String? identifier; // FRIEND: agoraId, TEAM: null

  const ParticipantProfile({
    required this.userId,
    required this.displayName,
    this.profileImage,
    this.identifier,
  });

  factory ParticipantProfile.fromJson(Map<String, dynamic> json) =>
      _$ParticipantProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ParticipantProfileToJson(this);
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
