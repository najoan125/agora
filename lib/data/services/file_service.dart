import 'dart:io';
import 'package:dio/dio.dart';
import '../api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/exception/app_exception.dart';
import '../models/file/agora_file.dart';

/// 파일 서비스
class FileService {
  final ApiClient _apiClient;

  FileService([ApiClient? apiClient]) : _apiClient = apiClient ?? ApiClient();

  /// 파일 업로드 (최대 50MB)
  /// [file] 업로드할 파일
  /// [onSendProgress] 업로드 진행률 콜백
  Future<Result<FileUploadResponse>> uploadFile(
    File file, {
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      // 파일 크기 확인 (50MB 제한)
      final fileSize = await file.length();
      if (fileSize > 50 * 1024 * 1024) {
        return Failure(
          AppException.validation(
            message: 'File size exceeds 50MB limit',
            userMessage: '파일 크기는 50MB를 초과할 수 없습니다.',
          ),
        );
      }

      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.uploadFile(
        ApiEndpoints.fileUpload,
        formData: formData,
        onSendProgress: onSendProgress,
      );

      return Success(FileUploadResponse.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 이미지 업로드 (썸네일 자동 생성)
  /// [imageFile] 업로드할 이미지 파일
  /// [onSendProgress] 업로드 진행률 콜백
  Future<Result<FileUploadResponse>> uploadImage(
    File imageFile, {
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      // 파일 크기 확인 (50MB 제한)
      final fileSize = await imageFile.length();
      if (fileSize > 50 * 1024 * 1024) {
        return Failure(
          AppException.validation(
            message: 'Image size exceeds 50MB limit',
            userMessage: '이미지 크기는 50MB를 초과할 수 없습니다.',
          ),
        );
      }

      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.uploadFile(
        ApiEndpoints.fileUploadImage,
        formData: formData,
        onSendProgress: onSendProgress,
      );

      return Success(FileUploadResponse.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 파일 메타데이터 조회
  Future<Result<AgoraFile>> getFileMetadata(String fileId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.fileMeta(fileId));
      return Success(AgoraFile.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 파일 다운로드 URL 조회
  Future<Result<String>> getDownloadUrl(String fileId) async {
    try {
      final response =
          await _apiClient.get(ApiEndpoints.fileDownload(fileId));
      final url = response.data['downloadUrl'] as String;
      return Success(url);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 파일 다운로드
  /// [fileId] 파일 ID
  /// [savePath] 저장할 경로
  /// [onReceiveProgress] 다운로드 진행률 콜백
  Future<Result<void>> downloadFile(
    String fileId,
    String savePath, {
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    try {
      // 다운로드 URL 먼저 조회
      final urlResult = await getDownloadUrl(fileId);
      if (urlResult is Failure) {
        return Failure((urlResult as Failure).error);
      }

      final downloadUrl = (urlResult as Success).value;

      // 파일 다운로드
      await _apiClient.downloadFile(
        downloadUrl,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );

      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 파일 삭제
  Future<Result<void>> deleteFile(String fileId) async {
    try {
      await _apiClient.delete(ApiEndpoints.fileById(fileId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 여러 파일 동시 업로드
  /// [files] 업로드할 파일 리스트
  /// [onProgress] 전체 진행률 콜백 (현재 파일 인덱스, 총 파일 개수)
  Future<Result<List<FileUploadResponse>>> uploadMultipleFiles(
    List<File> files, {
    void Function(int current, int total)? onProgress,
  }) async {
    final results = <FileUploadResponse>[];

    for (int i = 0; i < files.length; i++) {
      onProgress?.call(i + 1, files.length);

      final result = await uploadFile(files[i]);
      if (result is Failure) {
        return Failure((result as Failure).error);
      }

      results.add((result as Success).value);
    }

    return Success(results);
  }

  /// 여러 이미지 동시 업로드
  /// [images] 업로드할 이미지 파일 리스트
  /// [onProgress] 전체 진행률 콜백 (현재 파일 인덱스, 총 파일 개수)
  Future<Result<List<FileUploadResponse>>> uploadMultipleImages(
    List<File> images, {
    void Function(int current, int total)? onProgress,
  }) async {
    final results = <FileUploadResponse>[];

    for (int i = 0; i < images.length; i++) {
      onProgress?.call(i + 1, images.length);

      final result = await uploadImage(images[i]);
      if (result is Failure) {
        return Failure((result as Failure).error);
      }

      results.add((result as Success).value);
    }

    return Success(results);
  }
}
