import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

/// Service to manage user identification and auto-registration
class UserService {
  static const String _userIdKey = 'datuk_user_id';
  static const String _userCreatedAtKey = 'datuk_user_created_at';

  static UserService? _instance;
  static String? _userId;
  static bool _isInitialized = false;

  UserService._internal();

  /// Get singleton instance
  static UserService get instance {
    _instance ??= UserService._internal();
    return _instance!;
  }

  /// Get the current user ID (must call initialize first)
  static String? get userId => _userId;

  /// Check if user is initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize the user service - generates UUID if needed and registers with backend
  static Future<String> initialize() async {
    if (_isInitialized && _userId != null) {
      return _userId!;
    }

    final prefs = await SharedPreferences.getInstance();

    // Check if user ID exists
    String? storedUserId = prefs.getString(_userIdKey);

    if (storedUserId == null) {
      // Generate new UUID
      storedUserId = const Uuid().v4();
      await prefs.setString(_userIdKey, storedUserId);
    }

    _userId = storedUserId;

    // Register with backend (will get existing if already registered)
    try {
      await _registerWithBackend(storedUserId);
    } catch (e) {
      // Continue anyway - will retry on next API call
    }

    _isInitialized = true;
    return storedUserId;
  }

  /// Register user with backend
  static Future<Map<String, dynamic>> _registerWithBackend(
    String userId,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'user_id': userId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Store created_at locally
      if (data['user'] != null && data['user']['created_at'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userCreatedAtKey, data['user']['created_at']);
      }

      return data;
    } else {
      throw Exception('Failed to register user: ${response.statusCode}');
    }
  }

  /// Get user info from local storage
  static Future<Map<String, dynamic>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'user_id': prefs.getString(_userIdKey),
      'created_at': prefs.getString(_userCreatedAtKey),
    };
  }

  /// Clear user data (for testing/debugging)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userCreatedAtKey);
    _userId = null;
    _isInitialized = false;
  }
}
