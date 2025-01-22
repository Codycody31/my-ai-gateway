import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_ai_gateway/pages/chat.dart';
import 'package:my_ai_gateway/services/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    WindowManager.instance.setMinimumSize(const Size(600, 600));
    // WindowManager.instance.setMaximumSize(const Size(1200, 600));
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyAIGatewayApp(),
    ),
  );
}

class MyAIGatewayApp extends StatelessWidget {
  const MyAIGatewayApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'My AI Gateway',
      theme: themeNotifier.lightTheme,
      darkTheme: themeNotifier.darkTheme,
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const ChatPage(),
    );
  }
}


