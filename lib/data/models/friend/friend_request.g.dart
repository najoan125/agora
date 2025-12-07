// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendRequest _$FriendRequestFromJson(Map<String, dynamic> json) =>
    FriendRequest(
      id: json['requestId'],
      senderAgoraId: json['fromAgoraId'] as String,
      senderDisplayName: json['fromDisplayName'] as String,
      senderProfileImageUrl: json['fromProfileImage'] as String?,
      toUserId: (json['toUserId'] as num?)?.toInt(),
      status: $enumDecode(_$FriendRequestStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      respondedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FriendRequestToJson(FriendRequest instance) =>
    <String, dynamic>{
      'requestId': instance.id,
      'fromAgoraId': instance.senderAgoraId,
      'fromDisplayName': instance.senderDisplayName,
      'fromProfileImage': instance.senderProfileImageUrl,
      'toUserId': instance.toUserId,
      'status': _$FriendRequestStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.respondedAt?.toIso8601String(),
    };

const _$FriendRequestStatusEnumMap = {
  FriendRequestStatus.pending: 'PENDING',
  FriendRequestStatus.accepted: 'ACCEPTED',
  FriendRequestStatus.rejected: 'REJECTED',
};

FriendRequestListResponse _$FriendRequestListResponseFromJson(
        Map<String, dynamic> json) =>
    FriendRequestListResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => FriendRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
      pageNumber: (json['pageNumber'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      last: json['last'] as bool,
    );

Map<String, dynamic> _$FriendRequestListResponseToJson(
        FriendRequestListResponse instance) =>
    <String, dynamic>{
      'content': instance.content,
      'pageNumber': instance.pageNumber,
      'pageSize': instance.pageSize,
      'totalElements': instance.totalElements,
      'totalPages': instance.totalPages,
      'last': instance.last,
    };
