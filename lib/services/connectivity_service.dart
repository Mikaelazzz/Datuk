import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service to monitor internet connectivity status
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  /// Initialize the connectivity service
  Future<void> initialize() async {
    // Check initial status
    await checkConnection();

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((results) async {
      await checkConnection();
    });
  }

  /// Check actual internet connection by making a request
  Future<bool> checkConnection() async {
    try {
      // Check connectivity type first
      final results = await _connectivity.checkConnectivity();

      // If no connectivity at all
      if (results.contains(ConnectivityResult.none) || results.isEmpty) {
        _updateConnectionStatus(false);
        return false;
      }

      // For web platform, we can assume connected if there's any connectivity
      if (kIsWeb) {
        _updateConnectionStatus(true);
        return true;
      }

      // For mobile, verify actual internet by making a request
      try {
        final response = await http
            .get(Uri.parse('https://www.google.com'))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          _updateConnectionStatus(true);
          return true;
        }
      } catch (e) {
        // Try another endpoint
        try {
          final response = await http
              .get(Uri.parse('https://www.cloudflare.com'))
              .timeout(const Duration(seconds: 5));

          if (response.statusCode == 200) {
            _updateConnectionStatus(true);
            return true;
          }
        } catch (e) {
          _updateConnectionStatus(false);
          return false;
        }
      }

      _updateConnectionStatus(false);
      return false;
    } catch (e) {
      _updateConnectionStatus(false);
      return false;
    }
  }

  void _updateConnectionStatus(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      _connectionStatusController.add(isConnected);
    }
  }

  /// Dispose the service
  void dispose() {
    _connectionStatusController.close();
  }
}
