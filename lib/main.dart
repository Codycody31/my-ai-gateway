import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_ai_gateway/pages/chat.dart';
import 'package:my_ai_gateway/services/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


void main() {
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
  }
  // Change the default factory. On iOS/Android, if not using `sqlite_flutter_lib` you can forget
  // this step, it will use the sqlite version available on the system.
  databaseFactory = databaseFactoryFfi;
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


