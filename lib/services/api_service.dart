import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000'; // Windows, iOS, macOS, Linux
  }

  static Future<Map<String, dynamic>> predictCough(String filePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/predict'));
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType('audio', 'mpeg'), // Adjust based on file type if needed
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Server returned status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
}
