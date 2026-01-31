import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/landing_page.dart';
import 'widgets/connectivity_wrapper.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: false, // Set to false untuk disable device preview
      builder: (context) => const DatukApp(),
    ),
  );
}

class DatukApp extends StatelessWidget {
  const DatukApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Datuk App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          ThemeMode.light, // Change to ThemeMode.system for auto dark mode
      home: const ConnectivityWrapper(child: LandingPage()),
    );
  }
}
