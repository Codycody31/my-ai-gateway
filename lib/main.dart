import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_ai_gateway/pages/chat.dart';
import 'package:my_ai_gateway/services/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    return true;
  };

  if (Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();
    debugPrint('Changing databaseFactory to ffi');
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    debugPrint('Setting minimum and maximum window size');
    WindowManager.instance.setMinimumSize(const Size(600, 600));
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
      theme: themeNotifier.darkTheme,
      // darkTheme: themeNotifier.darkTheme,
      // themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const ChatPage(),
    );
  }
}
