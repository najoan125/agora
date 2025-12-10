// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Team _$TeamFromJson(Map<String, dynamic> json) => Team(
      id: json['teamId'],
      name: json['name'] as String,
      description: json['description'] as String?,
      profileImageUrl: json['profileImage'] as String?,
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
      id: json['id'] as String,
      agoraId: json['agoraId'] as String,
      displayName: json['displayName'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      teamDisplayName: json['teamDisplayName'] as String?,
      teamProfileImageUrl: json['teamProfileImageUrl'] as String?,
      role: $enumDecode(_$TeamRoleEnumMap, json['role']),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$TeamMemberToJson(TeamMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'agoraId': instance.agoraId,
      'displayName': instance.displayName,
      'profileImageUrl': instance.profileImageUrl,
      'teamDisplayName': instance.teamDisplayName,
      'teamProfileImageUrl': instance.teamProfileImageUrl,
      'role': _$TeamRoleEnumMap[instance.role]!,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };

const _$TeamRoleEnumMap = {
  TeamRole.admin: 'ADMIN',
  TeamRole.member: 'MEMBER',
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
      profileImageUrl: json['profileImage'] as String?,
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
      id: json['id'] as String,
      teamId: json['teamId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      isPinned: json['isPinned'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$NoticeToJson(Notice instance) => <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'title': instance.title,
      'content': instance.content,
      'authorId': instance.authorId,
      'authorName': instance.authorName,
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
