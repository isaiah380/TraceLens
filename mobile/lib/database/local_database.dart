import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/scan_history_item.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;
  
  // In-memory fallback list for web or environments where sqflite is unavailable
  final List<ScanHistoryItem> _memoryStorage = [];
  int _autoIncrementId = 1;

  LocalDatabase._init();

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    try {
      _database = await _initDB('tracelens_history.db');
      return _database;
    } catch (e) {
      return null;
    }
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
    await db.execute('''
      CREATE TABLE scan_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        scan_type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        preview_text TEXT NOT NULL,
        category TEXT NOT NULL,
        risk_level TEXT NOT NULL,
        risk_score INTEGER NOT NULL,
        brief_explanation TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertScan(ScanHistoryItem item) async {
    if (kIsWeb) {
      final newItem = ScanHistoryItem(
        id: _autoIncrementId++,
        scanType: item.scanType,
        timestamp: item.timestamp,
        previewText: item.previewText,
        category: item.category,
        riskLevel: item.riskLevel,
        riskScore: item.riskScore,
        briefExplanation: item.briefExplanation,
      );
      _memoryStorage.insert(0, newItem);
      return newItem.id ?? 1;
    }

    try {
      final db = await database;
      if (db != null) {
        return await db.insert('scan_history', item.toMap());
      }
    } catch (_) {}

    _memoryStorage.insert(0, item);
    return 1;
  }

  Future<List<ScanHistoryItem>> getAllScans() async {
    if (kIsWeb) {
      return List.from(_memoryStorage);
    }

    try {
      final db = await database;
      if (db != null) {
        final result = await db.query('scan_history', orderBy: 'id DESC');
        return result.map((json) => ScanHistoryItem.fromMap(json)).toList();
      }
    } catch (_) {}

    return List.from(_memoryStorage);
  }

  Future<int> deleteScan(int id) async {
    if (kIsWeb) {
      _memoryStorage.removeWhere((item) => item.id == id);
      return 1;
    }

    try {
      final db = await database;
      if (db != null) {
        return await db.delete('scan_history', where: 'id = ?', whereArgs: [id]);
      }
    } catch (_) {}

    _memoryStorage.removeWhere((item) => item.id == id);
    return 1;
  }

  Future<int> clearAllHistory() async {
    if (kIsWeb) {
      _memoryStorage.clear();
      return 1;
    }

    try {
      final db = await database;
      if (db != null) {
        return await db.delete('scan_history');
      }
    } catch (_) {}

    _memoryStorage.clear();
    return 1;
  }
}
