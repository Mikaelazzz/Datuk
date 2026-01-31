import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/splash_screen.dart';
import 'widgets/connectivity_wrapper.dart';
import 'package:device_preview/device_preview.dart';
import 'services/theme_service.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: false, // Set to false untuk disable device preview
      builder: (context) => const DatukApp(),
    ),
  );
}

class DatukApp extends StatefulWidget {
  const DatukApp({super.key});

  @override
  State<DatukApp> createState() => _DatukAppState();
}

class _DatukAppState extends State<DatukApp> {
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Datuk App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeService.themeMode,
      builder: (context, child) {
        // Wrap all routes with ConnectivityWrapper
        return ConnectivityWrapper(child: child ?? const SizedBox.shrink());
      },
      home: const SplashScreen(),
    );
  }
}
