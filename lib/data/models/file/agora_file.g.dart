// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agora_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgoraFile _$AgoraFileFromJson(Map<String, dynamic> json) => AgoraFile(
      id: json['id'] as String,
      originalName: json['originalName'] as String,
      storedName: json['storedName'] as String,
      mimeType: json['mimeType'] as String,
      size: (json['size'] as num).toInt(),
      type: $enumDecode(_$FileTypeEnumMap, json['type']),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      downloadUrl: json['downloadUrl'] as String,
      uploaderId: json['uploaderId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AgoraFileToJson(AgoraFile instance) => <String, dynamic>{
      'id': instance.id,
      'originalName': instance.originalName,
      'storedName': instance.storedName,
      'mimeType': instance.mimeType,
      'size': instance.size,
      'type': _$FileTypeEnumMap[instance.type]!,
      'thumbnailUrl': instance.thumbnailUrl,
      'downloadUrl': instance.downloadUrl,
      'uploaderId': instance.uploaderId,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$FileTypeEnumMap = {
  FileType.image: 'IMAGE',
  FileType.video: 'VIDEO',
  FileType.audio: 'AUDIO',
  FileType.document: 'DOCUMENT',
  FileType.other: 'OTHER',
};

FileUploadResponse _$FileUploadResponseFromJson(Map<String, dynamic> json) =>
    FileUploadResponse(
      file: AgoraFile.fromJson(json['file'] as Map<String, dynamic>),
      uploadId: json['uploadId'] as String,
    );

Map<String, dynamic> _$FileUploadResponseToJson(FileUploadResponse instance) =>
    <String, dynamic>{
      'file': instance.file,
      'uploadId': instance.uploadId,
    };
