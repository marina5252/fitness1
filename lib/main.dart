import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:voicepump/core/theme/app_theme.dart';
import 'package:voicepump/core/router/app_router.dart';
import 'package:voicepump/data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация Firebase
  await Firebase.initializeApp();
  
  // Инициализация уведомлений
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  runApp(
    const ProviderScope(
      child: VoicePumpApp(),
    ),
  );
}

class VoicePumpApp extends ConsumerWidget {
  const VoicePumpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'VoicePump',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

