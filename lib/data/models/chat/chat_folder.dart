import 'package:json_annotation/json_annotation.dart';

part 'chat_folder.g.dart';

/// 채팅 폴더 모델
@JsonSerializable()
class ChatFolder {
  final String id;
  final String name;
  final String? color;
  final int chatCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ChatFolder({
    required this.id,
    required this.name,
    this.color,
    this.chatCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory ChatFolder.fromJson(Map<String, dynamic> json) =>
      _$ChatFolderFromJson(json);
  Map<String, dynamic> toJson() => _$ChatFolderToJson(this);

  ChatFolder copyWith({
    String? id,
    String? name,
    String? color,
    int? chatCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      chatCount: chatCount ?? this.chatCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 채팅 폴더 생성 요청
@JsonSerializable()
class CreateChatFolderRequest {
  final String name;
  final String? color;

  const CreateChatFolderRequest({
    required this.name,
    this.color,
  });

  factory CreateChatFolderRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateChatFolderRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateChatFolderRequestToJson(this);
}

/// 채팅 폴더 수정 요청
@JsonSerializable()
class UpdateChatFolderRequest {
  final String? name;
  final String? color;

  const UpdateChatFolderRequest({
    this.name,
    this.color,
  });

  factory UpdateChatFolderRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateChatFolderRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateChatFolderRequestToJson(this);
}
