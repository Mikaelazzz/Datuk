import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'api_service.dart';

/// WebSocket service for real-time history updates
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  static const Duration _pingInterval = Duration(seconds: 30);

  // Stream controller for broadcasting events to listeners
  final StreamController<Map<String, dynamic>> _eventController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;
  bool get isConnected => _isConnected;

  /// Get WebSocket URL derived from ApiService.baseUrl
  static String get _wsUrl {
    final httpUrl = ApiService.baseUrl;
    // Convert http(s):// to ws(s)://
    final wsUrl = httpUrl
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
    return '$wsUrl/ws';
  }

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_isConnected) return;

    try {
      final wsUrl = _wsUrl;
      debugPrint('WebSocket: Connecting to $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Listen for messages
      _channel!.stream.listen(
        (data) {
          _handleMessage(data);
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _handleDisconnect();
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          _handleDisconnect();
        },
      );

      _isConnected = true;
      _reconnectAttempts = 0;
      debugPrint('WebSocket: Connected successfully');

      // Start ping timer to keep connection alive
      _startPingTimer();
    } catch (e) {
      debugPrint('WebSocket: Connection failed - $e');
      _scheduleReconnect();
    }
  }

  void _handleMessage(dynamic data) {
    try {
      final message = jsonDecode(data as String) as Map<String, dynamic>;
      debugPrint('WebSocket received: ${message['type']}');

      // Broadcast to all listeners
      _eventController.add(message);
    } catch (e) {
      // Handle pong response
      if (data == 'pong') {
        debugPrint('WebSocket: Received pong');
      } else {
        debugPrint('WebSocket: Failed to parse message - $e');
      }
    }
  }

  void _handleDisconnect() {
    _isConnected = false;
    _stopPingTimer();
    _scheduleReconnect();
  }

  void _startPingTimer() {
    _stopPingTimer();
    _pingTimer = Timer.periodic(_pingInterval, (_) {
      if (_isConnected && _channel != null) {
        try {
          _channel!.sink.add('ping');
        } catch (e) {
          debugPrint('WebSocket: Ping failed - $e');
        }
      }
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('WebSocket: Max reconnect attempts reached');
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      _reconnectAttempts++;
      debugPrint('WebSocket: Reconnecting... (attempt $_reconnectAttempts)');
      connect();
    });
  }

  /// Disconnect from WebSocket server
  void disconnect() {
    _stopPingTimer();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    debugPrint('WebSocket: Disconnected');
  }

  /// Dispose the service
  void dispose() {
    disconnect();
    _eventController.close();
  }
}
