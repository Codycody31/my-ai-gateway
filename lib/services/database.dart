import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:my_ai_gateway/models/chat.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/message.dart';
import '../models/provider.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();

  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase('my_ai_gateway.db');
    return _database!;
  }

  // I use a map for more readability, the key represents the version of the db
  Map<int, String> migrationScripts = {
    1: 'CREATE TABLE providers (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, url TEXT, auth_token TEXT, type TEXT, api_type TEXT, default_model TEXT);',
    2: 'CREATE TABLE chats (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, provider_id INTEGER, model_name TEXT, created_at TEXT);',
    3: 'CREATE TABLE messages (id INTEGER PRIMARY KEY AUTOINCREMENT, chat_id INTEGER, is_user INTEGER, provider_id INTEGER, model_name TEXT, created_at TEXT, content TEXT);',
    4: 'CREATE TABLE config (id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT UNIQUE, value TEXT);',
    5: 'ALTER TABLE chats ADD COLUMN last_active_at TEXT DEFAULT NULL;',
    6: 'UPDATE chats SET last_active_at = created_at;',
  };

  Future<Database> initDatabase(String filePath) async {
    int nbrMigrationScripts = migrationScripts.length;
    final dbPath = await getDatabasesPath();
    var path = join(dbPath, filePath);

    // TODO: If in development, ie: developer is working the app, use the default .dart_tool path
    if (Platform.isLinux || Platform.isMacOS) {
      final homeDir = Platform.environment['HOME'];
      path = join(homeDir!, '.myaigateway', filePath);
    }
    if (Platform.isWindows) {
      final homeDir = Platform.environment['USERPROFILE'];
      path = join(homeDir!, '.myaigateway', filePath);
    }

    // TODO: Handle platform-specific database paths, excluding android and IOS

    return await openDatabase(
      path,
      version: nbrMigrationScripts,
      onCreate: (Database db, int version) async {
        for (int i = 1; i <= nbrMigrationScripts; i++) {
          await db.execute(migrationScripts[i]!);
          debugPrint('Migration script $i executed');
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        for (int i = oldVersion + 1; i <= newVersion; i++) {
          await db.execute(migrationScripts[i]!);
          debugPrint('Migration script $i executed');
        }
      },
    );
  }

  String databaseLocation() {
    return _database!.path;
  }

  // Create provider
  Future<int> createProvider(Provider provider) async {
    final db = await instance.database;
    var p = provider.toMap();
    p['id'] = null;
    return await db.insert('providers', p,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Read all providers
  Future<List<Provider>> readAllProviders() async {
    final db = await instance.database;
    final result = await db.query('providers');
    return result.map((json) => Provider.fromJson(json)).toList();
  }

  // Get provider by ID
  Future<Provider?> getProviderById(int id) async {
    final db = await instance.database;
    final result =
        await db.query('providers', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? Provider.fromJson(result.first) : null;
  }

  // Update provider
  Future<int> updateProvider(Provider provider) async {
    final db = await instance.database;
    return await db.update(
      'providers',
      provider.toMap(),
      where: 'id = ?',
      whereArgs: [provider.id],
    );
  }

// Delete provider by ID
  Future<int> deleteProviderById(int id) async {
    final db = await instance.database;
    return await db.delete('providers', where: 'id = ?', whereArgs: [id]);
  }

  // Create chat
  Future<int> createChat(Chat chat) async {
    final db = await instance.database;
    var c = chat.toMap();
    c['id'] = null;
    return await db.insert('chats', c,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Chat>> readAllChats() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
    await db.query('chats', orderBy: 'last_active_at DESC');

    return List.generate(maps.length, (i) {
      return Chat.fromJson(maps[i]);
    });
  }


  // Get chat by ID
  Future<Chat?> getChatById(int id) async {
    final db = await instance.database;
    final result = await db.query('chats', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? Chat.fromJson(result.first) : null;
  }

  Future<void> updateChatName(int chatId, String newName) async {
    final db = await instance.database;
    await db.update(
      'chats',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [chatId],
    );
  }

  Future<void> updateChatModelName(int chatId, String newModelName) async {
    final db = await instance.database;
    await db.update(
      'chats',
      {'model_name': newModelName},
      where: 'id = ?',
      whereArgs: [chatId],
    );
  }

  // Delete chat by ID
  Future<int> deleteChatById(int id) async {
    final db = await instance.database;
    return await db.delete('chats', where: 'id = ?', whereArgs: [id]);
  }

  // Create message
  Future<int> createMessage(Message message) async {
    final db = await instance.database;
    var m = message.toMap();
    m['id'] = null;
    return await db.insert('messages', m,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Read all messages
  Future<List<Message>> readAllMessages() async {
    final db = await instance.database;
    final result = await db.query('messages');
    return result.map((json) => Message.fromJson(json)).toList();
  }

  // Get message by ID
  Future<Message?> getMessageById(int id) async {
    final db = await instance.database;
    final result = await db.query('messages', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? Message.fromJson(result.first) : null;
  }

  // Get messages by chat ID
  Future<List<Message>> getMessagesByChatId(int chatId) async {
    final db = await instance.database;
    final result =
        await db.query('messages', where: 'chat_id = ?', whereArgs: [chatId]);
    return result.map((json) => Message.fromJson(json)).toList();
  }

  Future<void> updateMessageContent(int messageId, String newContent) async {
    final db = await instance.database;
    await db.update(
      'messages',
      {'content': newContent},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  // Delete message by ID
  Future<int> deleteMessageById(int id) async {
    final db = await instance.database;
    return await db.delete('messages', where: 'id = ?', whereArgs: [id]);
  }

  // Delete all messages by chat ID
  Future<int> deleteMessagesByChatId(int chatId) async {
    final db = await instance.database;
    return await db
        .delete('messages', where: 'chat_id = ?', whereArgs: [chatId]);
  }

  Future<void> setConfig(String key, String value) async {
    final db = await instance.database;
    await db.insert(
      'config',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getConfig(String key) async {
    final db = await instance.database;
    final result = await db.query(
      'config',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
    );
    return result.isNotEmpty ? result.first['value'] as String : null;
  }

  Future<void> setLastOpenedChat(int chatId) async {
    await setConfig('last_opened_chat', chatId.toString());
  }

  Future<int?> getLastOpenedChat() async {
    final chatId = await getConfig('last_opened_chat');
    return chatId != null ? int.parse(chatId) : null;
  }

  Future<void> updateChatLastActive(int chatId) async {
    final db = await database;
    await db.update(
      'chats',
      {'last_active_at': DateTime.now().toString()},
      where: 'id = ?',
      whereArgs: [chatId],
    );
  }


  // Reset the entire database
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_ai_gateway.db');

    // Close the database before deleting
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    // Delete the database file
    await deleteDatabase(path);

    // Reinitialize the database
    _database = await initDatabase('my_ai_gateway.db');
    debugPrint('Database reset successfully');
  }
}
