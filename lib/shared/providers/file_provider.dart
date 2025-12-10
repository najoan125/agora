import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/file_service.dart';

/// File 서비스 Provider
final fileServiceProvider = Provider<FileService>((ref) {
  return FileService();
});
