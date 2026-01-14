import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Service for handling audio file operations
class AudioService {
  /// Pick an audio file from device storage
  /// Returns the file path if successful, null otherwise
  static Future<String?> pickAudioFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        return file.path;
      }
      return null;
    } catch (e) {
      debugPrint('Error picking audio file: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  /// Get file name from path
  static String getFileName(String path) {
    return path.split('/').last.split('\\').last;
  }

  /// Get file extension from path
  static String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  /// Check if file is a valid audio format
  static bool isValidAudioFormat(String path) {
    final validExtensions = ['mp3', 'wav', 'aac', 'm4a', 'ogg', 'flac', 'wma'];
    final extension = getFileExtension(path);
    return validExtensions.contains(extension);
  }
}
