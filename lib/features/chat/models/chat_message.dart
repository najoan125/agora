import 'dart:typed_data';

class ChatMessage {
  final String id; // Message ID
  final String text;
  final bool isMe;
  final DateTime time;
  final String? sender; // 그룹/팀 채팅용
  final String? avatar; // 팀 채팅용
  final String? userImage; // 그룹/팀 채팅용
  final Uint8List? imageBytes; // Single image
  final List<Uint8List>? imageBytesList; // Multiple images
  final String? imageUrl;
  final String? fileName; // Single file
  final int? fileSize; // Single file
  final String? filePath; // Single file
  final Uint8List? fileBytes; // Single file
  final List<Map<String, dynamic>>? filesList; // Multiple files
  final String? audioPath;
  final Duration? audioDuration;
  final List<String> reactions;
  
  // Reply fields
  final String? replyToId;
  final String? replyToSender;
  final String? replyToContent;

  ChatMessage({
    this.id = '', // Default empty for backward compatibility
    required this.text,
    required this.isMe,
    required this.time,
    this.sender,
    this.avatar,
    this.userImage,
    this.imageBytes,
    this.imageBytesList,
    this.imageUrl,
    this.fileName,
    this.fileSize,
    this.filePath,
    this.fileBytes,
    this.filesList,
    this.audioPath,
    this.audioDuration,
    this.reactions = const [],
    this.replyToId,
    this.replyToSender,
    this.replyToContent,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isMe,
    DateTime? time,
    String? sender,
    String? avatar,
    String? userImage,
    Uint8List? imageBytes,
    List<Uint8List>? imageBytesList,
    String? imageUrl,
    String? fileName,
    int? fileSize,
    String? filePath,
    Uint8List? fileBytes,
    List<Map<String, dynamic>>? filesList,
    String? audioPath,
    Duration? audioDuration,
    List<String>? reactions,
    String? replyToId,
    String? replyToSender,
    String? replyToContent,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      time: time ?? this.time,
      sender: sender ?? this.sender,
      avatar: avatar ?? this.avatar,
      userImage: userImage ?? this.userImage,
      imageBytes: imageBytes ?? this.imageBytes,
      imageBytesList: imageBytesList ?? this.imageBytesList,
      imageUrl: imageUrl ?? this.imageUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      filePath: filePath ?? this.filePath,
      fileBytes: fileBytes ?? this.fileBytes,
      filesList: filesList ?? this.filesList,
      audioPath: audioPath ?? this.audioPath,
      audioDuration: audioDuration ?? this.audioDuration,
      reactions: reactions ?? this.reactions,
      replyToId: replyToId ?? this.replyToId,
      replyToSender: replyToSender ?? this.replyToSender,
      replyToContent: replyToContent ?? this.replyToContent,
    );
  }
}
