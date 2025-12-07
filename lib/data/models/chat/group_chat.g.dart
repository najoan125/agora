// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateGroupChatRequest _$CreateGroupChatRequestFromJson(
        Map<String, dynamic> json) =>
    CreateGroupChatRequest(
      name: json['name'] as String,
      memberAgoraIds: (json['memberAgoraIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      profileImageUrl: json['profileImageUrl'] as String?,
    );

Map<String, dynamic> _$CreateGroupChatRequestToJson(
        CreateGroupChatRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'memberAgoraIds': instance.memberAgoraIds,
      'profileImageUrl': instance.profileImageUrl,
    };

UpdateGroupChatRequest _$UpdateGroupChatRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateGroupChatRequest(
      name: json['name'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
    );

Map<String, dynamic> _$UpdateGroupChatRequestToJson(
        UpdateGroupChatRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'profileImageUrl': instance.profileImageUrl,
    };

InviteGroupMembersRequest _$InviteGroupMembersRequestFromJson(
        Map<String, dynamic> json) =>
    InviteGroupMembersRequest(
      agoraIds:
          (json['agoraIds'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$InviteGroupMembersRequestToJson(
        InviteGroupMembersRequest instance) =>
    <String, dynamic>{
      'agoraIds': instance.agoraIds,
    };

GroupChatDetail _$GroupChatDetailFromJson(Map<String, dynamic> json) =>
    GroupChatDetail(
      chat: Chat.fromJson(json['chat'] as Map<String, dynamic>),
      members: (json['members'] as List<dynamic>)
          .map((e) => GroupMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalMembers: (json['totalMembers'] as num).toInt(),
    );

Map<String, dynamic> _$GroupChatDetailToJson(GroupChatDetail instance) =>
    <String, dynamic>{
      'chat': instance.chat,
      'members': instance.members,
      'totalMembers': instance.totalMembers,
    };

GroupMember _$GroupMemberFromJson(Map<String, dynamic> json) => GroupMember(
      id: json['id'] as String,
      agoraId: json['agoraId'] as String,
      displayName: json['displayName'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      role: $enumDecode(_$ChatParticipantRoleEnumMap, json['role']),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      isOnline: json['isOnline'] as bool? ?? false,
    );

Map<String, dynamic> _$GroupMemberToJson(GroupMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'agoraId': instance.agoraId,
      'displayName': instance.displayName,
      'profileImageUrl': instance.profileImageUrl,
      'role': _$ChatParticipantRoleEnumMap[instance.role]!,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'isOnline': instance.isOnline,
    };

const _$ChatParticipantRoleEnumMap = {
  ChatParticipantRole.admin: 'ADMIN',
  ChatParticipantRole.member: 'MEMBER',
};
