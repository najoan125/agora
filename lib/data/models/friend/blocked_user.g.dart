// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocked_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockedUser _$BlockedUserFromJson(Map<String, dynamic> json) => BlockedUser(
      id: json['blockedUserId'],
      agoraId: json['agoraId'] as String,
      displayName: json['displayName'] as String,
      profileImageUrl: json['profileImage'] as String?,
      blockedAt: DateTime.parse(json['blockedAt'] as String),
    );

Map<String, dynamic> _$BlockedUserToJson(BlockedUser instance) =>
    <String, dynamic>{
      'blockedUserId': instance.id,
      'agoraId': instance.agoraId,
      'displayName': instance.displayName,
      'profileImage': instance.profileImageUrl,
      'blockedAt': instance.blockedAt.toIso8601String(),
    };

BlockedUserListResponse _$BlockedUserListResponseFromJson(
        Map<String, dynamic> json) =>
    BlockedUserListResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => BlockedUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      pageNumber: (json['pageNumber'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      last: json['last'] as bool,
    );

Map<String, dynamic> _$BlockedUserListResponseToJson(
        BlockedUserListResponse instance) =>
    <String, dynamic>{
      'content': instance.content,
      'pageNumber': instance.pageNumber,
      'pageSize': instance.pageSize,
      'totalElements': instance.totalElements,
      'totalPages': instance.totalPages,
      'last': instance.last,
    };
