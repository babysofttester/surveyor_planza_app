import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class OfflineWorkQueueService {
  static Database? _db;

  //  open / create DB 
  static Future<Database> _getDb() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'work_queue.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE work_queue (
            id        INTEGER PRIMARY KEY AUTOINCREMENT,
            payload   TEXT    NOT NULL,
            queued_at TEXT    NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  //  enqueue 
  static Future<void> enqueue({
    required String projectId,
    required String bookingNo,
    required double length,
    required double breadth,
    required String description,
    required List<String> imagePaths,
  }) async {
    final db = await _getDb();
    final now = DateTime.now().toIso8601String();

    final payload = jsonEncode({
      'project_id':  projectId,
      'booking_no':  bookingNo,
      'length':      length,
      'breadth':     breadth,
      'description': description,
      'image_paths': imagePaths,
      'queued_at':   now,
    });

    await db.insert('work_queue', {
      'payload':   payload,
      'queued_at': now,
    });
  }

  //  dequeue all (reads + wipes atomically) 
  static Future<List<Map<String, dynamic>>> dequeueAll() async {
    final db = await _getDb();

    return db.transaction<List<Map<String, dynamic>>>((txn) async {
      final rows = await txn.query(
        'work_queue',
        columns: ['payload'],
        orderBy: 'id ASC',
      );
      await txn.delete('work_queue');

      return rows.map((row) {
        return Map<String, dynamic>.from(
          jsonDecode(row['payload'] as String) as Map,
        );
      }).toList();
    });
  }

  //  peek (non-destructive) 
  static Future<List<Map<String, dynamic>>> peekAll() async {
    final db = await _getDb();
    final rows = await db.query('work_queue', orderBy: 'id ASC');
    return rows.map((row) {
      return Map<String, dynamic>.from(
        jsonDecode(row['payload'] as String) as Map,
      );
    }).toList();
  }

  //  count 
  static Future<int> pendingCount() async {
    final db = await _getDb();
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM work_queue');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  //  clear (logout) 
  static Future<void> clearAll() async {
    final db = await _getDb();
    await db.delete('work_queue');
  }

  //  close (optional, for testing) 
  static Future<void> closeDb() async {
    await _db?.close();
    _db = null;
  }
}