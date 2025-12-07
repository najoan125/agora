import 'package:json_annotation/json_annotation.dart';
import 'chat.dart';

part 'group_chat.g.dart';

/// 그룹 채팅 생성 요청
@JsonSerializable()
class CreateGroupChatRequest {
  final String name;
  final List<String> memberAgoraIds;
  final String? profileImageUrl;

  const CreateGroupChatRequest({
    required this.name,
    required this.memberAgoraIds,
    this.profileImageUrl,
  });

  factory CreateGroupChatRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateGroupChatRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateGroupChatRequestToJson(this);
}

/// 그룹 채팅 수정 요청
@JsonSerializable()
class UpdateGroupChatRequest {
  final String? name;
  final String? profileImageUrl;

  const UpdateGroupChatRequest({
    this.name,
    this.profileImageUrl,
  });

  factory UpdateGroupChatRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateGroupChatRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateGroupChatRequestToJson(this);
}

/// 그룹 멤버 초대 요청
@JsonSerializable()
class InviteGroupMembersRequest {
  final List<String> agoraIds;

  const InviteGroupMembersRequest({
    required this.agoraIds,
  });

  factory InviteGroupMembersRequest.fromJson(Map<String, dynamic> json) =>
      _$InviteGroupMembersRequestFromJson(json);
  Map<String, dynamic> toJson() => _$InviteGroupMembersRequestToJson(this);
}

/// 그룹 채팅 상세 정보
@JsonSerializable()
class GroupChatDetail {
  final Chat chat;
  final List<GroupMember> members;
  final int totalMembers;

  const GroupChatDetail({
    required this.chat,
    required this.members,
    required this.totalMembers,
  });

  factory GroupChatDetail.fromJson(Map<String, dynamic> json) =>
      _$GroupChatDetailFromJson(json);
  Map<String, dynamic> toJson() => _$GroupChatDetailToJson(this);
}

/// 그룹 멤버
@JsonSerializable()
class GroupMember {
  final String id;
  final String agoraId;
  final String displayName;
  final String? profileImageUrl;
  final ChatParticipantRole role;
  final DateTime joinedAt;
  final bool isOnline;

  const GroupMember({
    required this.id,
    required this.agoraId,
    required this.displayName,
    this.profileImageUrl,
    required this.role,
    required this.joinedAt,
    this.isOnline = false,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) =>
      _$GroupMemberFromJson(json);
  Map<String, dynamic> toJson() => _$GroupMemberToJson(this);

  /// 관리자 여부
  bool get isAdmin => role == ChatParticipantRole.admin;

  /// ChatParticipant로 변환
  ChatParticipant toChatParticipant() {
    return ChatParticipant(
      id: id,
      agoraId: agoraId,
      displayName: displayName,
      profileImageUrl: profileImageUrl,
      role: role,
      joinedAt: joinedAt,
    );
  }
}
