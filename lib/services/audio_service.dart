import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Result class to hold audio file info (works for both web and native)
class AudioFileResult {
  final String name;
  final String? path; // Only available on native platforms
  final Uint8List? bytes; // Available on all platforms
  final String extension;

  AudioFileResult({
    required this.name,
    this.path,
    this.bytes,
    required this.extension,
  });
}

/// Service for handling audio file operations
class AudioService {
  /// Pick an audio file from device storage
  /// Returns AudioFileResult if successful, null otherwise
  static Future<AudioFileResult?> pickAudioFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
        withData: true, // Required for web to get bytes
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Validate audio format
        final extension = file.extension?.toLowerCase() ?? '';
        if (!_isValidAudioExtension(extension)) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Format file tidak didukung. Gunakan MP3, WAV, atau M4A.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return null;
        }

        return AudioFileResult(
          name: file.name,
          // IMPORTANT: On web, accessing file.path throws an exception!
          // We must check kIsWeb before accessing it
          path: kIsWeb ? null : file.path,
          bytes: file.bytes, // Available on all platforms when withData: true
          extension: extension,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error picking audio file: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memilih file: ${e.toString().split('\n').first}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  /// Check if extension is a valid audio format
  static bool _isValidAudioExtension(String extension) {
    final validExtensions = ['mp3', 'wav', 'aac', 'm4a', 'ogg', 'flac', 'wma'];
    return validExtensions.contains(extension);
  }

  /// Get file name from path (for backwards compatibility)
  static String getFileName(String path) {
    return path.split('/').last.split('\\').last;
  }

  /// Get file extension from path (for backwards compatibility)
  static String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  /// Check if file is a valid audio format (for backwards compatibility)
  static bool isValidAudioFormat(String path) {
    final extension = getFileExtension(path);
    return _isValidAudioExtension(extension);
  }
}
