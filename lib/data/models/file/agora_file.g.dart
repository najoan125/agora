// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agora_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgoraFile _$AgoraFileFromJson(Map<String, dynamic> json) => AgoraFile(
      id: _idFromJson(json['fileId']),
      originalName: json['originalName'] as String,
      storedName: json['fileName'] as String,
      mimeType: json['mimeType'] as String,
      size: (json['fileSize'] as num).toInt(),
      type: $enumDecode(_$FileTypeEnumMap, json['fileType']),
      thumbnailUrl: _nullableUrlFromJson(json['thumbnailUrl']),
      downloadUrl: _urlFromJson(json['fileUrl']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AgoraFileToJson(AgoraFile instance) => <String, dynamic>{
      'fileId': _idToJson(instance.id),
      'originalName': instance.originalName,
      'fileName': instance.storedName,
      'mimeType': instance.mimeType,
      'fileSize': instance.size,
      'fileType': _$FileTypeEnumMap[instance.type]!,
      'thumbnailUrl': instance.thumbnailUrl,
      'fileUrl': instance.downloadUrl,
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
