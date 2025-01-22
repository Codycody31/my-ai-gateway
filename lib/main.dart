import 'package:flutter/material.dart';
import 'package:my_ai_gateway/pages/chat.dart';
import 'package:my_ai_gateway/services/theme_notifier.dart';
import 'package:provider/provider.dart';

void main() {
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


