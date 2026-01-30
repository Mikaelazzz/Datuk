import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../screens/no_internet_screen.dart';

/// A wrapper widget that monitors internet connectivity
/// and shows NoInternetScreen when connection is lost
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    // Initialize and get initial status
    await _connectivityService.initialize();

    if (mounted) {
      setState(() {
        _isConnected = _connectivityService.isConnected;
      });
    }

    // Listen for changes
    _connectivityService.connectionStatus.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });
      }
    });
  }

  Future<void> _onRetry() async {
    // Check connection again
    final isConnected = await _connectivityService.checkConnection();

    if (mounted) {
      setState(() {
        _isConnected = isConnected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return NoInternetScreen(onRetry: _onRetry);
    }

    return widget.child;
  }
}
