// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Team _$TeamFromJson(Map<String, dynamic> json) => Team(
      id: json['teamId'],
      name: json['name'] as String,
      description: json['description'] as String?,
      profileImageUrl: _imageUrlFromJson(json['profileImage']),
      creatorId: json['creatorEmail'] as String?,
      isMain: json['isMain'] as bool? ?? false,
      memberCount: (json['memberCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TeamToJson(Team instance) => <String, dynamic>{
      'teamId': instance.id,
      'name': instance.name,
      'description': instance.description,
      'profileImage': instance.profileImageUrl,
      'creatorEmail': instance.creatorId,
      'isMain': instance.isMain,
      'memberCount': instance.memberCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

TeamMember _$TeamMemberFromJson(Map<String, dynamic> json) => TeamMember(
      memberId: (json['memberId'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      agoraId: json['agoraId'] as String,
      displayName: json['displayName'] as String?,
      profileImage: _imageUrlFromJson(json['profileImage']),
      role: $enumDecode(_$TeamRoleEnumMap, json['roleName']),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$TeamMemberToJson(TeamMember instance) =>
    <String, dynamic>{
      'memberId': instance.memberId,
      'userId': instance.userId,
      'agoraId': instance.agoraId,
      'displayName': instance.displayName,
      'profileImage': instance.profileImage,
      'roleName': _$TeamRoleEnumMap[instance.role]!,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };

const _$TeamRoleEnumMap = {
  TeamRole.admin: 'admin',
  TeamRole.member: 'member',
};

TeamListResponse _$TeamListResponseFromJson(Map<String, dynamic> json) =>
    TeamListResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => Team.fromJson(e as Map<String, dynamic>))
          .toList(),
      pageNumber: (json['pageNumber'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      last: json['last'] as bool,
    );

Map<String, dynamic> _$TeamListResponseToJson(TeamListResponse instance) =>
    <String, dynamic>{
      'content': instance.content,
      'pageNumber': instance.pageNumber,
      'pageSize': instance.pageSize,
      'totalElements': instance.totalElements,
      'totalPages': instance.totalPages,
      'last': instance.last,
    };

TeamProfile _$TeamProfileFromJson(Map<String, dynamic> json) => TeamProfile(
      userId: (json['userId'] as num).toInt(),
      userEmail: json['userEmail'] as String?,
      displayName: json['displayName'] as String,
      profileImageUrl: _imageUrlFromJson(json['profileImage']),
      bio: json['bio'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TeamProfileToJson(TeamProfile instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userEmail': instance.userEmail,
      'displayName': instance.displayName,
      'profileImage': instance.profileImageUrl,
      'bio': instance.bio,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

Notice _$NoticeFromJson(Map<String, dynamic> json) => Notice(
      id: _noticeIdFromJson(json['noticeId']),
      teamId: _noticeTeamIdFromJson(json['teamId']),
      title: json['title'] as String,
      content: json['content'] as String,
      authorId: json['authorEmail'] as String,
      isPinned: json['isPinned'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$NoticeToJson(Notice instance) => <String, dynamic>{
      'noticeId': instance.id,
      'teamId': instance.teamId,
      'title': instance.title,
      'content': instance.content,
      'authorEmail': instance.authorId,
      'isPinned': instance.isPinned,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

Todo _$TodoFromJson(Map<String, dynamic> json) => Todo(
      id: json['id'] as String,
      teamId: json['teamId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: $enumDecode(_$TodoStatusEnumMap, json['status']),
      priority: $enumDecode(_$TodoPriorityEnumMap, json['priority']),
      assignedToId: json['assignedToId'] as String?,
      assignedToName: json['assignedToName'] as String?,
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TodoToJson(Todo instance) => <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'title': instance.title,
      'description': instance.description,
      'status': _$TodoStatusEnumMap[instance.status]!,
      'priority': _$TodoPriorityEnumMap[instance.priority]!,
      'assignedToId': instance.assignedToId,
      'assignedToName': instance.assignedToName,
      'dueDate': instance.dueDate?.toIso8601String(),
      'creatorId': instance.creatorId,
      'creatorName': instance.creatorName,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$TodoStatusEnumMap = {
  TodoStatus.todo: 'TODO',
  TodoStatus.inProgress: 'IN_PROGRESS',
  TodoStatus.done: 'DONE',
};

const _$TodoPriorityEnumMap = {
  TodoPriority.low: 'LOW',
  TodoPriority.medium: 'MEDIUM',
  TodoPriority.high: 'HIGH',
};

Event _$EventFromJson(Map<String, dynamic> json) => Event(
      id: json['id'] as String,
      teamId: json['teamId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      isAllDay: json['isAllDay'] as bool? ?? false,
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'title': instance.title,
      'description': instance.description,
      'location': instance.location,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'isAllDay': instance.isAllDay,
      'creatorId': instance.creatorId,
      'creatorName': instance.creatorName,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

TeamInvitation _$TeamInvitationFromJson(Map<String, dynamic> json) =>
    TeamInvitation(
      invitationId: (json['invitationId'] as num).toInt(),
      teamId: (json['teamId'] as num).toInt(),
      teamName: json['teamName'] as String,
      teamProfileImage: _imageUrlFromJson(json['teamProfileImage']),
      fromAgoraId: json['fromAgoraId'] as String,
      fromDisplayName: json['fromDisplayName'] as String?,
      fromProfileImage: _imageUrlFromJson(json['fromProfileImage']),
      toAgoraId: json['toAgoraId'] as String,
      toDisplayName: json['toDisplayName'] as String?,
      toProfileImage: _imageUrlFromJson(json['toProfileImage']),
      status: $enumDecode(_$InvitationStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TeamInvitationToJson(TeamInvitation instance) =>
    <String, dynamic>{
      'invitationId': instance.invitationId,
      'teamId': instance.teamId,
      'teamName': instance.teamName,
      'teamProfileImage': instance.teamProfileImage,
      'fromAgoraId': instance.fromAgoraId,
      'fromDisplayName': instance.fromDisplayName,
      'fromProfileImage': instance.fromProfileImage,
      'toAgoraId': instance.toAgoraId,
      'toDisplayName': instance.toDisplayName,
      'toProfileImage': instance.toProfileImage,
      'status': _$InvitationStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$InvitationStatusEnumMap = {
  InvitationStatus.pending: 'PENDING',
  InvitationStatus.accepted: 'ACCEPTED',
  InvitationStatus.rejected: 'REJECTED',
};
