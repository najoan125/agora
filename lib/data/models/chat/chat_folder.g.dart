// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_folder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatFolder _$ChatFolderFromJson(Map<String, dynamic> json) => ChatFolder(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String?,
      chatCount: (json['chatCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ChatFolderToJson(ChatFolder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
      'chatCount': instance.chatCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

CreateChatFolderRequest _$CreateChatFolderRequestFromJson(
        Map<String, dynamic> json) =>
    CreateChatFolderRequest(
      name: json['name'] as String,
      color: json['color'] as String?,
    );

Map<String, dynamic> _$CreateChatFolderRequestToJson(
        CreateChatFolderRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'color': instance.color,
    };

UpdateChatFolderRequest _$UpdateChatFolderRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateChatFolderRequest(
      name: json['name'] as String?,
      color: json['color'] as String?,
    );

Map<String, dynamic> _$UpdateChatFolderRequestToJson(
        UpdateChatFolderRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'color': instance.color,
    };
