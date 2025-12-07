import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ChatDatabase {
  static final ChatDatabase instance = ChatDatabase._init();
  static Database? _database;

  ChatDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chat.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Messages table
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY,
        username TEXT,
        room_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        parent_message_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_sent INTEGER DEFAULT 1,
        is_deleted INTEGER DEFAULT 0,
        is_edited INTEGER DEFAULT 0,
        is_pending INTEGER DEFAULT 0,
        local_id TEXT UNIQUE
      )
    ''');

    // Pending messages queue (for offline sending)
    await db.execute('''
      CREATE TABLE pending_messages (
        local_id TEXT PRIMARY KEY,
        username TEXT,
        room_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        parent_message_id INTEGER,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0
      )
    ''');

    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX idx_messages_room_id ON messages(room_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_messages_created_at ON messages(created_at)
    ''');
  }

  // ==================== MESSAGES ====================
  
  Future<void> insertMessage(Map<String, dynamic> message) async {
    final db = await database;
    await db.insert(
      'messages',
      message,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertMessages(List<Map<String, dynamic>> messages) async {
    final db = await database;
    final batch = db.batch();
    
    for (var message in messages) {
      batch.insert(
        'messages',
        message,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getMessages(
    int roomId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await database;
    return await db.query(
      'messages',
      where: 'room_id = ?',
      whereArgs: [roomId],
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<void> deleteMessage(int messageId) async {
    final db = await database;
    await db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  Future<void> clearRoomMessages(int roomId) async {
    final db = await database;
    await db.delete(
      'messages',
      where: 'room_id = ?',
      whereArgs: [roomId],
    );
  }

  // ==================== PENDING MESSAGES QUEUE ====================

  Future<String> addPendingMessage({
    required int roomId,
    required String content,
    int? parentMessageId,
  }) async {
    final db = await database;
    final localId = '${DateTime.now().millisecondsSinceEpoch}_${roomId}';
    
    await db.insert('pending_messages', {
      'local_id': localId,
      'room_id': roomId,
      'content': content,
      'parent_message_id': parentMessageId,
      'created_at': DateTime.now().toIso8601String(),
      'retry_count': 0,
    });

    return localId;
  }

  Future<List<Map<String, dynamic>>> getPendingMessages() async {
    final db = await database;
    return await db.query(
      'pending_messages',
      orderBy: 'created_at ASC',
    );
  }

  Future<void> removePendingMessage(String localId) async {
    final db = await database;
    await db.delete(
      'pending_messages',
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<void> incrementRetryCount(String localId) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE pending_messages SET retry_count = retry_count + 1 WHERE local_id = ?',
      [localId],
    );
  }

  // ==================== UTILITY ====================

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('messages');
    await db.delete('pending_messages');
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}