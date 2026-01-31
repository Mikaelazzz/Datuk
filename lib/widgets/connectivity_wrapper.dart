import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../screens/no_internet_screen.dart';

/// A global wrapper widget that monitors internet connectivity
/// and shows NoInternetScreen as an overlay when connection is lost.
/// User must press "Coba Lagi" button to dismiss the overlay.
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isConnected = true;
  bool _showOverlay = false;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    // Initialize and get initial status
    await _connectivityService.initialize();

    if (mounted) {
      final connected = _connectivityService.isConnected;
      setState(() {
        _isConnected = connected;
        _showOverlay = !connected;
      });
    }

    // Listen for changes
    _connectivityService.connectionStatus.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
          // Show overlay when connection is lost
          if (!isConnected) {
            _showOverlay = true;
          }
          // Note: We DON'T auto-hide overlay when connection returns
          // User must press "Coba Lagi" button
        });
      }
    });
  }

  Future<void> _onRetry() async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
    });

    // Check connection
    final isConnected = await _connectivityService.checkConnection();

    if (mounted) {
      setState(() {
        _isRetrying = false;
        _isConnected = isConnected;

        // Only dismiss overlay if connection is restored
        if (isConnected) {
          _showOverlay = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main app content
        widget.child,

        // No internet overlay
        if (_showOverlay)
          Positioned.fill(
            child: NoInternetScreen(onRetry: _onRetry, isRetrying: _isRetrying),
          ),
      ],
    );
  }
}
