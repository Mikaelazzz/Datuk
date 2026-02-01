import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';
import 'user_service.dart';

/// Model for diagnosis history from database
class DiagnosisHistory {
  final int id;
  final String jenisBatuk;
  final double confidence;
  final String? tingkatKondisi;
  final List<dynamic>? rekomendasiObat;
  final DateTime createdAt;

  DiagnosisHistory({
    required this.id,
    required this.jenisBatuk,
    required this.confidence,
    this.tingkatKondisi,
    this.rekomendasiObat,
    required this.createdAt,
  });

  factory DiagnosisHistory.fromJson(Map<String, dynamic> json) {
    return DiagnosisHistory(
      id: json['id'] as int,
      jenisBatuk: json['jenis_batuk'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      tingkatKondisi: json['tingkat_kondisi'] as String?,
      rekomendasiObat: json['rekomendasi_obat'] as List<dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Get confidence as percentage string
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(0)}%';

  /// Get formatted date (e.g., "05 Jan")
  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${createdAt.day.toString().padLeft(2, '0')} ${months[createdAt.month - 1]}';
  }

  /// Get formatted time (e.g., "08:30 Pagi")
  String get formattedTime {
    final hour = createdAt.hour;
    final minute = createdAt.minute.toString().padLeft(2, '0');

    String period;
    if (hour >= 5 && hour < 12) {
      period = 'Pagi';
    } else if (hour >= 12 && hour < 15) {
      period = 'Siang';
    } else if (hour >= 15 && hour < 18) {
      period = 'Sore';
    } else {
      period = 'Malam';
    }

    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Get month name in Indonesian
  String get monthName {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[createdAt.month - 1];
  }

  /// Get short month name
  String get monthShort {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[createdAt.month - 1];
  }

  /// Get day as string
  String get day => createdAt.day.toString().padLeft(2, '0');

  /// Get year as string
  String get year => createdAt.year.toString();
}

class ApiService {
  // Production URL - Hugging Face Spaces
  // static const String productionUrl = 'https://vel1xi-datuk-backend.hf.space';

  // // Local development URL
  // static const String localUrl = 'http://localhost:8000';

  // // Toggle this for testing (true = localhost, false = production)
  // static const bool useLocalhost = true;

  // // Get the active base URL
  // static String get baseUrl => useLocalhost ? localUrl : productionUrl;

  // Production URL - Hugging Face Spaces
  static const String baseUrl = 'https://vel1xi-datuk-backend.hf.space';

  /// Get headers with user ID
  static Map<String, String> _getHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json'};

    // Add user ID if available
    if (UserService.userId != null) {
      headers['x-user-id'] = UserService.userId!;
    }

    return headers;
  }

  /// Predict cough type from audio file path
  static Future<Map<String, dynamic>> predictCough(String filePath) async {
    try {
      // Build URL with user_id as query parameter
      var url = '$baseUrl/predict';
      if (UserService.userId != null) {
        url = '$baseUrl/predict?user_id=${UserService.userId}';
      }

      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          contentType: MediaType('audio', 'mpeg'),
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Server returned status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  /// Predict cough type from audio bytes (for web platform)
  static Future<Map<String, dynamic>> predictCoughFromBytes(
    Uint8List bytes,
    String filename,
  ) async {
    try {
      // Build URL with user_id as query parameter
      var url = '$baseUrl/predict';
      if (UserService.userId != null) {
        url = '$baseUrl/predict?user_id=${UserService.userId}';
      }

      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
          contentType: MediaType('audio', 'mpeg'),
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Server returned status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  /// Get diagnosis history from backend (filtered by user)
  static Future<List<DiagnosisHistory>> getHistory({int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history?limit=$limit'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final historyList = data['history'] as List<dynamic>;
        return historyList
            .map(
              (item) => DiagnosisHistory.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception(
          'Server returned status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch history: $e');
    }
  }

  /// Get a specific diagnosis by ID
  static Future<DiagnosisHistory> getDiagnosisById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history/$id'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DiagnosisHistory.fromJson(
          data['diagnosis'] as Map<String, dynamic>,
        );
      } else if (response.statusCode == 404) {
        throw Exception('Diagnosis not found');
      } else {
        throw Exception(
          'Server returned status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch diagnosis: $e');
    }
  }

  /// Delete a diagnosis by ID
  static Future<bool> deleteDiagnosis(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/history/$id'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        return false;
      } else {
        throw Exception(
          'Server returned status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to delete diagnosis: $e');
    }
  }

  /// Get diagnosis statistics (filtered by user)
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['statistics'] as Map<String, dynamic>;
      } else {
        throw Exception(
          'Server returned status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch statistics: $e');
    }
  }

  /// Register user with backend
  static Future<Map<String, dynamic>> registerUser(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Server returned status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }
}
