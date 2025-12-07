import 'package:json_annotation/json_annotation.dart';

part 'blocked_user.g.dart';

/// 차단된 사용자 모델
@JsonSerializable()
class BlockedUser {
  @JsonKey(name: 'blockedUserId')
  final dynamic id;
  final String agoraId;
  final String displayName;
  @JsonKey(name: 'profileImage')
  final String? profileImageUrl;
  final DateTime blockedAt;

  const BlockedUser({
    required this.id,
    required this.agoraId,
    required this.displayName,
    this.profileImageUrl,
    required this.blockedAt,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) =>
      _$BlockedUserFromJson(json);
  Map<String, dynamic> toJson() => _$BlockedUserToJson(this);
}

/// 차단 사용자 목록 응답
@JsonSerializable()
class BlockedUserListResponse {
  final List<BlockedUser> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool last;

  const BlockedUserListResponse({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory BlockedUserListResponse.fromJson(Map<String, dynamic> json) =>
      _$BlockedUserListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BlockedUserListResponseToJson(this);
}
