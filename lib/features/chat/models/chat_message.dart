import 'dart:typed_data';

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;
  final String? sender; // 그룹/팀 채팅용
  final String? avatar; // 팀 채팅용
  final String? userImage; // 그룹/팀 채팅용
  final Uint8List? imageBytes; // Single image (backward compatibility)
  final List<Uint8List>? imageBytesList; // Multiple images
  final String? imageUrl;
  final String? fileName; // Single file (backward compatibility)
  final int? fileSize; // Single file (backward compatibility)
  final String? filePath; // Single file (backward compatibility)
  final Uint8List? fileBytes; // Single file (backward compatibility)
  final List<Map<String, dynamic>>? filesList; // Multiple files
  final String? audioPath;
  final Duration? audioDuration;
  final List<String> reactions;

  ChatMessage({
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
  });

  ChatMessage copyWith({
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
  }) {
    return ChatMessage(
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
    );
  }
}
