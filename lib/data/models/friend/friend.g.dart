// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Friend _$FriendFromJson(Map<String, dynamic> json) => Friend(
      id: json['friendId'],
      agoraId: json['agoraId'] as String,
      displayName: json['displayName'] as String,
      profileImageUrl: json['profileImage'] as String?,
      statusMessage: json['statusMessage'] as String?,
      phone: json['phone'] as String?,
      birthday: json['birthday'] == null
          ? null
          : DateTime.parse(json['birthday'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? false,
      lastOnlineAt: json['lastOnlineAt'] == null
          ? null
          : DateTime.parse(json['lastOnlineAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$FriendToJson(Friend instance) => <String, dynamic>{
      'friendId': instance.id,
      'agoraId': instance.agoraId,
      'displayName': instance.displayName,
      'profileImage': instance.profileImageUrl,
      'statusMessage': instance.statusMessage,
      'phone': instance.phone,
      'birthday': instance.birthday?.toIso8601String(),
      'isFavorite': instance.isFavorite,
      'isOnline': instance.isOnline,
      'lastOnlineAt': instance.lastOnlineAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

FriendListResponse _$FriendListResponseFromJson(Map<String, dynamic> json) =>
    FriendListResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => Friend.fromJson(e as Map<String, dynamic>))
          .toList(),
      pageNumber: (json['pageNumber'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      last: json['last'] as bool,
    );

Map<String, dynamic> _$FriendListResponseToJson(FriendListResponse instance) =>
    <String, dynamic>{
      'content': instance.content,
      'pageNumber': instance.pageNumber,
      'pageSize': instance.pageSize,
      'totalElements': instance.totalElements,
      'totalPages': instance.totalPages,
      'last': instance.last,
    };
