import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tan_network/screens/login_screen.dart';
import 'package:tan_network/screens/splash_screen.dart';
import 'package:tan_network/screens/main_layout.dart';
import 'package:tan_network/theme/app_theme.dart';
import 'package:tan_network/services/api_service.dart';
import 'package:tan_network/services/notification_service.dart';
import 'package:tan_network/core/navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final container = ProviderContainer();
  
  final apiService = container.read(apiServiceProvider);

  // Initialize Notifications
  await NotificationService.initialize(apiService);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TanNetworkApp(),
    ),
  );
}

class TanNetworkApp extends StatelessWidget {
  const TanNetworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TAN Network',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainLayout(),
      },
    );
  }
}
