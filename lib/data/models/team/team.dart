import 'package:json_annotation/json_annotation.dart';
import '../../../core/constants/api_endpoints.dart';

part 'team.g.dart';

// Helper function for nullable URL - adds base URL if needed
String? _imageUrlFromJson(dynamic value) {
  if (value == null) return null;
  final url = value.toString();
  if (url.isEmpty) return null;
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }
  return '${ApiEndpoints.baseUrl}$url';
}

/// 팀 모델
@JsonSerializable()
class Team {
  @JsonKey(name: 'teamId')
  final dynamic id;
  final String name;
  final String? description;
  @JsonKey(name: 'profileImage', fromJson: _imageUrlFromJson)
  final String? profileImageUrl;
  @JsonKey(name: 'creatorEmail')
  final String? creatorId;
  final bool isMain;
  final int memberCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Team({
    required this.id,
    required this.name,
    this.description,
    this.profileImageUrl,
    this.creatorId,
    this.isMain = false,
    required this.memberCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
  Map<String, dynamic> toJson() => _$TeamToJson(this);

  Team copyWith({
    String? id,
    String? name,
    String? description,
    String? profileImageUrl,
    String? creatorId,
    bool? isMain,
    int? memberCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      creatorId: creatorId ?? this.creatorId,
      isMain: isMain ?? this.isMain,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 팀 멤버 모델
@JsonSerializable()
class TeamMember {
  final int memberId;
  final int userId;
  final String agoraId;
  final String? displayName;
  @JsonKey(fromJson: _imageUrlFromJson)
  final String? profileImage;
  final TeamRole role;
  final DateTime joinedAt;

  const TeamMember({
    required this.memberId,
    required this.userId,
    required this.agoraId,
    this.displayName,
    this.profileImage,
    required this.role,
    required this.joinedAt,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) =>
      _$TeamMemberFromJson(json);
  Map<String, dynamic> toJson() => _$TeamMemberToJson(this);

  /// 표시할 이름 (displayName이 있으면 사용, 없으면 agoraId)
  String get effectiveDisplayName => displayName ?? agoraId;

  bool get isAdmin => role == TeamRole.admin;
}

/// 팀 역할
enum TeamRole {
  @JsonValue('ADMIN')
  admin,
  @JsonValue('MEMBER')
  member,
}

/// 팀 목록 응답
@JsonSerializable()
class TeamListResponse {
  final List<Team> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool last;

  const TeamListResponse({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory TeamListResponse.fromJson(Map<String, dynamic> json) =>
      _$TeamListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TeamListResponseToJson(this);
}

/// 팀 프로필 모델 (사용자당 하나의 팀 프로필)
@JsonSerializable()
class TeamProfile {
  final int userId;
  final String? userEmail;
  final String displayName;
  @JsonKey(name: 'profileImage', fromJson: _imageUrlFromJson)
  final String? profileImageUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TeamProfile({
    required this.userId,
    this.userEmail,
    required this.displayName,
    this.profileImageUrl,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TeamProfile.fromJson(Map<String, dynamic> json) =>
      _$TeamProfileFromJson(json);
  Map<String, dynamic> toJson() => _$TeamProfileToJson(this);
}

/// 공지 모델
@JsonSerializable()
class Notice {
  final String id;
  final String teamId;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Notice({
    required this.id,
    required this.teamId,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Notice.fromJson(Map<String, dynamic> json) => _$NoticeFromJson(json);
  Map<String, dynamic> toJson() => _$NoticeToJson(this);
}

/// 할일 상태
enum TodoStatus {
  @JsonValue('TODO')
  todo,
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('DONE')
  done,
}

/// 할일 우선순위
enum TodoPriority {
  @JsonValue('LOW')
  low,
  @JsonValue('MEDIUM')
  medium,
  @JsonValue('HIGH')
  high,
}

/// 할일 모델
@JsonSerializable()
class Todo {
  final String id;
  final String teamId;
  final String title;
  final String? description;
  final TodoStatus status;
  final TodoPriority priority;
  final String? assignedToId;
  final String? assignedToName;
  final DateTime? dueDate;
  final String creatorId;
  final String creatorName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Todo({
    required this.id,
    required this.teamId,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.assignedToId,
    this.assignedToName,
    this.dueDate,
    required this.creatorId,
    required this.creatorName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
  Map<String, dynamic> toJson() => _$TodoToJson(this);

  bool get isCompleted => status == TodoStatus.done;
  bool get isOverdue => dueDate != null && dueDate!.isBefore(DateTime.now()) && !isCompleted;
}

/// 이벤트 모델
@JsonSerializable()
class Event {
  final String id;
  final String teamId;
  final String title;
  final String? description;
  final String? location;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final String creatorId;
  final String creatorName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    required this.id,
    required this.teamId,
    required this.title,
    this.description,
    this.location,
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    required this.creatorId,
    required this.creatorName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);

  Duration get duration => endTime.difference(startTime);
  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }
}

/// 초대 상태
enum InvitationStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('REJECTED')
  rejected,
}

/// 팀 초대 모델
@JsonSerializable()
class TeamInvitation {
  final int invitationId;
  final int teamId;
  final String teamName;
  @JsonKey(fromJson: _imageUrlFromJson)
  final String? teamProfileImage;
  final String fromAgoraId;
  final String? fromDisplayName;
  @JsonKey(fromJson: _imageUrlFromJson)
  final String? fromProfileImage;
  final String toAgoraId;
  final String? toDisplayName;
  @JsonKey(fromJson: _imageUrlFromJson)
  final String? toProfileImage;
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TeamInvitation({
    required this.invitationId,
    required this.teamId,
    required this.teamName,
    this.teamProfileImage,
    required this.fromAgoraId,
    this.fromDisplayName,
    this.fromProfileImage,
    required this.toAgoraId,
    this.toDisplayName,
    this.toProfileImage,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TeamInvitation.fromJson(Map<String, dynamic> json) =>
      _$TeamInvitationFromJson(json);
  Map<String, dynamic> toJson() => _$TeamInvitationToJson(this);

  bool get isPending => status == InvitationStatus.pending;
  bool get isAccepted => status == InvitationStatus.accepted;
  bool get isRejected => status == InvitationStatus.rejected;

  /// 보낸 사람 표시 이름 (displayName이 있으면 사용, 없으면 agoraId)
  String get fromEffectiveDisplayName => fromDisplayName ?? fromAgoraId;

  /// 받는 사람 표시 이름 (displayName이 있으면 사용, 없으면 agoraId)
  String get toEffectiveDisplayName => toDisplayName ?? toAgoraId;
}
