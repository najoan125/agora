import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' as html;

class FileDownloadHelper {
  static Future<void> downloadFile({
    required Uint8List fileBytes,
    required String fileName,
    String? filePath,
  }) async {
    if (kIsWeb) {
      // Web implementation
      final blob = html.Blob([fileBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Mobile implementation
      String? path = filePath;
      
      if (path == null) {
        // If no path provided (e.g. from server bytes), save to temp
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(fileBytes);
        path = file.path;
      }
      
      // Open the file
      final result = await OpenFile.open(path);
      if (result.type != ResultType.done) {
        debugPrint('Error opening file: ${result.message}');
      }
    }
  }
}
