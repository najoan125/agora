# Flutter 파일 업로드 구현

## 개요

이미지, 동영상, 일반 파일 업로드

---

## 1. 파일 선택 서비스

### lib/services/file_picker_service.dart

```dart
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:agora_app/core/utils/logger.dart';

class FilePickerService {
  final _imagePicker = ImagePicker();

  /// 갤러리에서 이미지 선택
  Future<XFile?> pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        AppLogger.debug('Image picked: ${pickedFile.path}');
      }

      return pickedFile;
    } catch (e) {
      AppLogger.error('Failed to pick image from gallery', error: e);
      return null;
    }
  }

  /// 카메라로 사진 촬영
  Future<XFile?> pickImageFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        AppLogger.debug('Image captured: ${pickedFile.path}');
      }

      return pickedFile;
    } catch (e) {
      AppLogger.error('Failed to capture image', error: e);
      return null;
    }
  }

  /// 비디오 선택 (갤러리)
  Future<XFile?> pickVideoFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        AppLogger.debug('Video picked: ${pickedFile.path}');
      }

      return pickedFile;
    } catch (e) {
      AppLogger.error('Failed to pick video from gallery', error: e);
      return null;
    }
  }

  /// 비디오 촬영 (카메라)
  Future<XFile?> pickVideoFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.camera,
      );

      if (pickedFile != null) {
        AppLogger.debug('Video captured: ${pickedFile.path}');
      }

      return pickedFile;
    } catch (e) {
      AppLogger.error('Failed to capture video', error: e);
      return null;
    }
  }

  /// 일반 파일 선택
  Future<FilePickerResult?> pickFile({
    List<String> allowedExtensions = const [],
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        onFileLoading: (status) {
          AppLogger.debug('File loading: $status');
        },
      );

      if (result != null) {
        AppLogger.debug('File picked: ${result.files.single.path}');
      }

      return result;
    } catch (e) {
      AppLogger.error('Failed to pick file', error: e);
      return null;
    }
  }

  /// 여러 파일 선택
  Future<FilePickerResult?> pickMultipleFiles({
    List<String> allowedExtensions = const [],
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );

      if (result != null) {
        AppLogger.debug('${result.files.length} files picked');
      }

      return result;
    } catch (e) {
      AppLogger.error('Failed to pick multiple files', error: e);
      return null;
    }
  }
}

final filePickerServiceProvider = Provider((ref) => FilePickerService());
```

---

## 2. 파일 업로드 API

### lib/data/datasources/remote/file_api.dart

```dart
import 'package:dio/dio.dart';
import 'package:agora_app/data/datasources/remote/api_client.dart';
import 'package:agora_app/core/constants/api_endpoints.dart';

class FileApi {
  final ApiClient apiClient;

  FileApi(this.apiClient);

  /// 일반 파일 업로드 (최대 50MB)
  Future<Map<String, dynamic>> uploadFile({
    required String filePath,
    String? fileName,
    ProgressCallback? onSendProgress,
  }) async {
    return await apiClient.uploadFile(
      ApiEndpoints.fileUpload,
      filePath: filePath,
      fieldName: 'file',
      formFields: {
        'type': 'GENERAL',
      },
    );
  }

  /// 이미지 업로드 (썸네일 자동 생성)
  Future<Map<String, dynamic>> uploadImage({
    required String imagePath,
    ProgressCallback? onSendProgress,
  }) async {
    return await apiClient.uploadFile(
      ApiEndpoints.fileUploadImage,
      filePath: imagePath,
      fieldName: 'image',
      formFields: {
        'type': 'IMAGE',
      },
    );
  }

  /// 프로필 이미지 업로드
  Future<Map<String, dynamic>> uploadProfileImage({
    required String imagePath,
  }) async {
    return await apiClient.uploadFile(
      '/api/agora/profile/image',
      filePath: imagePath,
      fieldName: 'file',
    );
  }

  /// 채팅 파일 업로드
  Future<Map<String, dynamic>> uploadChatAttachment({
    required String filePath,
    required int chatId,
  }) async {
    return await apiClient.uploadFile(
      '/api/agora/chats/$chatId/attachments',
      filePath: filePath,
      fieldName: 'file',
    );
  }

  /// 팀 파일 업로드
  Future<Map<String, dynamic>> uploadTeamFile({
    required String filePath,
    required int teamId,
  }) async {
    return await apiClient.uploadFile(
      '/api/agora/teams/$teamId/files',
      filePath: filePath,
      fieldName: 'file',
    );
  }

  /// 파일 메타데이터 조회
  Future<Map<String, dynamic>> getFileMetadata(int fileId) async {
    return await apiClient.get('/api/agora/files/$fileId');
  }

  /// 파일 다운로드
  Future<void> downloadFile({
    required int fileId,
    required String savePath,
    ProgressCallback? onReceiveProgress,
  }) async {
    await apiClient.downloadFile(
      path: '/api/agora/files/$fileId/download',
      savePath: savePath,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// 파일 삭제
  Future<void> deleteFile(int fileId) async {
    await apiClient.delete('/api/agora/files/$fileId');
  }
}

final fileApiProvider = Provider((ref) => FileApi(ref.watch(apiClientProvider)));
```

---

## 3. 파일 업로드 Repository

### lib/data/repositories/file_repository.dart

```dart
import 'package:agora_app/data/datasources/remote/file_api.dart';
import 'package:agora_app/core/exception/app_exception.dart';

class FileRepository {
  final FileApi fileApi;

  FileRepository({required this.fileApi});

  /// 일반 파일 업로드
  Future<FileUploadResult> uploadFile({
    required String filePath,
    String? fileName,
    Function(int, int)? onProgress,
  }) async {
    try {
      final response = await fileApi.uploadFile(
        filePath: filePath,
        fileName: fileName,
      );

      return FileUploadResult.fromJson(response);
    } on AppException {
      rethrow;
    }
  }

  /// 이미지 업로드
  Future<FileUploadResult> uploadImage({
    required String imagePath,
    Function(int, int)? onProgress,
  }) async {
    try {
      final response = await fileApi.uploadImage(
        imagePath: imagePath,
      );

      return FileUploadResult.fromJson(response);
    } on AppException {
      rethrow;
    }
  }

  /// 프로필 이미지 업로드
  Future<FileUploadResult> uploadProfileImage({
    required String imagePath,
  }) async {
    try {
      final response = await fileApi.uploadProfileImage(imagePath: imagePath);
      return FileUploadResult.fromJson(response);
    } on AppException {
      rethrow;
    }
  }

  /// 채팅 첨부파일 업로드
  Future<FileUploadResult> uploadChatAttachment({
    required String filePath,
    required int chatId,
  }) async {
    try {
      final response = await fileApi.uploadChatAttachment(
        filePath: filePath,
        chatId: chatId,
      );
      return FileUploadResult.fromJson(response);
    } on AppException {
      rethrow;
    }
  }
}

class FileUploadResult {
  final int fileId;
  final String fileName;
  final String fileUrl;
  final String? thumbnailUrl;
  final int fileSize;
  final String mimeType;

  FileUploadResult({
    required this.fileId,
    required this.fileName,
    required this.fileUrl,
    this.thumbnailUrl,
    required this.fileSize,
    required this.mimeType,
  });

  factory FileUploadResult.fromJson(Map<String, dynamic> json) {
    return FileUploadResult(
      fileId: json['fileId'] as int,
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      fileSize: json['fileSize'] as int,
      mimeType: json['mimeType'] as String,
    );
  }
}

final fileRepositoryProvider = Provider((ref) => FileRepository(
  fileApi: ref.watch(fileApiProvider),
));
```

---

## 4. 파일 업로드 Provider (State)

### lib/presentation/providers/file_upload_provider.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_app/data/repositories/file_repository.dart';

enum UploadStatus {
  idle,
  uploading,
  success,
  error,
}

class FileUploadState {
  final UploadStatus status;
  final int? progress; // 0-100
  final String? fileUrl;
  final String? error;

  FileUploadState({
    this.status = UploadStatus.idle,
    this.progress = 0,
    this.fileUrl,
    this.error,
  });

  FileUploadState copyWith({
    UploadStatus? status,
    int? progress,
    String? fileUrl,
    String? error,
  }) {
    return FileUploadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      fileUrl: fileUrl ?? this.fileUrl,
      error: error ?? this.error,
    );
  }
}

class FileUploadNotifier extends StateNotifier<FileUploadState> {
  final FileRepository fileRepository;

  FileUploadNotifier(this.fileRepository) : super(FileUploadState());

  /// 파일 업로드
  Future<String?> uploadFile(String filePath) async {
    state = state.copyWith(
      status: UploadStatus.uploading,
      progress: 0,
      error: null,
    );

    try {
      final result = await fileRepository.uploadFile(
        filePath: filePath,
        onProgress: (sent, total) {
          final progress = (sent / total * 100).toInt();
          state = state.copyWith(progress: progress);
        },
      );

      state = state.copyWith(
        status: UploadStatus.success,
        progress: 100,
        fileUrl: result.fileUrl,
      );

      return result.fileUrl;
    } catch (e) {
      state = state.copyWith(
        status: UploadStatus.error,
        error: e.toString(),
      );
      return null;
    }
  }

  /// 이미지 업로드
  Future<String?> uploadImage(String imagePath) async {
    state = state.copyWith(
      status: UploadStatus.uploading,
      progress: 0,
      error: null,
    );

    try {
      final result = await fileRepository.uploadImage(
        imagePath: imagePath,
        onProgress: (sent, total) {
          final progress = (sent / total * 100).toInt();
          state = state.copyWith(progress: progress);
        },
      );

      state = state.copyWith(
        status: UploadStatus.success,
        progress: 100,
        fileUrl: result.fileUrl,
      );

      return result.fileUrl;
    } catch (e) {
      state = state.copyWith(
        status: UploadStatus.error,
        error: e.toString(),
      );
      return null;
    }
  }

  /// 프로필 이미지 업로드
  Future<String?> uploadProfileImage(String imagePath) async {
    state = state.copyWith(
      status: UploadStatus.uploading,
      progress: 0,
      error: null,
    );

    try {
      final result = await fileRepository.uploadProfileImage(
        imagePath: imagePath,
      );

      state = state.copyWith(
        status: UploadStatus.success,
        progress: 100,
        fileUrl: result.fileUrl,
      );

      return result.fileUrl;
    } catch (e) {
      state = state.copyWith(
        status: UploadStatus.error,
        error: e.toString(),
      );
      return null;
    }
  }

  /// 채팅 첨부파일 업로드
  Future<String?> uploadChatAttachment({
    required String filePath,
    required int chatId,
  }) async {
    state = state.copyWith(
      status: UploadStatus.uploading,
      progress: 0,
      error: null,
    );

    try {
      final result = await fileRepository.uploadChatAttachment(
        filePath: filePath,
        chatId: chatId,
      );

      state = state.copyWith(
        status: UploadStatus.success,
        progress: 100,
        fileUrl: result.fileUrl,
      );

      return result.fileUrl;
    } catch (e) {
      state = state.copyWith(
        status: UploadStatus.error,
        error: e.toString(),
      );
      return null;
    }
  }

  /// 상태 리셋
  void reset() {
    state = FileUploadState();
  }
}

final fileUploadProvider =
    StateNotifierProvider<FileUploadNotifier, FileUploadState>((ref) {
  return FileUploadNotifier(ref.watch(fileRepositoryProvider));
});
```

---

## 5. 파일 업로드 UI 위젯

### lib/presentation/widgets/file_upload_widget.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_app/presentation/providers/file_upload_provider.dart';
import 'package:agora_app/services/file_picker_service.dart';

class FileUploadWidget extends ConsumerStatefulWidget {
  final Function(String fileUrl) onUploadSuccess;
  final String uploadType; // 'IMAGE', 'FILE', 'PROFILE_IMAGE'

  const FileUploadWidget({
    required this.onUploadSuccess,
    required this.uploadType,
  });

  @override
  ConsumerState<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends ConsumerState<FileUploadWidget> {
  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(fileUploadProvider);
    final filePickerService = ref.read(filePickerServiceProvider);

    return Column(
      children: [
        if (uploadState.status == UploadStatus.uploading)
          LinearProgressIndicator(
            value: (uploadState.progress ?? 0) / 100,
            minHeight: 4,
          ),
        SizedBox(height: 16),
        if (uploadState.status == UploadStatus.idle)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (widget.uploadType == 'IMAGE' ||
                  widget.uploadType == 'PROFILE_IMAGE')
                ElevatedButton.icon(
                  icon: Icon(Icons.photo),
                  label: Text('갤러리'),
                  onPressed: () async {
                    final file =
                        await filePickerService.pickImageFromGallery();
                    if (file != null) {
                      _uploadFile(file.path);
                    }
                  },
                ),
              if (widget.uploadType == 'IMAGE')
                ElevatedButton.icon(
                  icon: Icon(Icons.camera),
                  label: Text('카메라'),
                  onPressed: () async {
                    final file =
                        await filePickerService.pickImageFromCamera();
                    if (file != null) {
                      _uploadFile(file.path);
                    }
                  },
                ),
              if (widget.uploadType == 'FILE')
                ElevatedButton.icon(
                  icon: Icon(Icons.file_present),
                  label: Text('파일 선택'),
                  onPressed: () async {
                    final result = await filePickerService.pickFile();
                    if (result != null) {
                      _uploadFile(result.files.single.path ?? '');
                    }
                  },
                ),
            ],
          ),
        if (uploadState.status == UploadStatus.uploading)
          Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text('${uploadState.progress}% 업로드 중...'),
            ],
          ),
        if (uploadState.status == UploadStatus.success)
          Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 40),
              SizedBox(height: 8),
              Text('업로드 완료'),
              if (uploadState.fileUrl != null)
                Image.network(
                  uploadState.fileUrl!,
                  height: 150,
                  fit: BoxFit.cover,
                ),
            ],
          ),
        if (uploadState.status == UploadStatus.error)
          Column(
            children: [
              Icon(Icons.error, color: Colors.red, size: 40),
              SizedBox(height: 8),
              Text('업로드 실패: ${uploadState.error}'),
              ElevatedButton(
                onPressed: () {
                  ref.read(fileUploadProvider.notifier).reset();
                },
                child: Text('다시 시도'),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _uploadFile(String filePath) async {
    final notifier = ref.read(fileUploadProvider.notifier);
    String? fileUrl;

    switch (widget.uploadType) {
      case 'IMAGE':
        fileUrl = await notifier.uploadImage(filePath);
        break;
      case 'PROFILE_IMAGE':
        fileUrl = await notifier.uploadProfileImage(filePath);
        break;
      case 'FILE':
        fileUrl = await notifier.uploadFile(filePath);
        break;
    }

    if (fileUrl != null) {
      widget.onUploadSuccess(fileUrl);
    }
  }
}
```

---

## 6. 프로필 이미지 업로드 예제

```dart
class ProfileEditScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('프로필 수정')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('프로필 이미지'),
            SizedBox(height: 16),
            FileUploadWidget(
              uploadType: 'PROFILE_IMAGE',
              onUploadSuccess: (fileUrl) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('프로필 이미지 변경 완료')),
                );
                // 프로필 정보 업데이트
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 7. 채팅에서 파일 첨부

```dart
class ChatDetailScreen extends ConsumerStatefulWidget {
  final int chatId;

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final filePickerService = ref.read(filePickerServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('채팅'),
        actions: [
          IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: () async {
              final result = await filePickerService.pickFile();
              if (result != null) {
                // 파일 첨부 처리
                final filePath = result.files.single.path ?? '';
                // 업로드 로직
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 메시지 목록
          Expanded(
            child: MessageListView(),
          ),
          // 메시지 입력창
          MessageInputBar(),
        ],
      ),
    );
  }
}
```

---

## Android 권한 설정

### android/app/src/main/AndroidManifest.xml

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />
```

---

## iOS 권한 설정

### ios/Runner/Info.plist

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>앱이 사진 라이브러리에 접근하기 위해 권한이 필요합니다</string>

<key>NSCameraUsageDescription</key>
<string>앱이 카메라에 접근하기 위해 권한이 필요합니다</string>

<key>NSMicrophoneUsageDescription</key>
<string>앱이 마이크에 접근하기 위해 권한이 필요합니다</string>
```

---

## 주의사항

1. **파일 크기**: 서버는 최대 50MB 허용
2. **이미지 품질**: 업로드 전 압축 권장
3. **권한**: 앱 시작 시 권한 요청
4. **캐싱**: 다운로드 파일은 캐시 디렉토리에 저장
5. **진행률**: 큰 파일은 진행률 표시 필수

---

## 다음 단계

- FLUTTER_STATE_MANAGEMENT.md - 상태 관리 패턴
