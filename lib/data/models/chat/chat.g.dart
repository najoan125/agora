// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chat _$ChatFromJson(Map<String, dynamic> json) => Chat(
      id: json['chatId'],
      type: $enumDecodeNullable(_$ChatTypeEnumMap, json['type']),
      context: $enumDecodeNullable(_$ChatContextEnumMap, json['context']),
      displayName: json['displayName'] as String?,
      displayImage: json['displayImage'] as String?,
      name: json['name'] as String?,
      profileImageUrl: json['profileImage'] as String?,
      teamId: (json['teamId'] as num?)?.toInt(),
      teamName: json['teamName'] as String?,
      participantCount: (json['participantCount'] as num?)?.toInt(),
      participants: (json['participants'] as List<dynamic>?)
          ?.map((e) => ParticipantProfile.fromJson(e as Map<String, dynamic>))
          .toList(),
      otherParticipant: json['otherParticipant'] == null
          ? null
          : ParticipantProfile.fromJson(
              json['otherParticipant'] as Map<String, dynamic>),
      readCount: (json['readCount'] as num?)?.toInt(),
      readEnabled: json['readEnabled'] as bool?,
      messageCount: (json['messageCount'] as num?)?.toInt(),
      lastMessageContent: json['lastMessageContent'],
      lastMessageAt: json['lastMessageTime'] == null
          ? null
          : DateTime.parse(json['lastMessageTime'] as String),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isPinned: json['isPinned'] as bool? ?? false,
      folderId: json['folderId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
      'chatId': instance.id,
      'type': _$ChatTypeEnumMap[instance.type],
      'context': _$ChatContextEnumMap[instance.context],
      'displayName': instance.displayName,
      'displayImage': instance.displayImage,
      'name': instance.name,
      'profileImage': instance.profileImageUrl,
      'teamId': instance.teamId,
      'teamName': instance.teamName,
      'participantCount': instance.participantCount,
      'participants': instance.participants,
      'otherParticipant': instance.otherParticipant,
      'readCount': instance.readCount,
      'readEnabled': instance.readEnabled,
      'messageCount': instance.messageCount,
      'lastMessageContent': instance.lastMessageContent,
      'lastMessageTime': instance.lastMessageAt?.toIso8601String(),
      'unreadCount': instance.unreadCount,
      'isPinned': instance.isPinned,
      'folderId': instance.folderId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$ChatTypeEnumMap = {
  ChatType.direct: 'DIRECT',
  ChatType.group: 'GROUP',
};

const _$ChatContextEnumMap = {
  ChatContext.friend: 'FRIEND',
  ChatContext.team: 'TEAM',
};

ChatParticipant _$ChatParticipantFromJson(Map<String, dynamic> json) =>
    ChatParticipant(
      id: json['id'] as String,
      agoraId: json['agoraId'] as String,
      displayName: json['displayName'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      role: $enumDecode(_$ChatParticipantRoleEnumMap, json['role']),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$ChatParticipantToJson(ChatParticipant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'agoraId': instance.agoraId,
      'displayName': instance.displayName,
      'profileImageUrl': instance.profileImageUrl,
      'role': _$ChatParticipantRoleEnumMap[instance.role]!,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };

const _$ChatParticipantRoleEnumMap = {
  ChatParticipantRole.admin: 'ADMIN',
  ChatParticipantRole.member: 'MEMBER',
};

ChatListResponse _$ChatListResponseFromJson(Map<String, dynamic> json) =>
    ChatListResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => Chat.fromJson(e as Map<String, dynamic>))
          .toList(),
      pageNumber: (json['pageNumber'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      last: json['last'] as bool,
    );

Map<String, dynamic> _$ChatListResponseToJson(ChatListResponse instance) =>
    <String, dynamic>{
      'content': instance.content,
      'pageNumber': instance.pageNumber,
      'pageSize': instance.pageSize,
      'totalElements': instance.totalElements,
      'totalPages': instance.totalPages,
      'last': instance.last,
    };

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
      id: json['messageId'],
      chatId: ChatMessage._chatIdFromJson(json['chatId']),
      senderId: (json['senderId'] as num?)?.toInt(),
      senderAgoraId: json['senderAgoraId'] as String,
      senderName: json['senderName'] as String?,
      senderEmail: json['senderEmail'] as String?,
      senderProfileImage: json['senderProfileImage'] as String?,
      senderDisplayName: json['senderDisplayName'] as String?,
      content: json['content'] as String,
      type: $enumDecode(_$MessageTypeEnumMap, json['type']),
      isDeleted: json['isDeleted'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      replyToId: json['replyToId'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => MessageAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'messageId': instance.id,
      'chatId': instance.chatId,
      'senderId': instance.senderId,
      'senderAgoraId': instance.senderAgoraId,
      'senderName': instance.senderName,
      'senderEmail': instance.senderEmail,
      'senderProfileImage': instance.senderProfileImage,
      'senderDisplayName': instance.senderDisplayName,
      'content': instance.content,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'isDeleted': instance.isDeleted,
      'isPinned': instance.isPinned,
      'replyToId': instance.replyToId,
      'attachments': instance.attachments,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'TEXT',
  MessageType.image: 'IMAGE',
  MessageType.file: 'FILE',
  MessageType.system: 'SYSTEM',
};

MessageAttachment _$MessageAttachmentFromJson(Map<String, dynamic> json) =>
    MessageAttachment(
      id: json['id'] as String,
      fileId: json['fileId'] as String,
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      fileSize: (json['fileSize'] as num).toInt(),
      mimeType: json['mimeType'] as String,
    );

Map<String, dynamic> _$MessageAttachmentToJson(MessageAttachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fileId': instance.fileId,
      'fileName': instance.fileName,
      'fileUrl': instance.fileUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'fileSize': instance.fileSize,
      'mimeType': instance.mimeType,
    };

ParticipantProfile _$ParticipantProfileFromJson(Map<String, dynamic> json) =>
    ParticipantProfile(
      userId: (json['userId'] as num).toInt(),
      displayName: json['displayName'] as String,
      profileImage: json['profileImage'] as String?,
      identifier: json['identifier'] as String?,
    );

Map<String, dynamic> _$ParticipantProfileToJson(ParticipantProfile instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'displayName': instance.displayName,
      'profileImage': instance.profileImage,
      'identifier': instance.identifier,
    };

MessageListResponse _$MessageListResponseFromJson(Map<String, dynamic> json) =>
    MessageListResponse(
      content: (json['messages'] as List<dynamic>)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'],
      hasNext: json['hasNext'] as bool? ?? false,
    );

Map<String, dynamic> _$MessageListResponseToJson(
        MessageListResponse instance) =>
    <String, dynamic>{
      'messages': instance.content,
      'nextCursor': instance.nextCursor,
      'hasNext': instance.hasNext,
    };
