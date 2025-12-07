import 'package:json_annotation/json_annotation.dart';

part 'friend_request.g.dart';

/// 친구 요청 상태
enum FriendRequestStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('REJECTED')
  rejected,
}

/// 친구 요청 모델
@JsonSerializable()
class FriendRequest {
  @JsonKey(name: 'requestId')
  final dynamic id;
  @JsonKey(name: 'fromAgoraId')
  final String senderAgoraId;
  @JsonKey(name: 'fromDisplayName')
  final String senderDisplayName;
  @JsonKey(name: 'fromProfileImage')
  final String? senderProfileImageUrl;
  final int? toUserId;
  final FriendRequestStatus status;
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime? respondedAt;

  const FriendRequest({
    required this.id,
    required this.senderAgoraId,
    required this.senderDisplayName,
    this.senderProfileImageUrl,
    this.toUserId,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) =>
      _$FriendRequestFromJson(json);
  Map<String, dynamic> toJson() => _$FriendRequestToJson(this);

  bool get isPending => status == FriendRequestStatus.pending;
}

/// 친구 요청 목록 응답
@JsonSerializable()
class FriendRequestListResponse {
  final List<FriendRequest> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool last;

  const FriendRequestListResponse({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory FriendRequestListResponse.fromJson(Map<String, dynamic> json) =>
      _$FriendRequestListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FriendRequestListResponseToJson(this);
}
