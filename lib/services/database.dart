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
    _database = await _initDB('my_ai_gateway.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
    );
  }


  Future _createDB(Database db, int version) async {
    await db.execute('CREATE TABLE providers (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, url TEXT, auth_token TEXT, type TEXT, default_model TEXT);');
    await db.execute('CREATE TABLE chats (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, provider_id INTEGER, model_name TEXT, created_at TEXT);');
    await db.execute('CREATE TABLE messages (id INTEGER PRIMARY KEY AUTOINCREMENT, chat_id INTEGER, is_user INTEGER, provider_id INTEGER, model_name TEXT, created_at TEXT, content TEXT);');
    await db.execute('CREATE TABLE config (id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT UNIQUE, value TEXT);');
  }

  // TODO: Add type to provider
  // If openai, or custom, or other
  // TODO: add config table to track last used provider and model
  // along with the last opened chat

  // Create provider
  Future<int> createProvider(Provider provider) async {
    final db = await instance.database;
    var p = provider.toMap();
    p['id'] = null;
    return await db.insert('providers', p, conflictAlgorithm: ConflictAlgorithm.replace);
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
    final result = await db.query('providers', where: 'id = ?', whereArgs: [id]);
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
    return await db.insert('chats', c, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Read all chats
  Future<List<Chat>> readAllChats() async {
    final db = await instance.database;
    final result = await db.query('chats');
    return result.map((json) => Chat.fromJson(json)).toList();
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
    return await db.insert('messages', m, conflictAlgorithm: ConflictAlgorithm.replace);
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
    final result = await db.query('messages', where: 'chat_id = ?', whereArgs: [chatId]);
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
    return await db.delete('messages', where: 'chat_id = ?', whereArgs: [chatId]);
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

  // Reset database
  Future<void> resetDatabase() async {
    final db = await instance.database;
    await db.execute('DROP TABLE IF EXISTS providers');
    await db.execute('DROP TABLE IF EXISTS chats');
    await db.execute('DROP TABLE IF EXISTS messages');
    await db.execute('DROP TABLE IF EXISTS config');
    await _createDB(db, 1);
  }

  // Delete database
  deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_ai_gateway.db');
    databaseFactory.deleteDatabase(path);
  }

}
