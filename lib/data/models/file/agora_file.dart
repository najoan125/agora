import 'package:json_annotation/json_annotation.dart';
import '../../../core/constants/api_endpoints.dart';

part 'agora_file.g.dart';

/// 파일 타입
enum FileType {
  @JsonValue('IMAGE')
  image,
  @JsonValue('VIDEO')
  video,
  @JsonValue('AUDIO')
  audio,
  @JsonValue('DOCUMENT')
  document,
  @JsonValue('OTHER')
  other,
}

/// 파일 모델
@JsonSerializable()
class AgoraFile {
  @JsonKey(name: 'fileId', fromJson: _idFromJson, toJson: _idToJson)
  final String id;
  final String originalName;
  @JsonKey(name: 'fileName')
  final String storedName;
  final String mimeType;
  @JsonKey(name: 'fileSize')
  final int size;
  @JsonKey(name: 'fileType')
  final FileType type;
  @JsonKey(fromJson: _nullableUrlFromJson)
  final String? thumbnailUrl;
  @JsonKey(name: 'fileUrl', fromJson: _urlFromJson)
  final String downloadUrl;
  final DateTime createdAt;

  const AgoraFile({
    required this.id,
    required this.originalName,
    required this.storedName,
    required this.mimeType,
    required this.size,
    required this.type,
    this.thumbnailUrl,
    required this.downloadUrl,
    required this.createdAt,
  });

  factory AgoraFile.fromJson(Map<String, dynamic> json) =>
      _$AgoraFileFromJson(json);
  Map<String, dynamic> toJson() => _$AgoraFileToJson(this);

  /// 파일 크기를 사람이 읽기 좋은 형식으로 변환
  String get formattedSize {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// 파일 확장자 가져오기
  String get extension {
    final parts = originalName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// 이미지 파일 여부
  bool get isImage => type == FileType.image;

  /// 비디오 파일 여부
  bool get isVideo => type == FileType.video;

  /// 오디오 파일 여부
  bool get isAudio => type == FileType.audio;

  /// 문서 파일 여부
  bool get isDocument => type == FileType.document;
}

/// 파일 업로드 응답
@JsonSerializable()
class FileUploadResponse {
  final AgoraFile file;
  final String uploadId;

  const FileUploadResponse({
    required this.file,
    required this.uploadId,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$FileUploadResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FileUploadResponseToJson(this);
}

// Helper functions for id conversion
String _idFromJson(dynamic value) => value.toString();
dynamic _idToJson(String value) => value;

// Helper function for URL - adds base URL if needed
String _urlFromJson(dynamic value) {
  if (value == null) return '';
  final url = value.toString();
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }
  // 상대 경로인 경우 base URL 추가
  return '${ApiEndpoints.baseUrl}$url';
}

// Helper function for nullable URL
String? _nullableUrlFromJson(dynamic value) {
  if (value == null) return null;
  final url = value.toString();
  if (url.isEmpty) return null;
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }
  return '${ApiEndpoints.baseUrl}$url';
}
