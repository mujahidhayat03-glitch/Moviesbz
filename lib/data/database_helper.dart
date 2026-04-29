// lib/data/database_helper.dart
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/content_model.dart';

class DatabaseHelper {
  static const _dbName = 'moviesbz.db';
  static const _dbVersion = 1;

  static const _tableContent = 'content';
  static const _tableWatchlist = 'watchlist';
  static const _tableDownloads = 'downloads';
  static const _tableHistory = 'watch_history';

  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    // Content table
    await db.execute('''
      CREATE TABLE $_tableContent (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        poster_url TEXT NOT NULL,
        backdrop_url TEXT,
        category TEXT NOT NULL,
        genres TEXT NOT NULL,
        release_year INTEGER,
        rating REAL NOT NULL,
        duration_minutes INTEGER,
        language TEXT,
        country TEXT,
        is_featured INTEGER DEFAULT 0,
        is_trending INTEGER DEFAULT 0,
        is_new INTEGER DEFAULT 0,
        watch_links TEXT NOT NULL DEFAULT '[]',
        download_links TEXT NOT NULL DEFAULT '[]',
        seasons TEXT NOT NULL DEFAULT '[]',
        added_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Watchlist table
    await db.execute('''
      CREATE TABLE $_tableWatchlist (
        content_id TEXT PRIMARY KEY,
        added_at TEXT NOT NULL
      )
    ''');

    // Downloads table
    await db.execute('''
      CREATE TABLE $_tableDownloads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content_id TEXT NOT NULL,
        title TEXT NOT NULL,
        file_path TEXT NOT NULL,
        quality TEXT NOT NULL,
        file_size_mb REAL,
        status TEXT NOT NULL DEFAULT 'completed',
        downloaded_at TEXT NOT NULL
      )
    ''');

    // Watch history table
    await db.execute('''
      CREATE TABLE $_tableHistory (
        content_id TEXT PRIMARY KEY,
        last_watched TEXT NOT NULL,
        watch_count INTEGER DEFAULT 1,
        last_episode_id TEXT
      )
    ''');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // Handle future migrations here
  }

  // ─── Content CRUD ───

  static Future<void> insertContent(ContentItem item) async {
    final db = await database;
    await db.insert(
      _tableContent,
      _contentToMap(item),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertBatch(List<ContentItem> items) async {
    final db = await database;
    final batch = db.batch();
    for (final item in items) {
      batch.insert(
        _tableContent,
        _contentToMap(item),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<List<ContentItem>> getAllContent() async {
    final db = await database;
    final maps = await db.query(_tableContent, orderBy: 'added_at DESC');
    return maps.map(_mapToContent).toList();
  }

  static Future<List<ContentItem>> getContentByCategory(
      ContentCategory category) async {
    final db = await database;
    final maps = await db.query(
      _tableContent,
      where: 'category = ?',
      whereArgs: [category.id],
      orderBy: 'added_at DESC',
    );
    return maps.map(_mapToContent).toList();
  }

  static Future<ContentItem?> getContentById(String id) async {
    final db = await database;
    final maps = await db.query(
      _tableContent,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return _mapToContent(maps.first);
  }

  static Future<List<ContentItem>> searchContent(String query) async {
    final db = await database;
    final q = '%${query.toLowerCase()}%';
    final maps = await db.rawQuery('''
      SELECT * FROM $_tableContent
      WHERE LOWER(title) LIKE ? 
        OR LOWER(description) LIKE ?
        OR LOWER(genres) LIKE ?
      ORDER BY rating DESC
    ''', [q, q, q]);
    return maps.map(_mapToContent).toList();
  }

  static Future<void> updateContent(ContentItem item) async {
    final db = await database;
    final map = _contentToMap(item);
    map['updated_at'] = DateTime.now().toIso8601String();
    await db.update(
      _tableContent,
      map,
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  static Future<void> deleteContent(String id) async {
    final db = await database;
    await db.delete(_tableContent, where: 'id = ?', whereArgs: [id]);
  }

  // ─── Watchlist ───

  static Future<void> addToWatchlist(String contentId) async {
    final db = await database;
    await db.insert(
      _tableWatchlist,
      {'content_id': contentId, 'added_at': DateTime.now().toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<void> removeFromWatchlist(String contentId) async {
    final db = await database;
    await db.delete(
      _tableWatchlist,
      where: 'content_id = ?',
      whereArgs: [contentId],
    );
  }

  static Future<List<String>> getWatchlistIds() async {
    final db = await database;
    final maps = await db.query(
      _tableWatchlist,
      columns: ['content_id'],
      orderBy: 'added_at DESC',
    );
    return maps.map((m) => m['content_id'] as String).toList();
  }

  static Future<bool> isInWatchlist(String contentId) async {
    final db = await database;
    final maps = await db.query(
      _tableWatchlist,
      where: 'content_id = ?',
      whereArgs: [contentId],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  // ─── Downloads ───

  static Future<void> recordDownload({
    required String contentId,
    required String title,
    required String filePath,
    required String quality,
    double? fileSizeMb,
  }) async {
    final db = await database;
    await db.insert(_tableDownloads, {
      'content_id': contentId,
      'title': title,
      'file_path': filePath,
      'quality': quality,
      'file_size_mb': fileSizeMb,
      'status': 'completed',
      'downloaded_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getDownloads() async {
    final db = await database;
    return db.query(_tableDownloads, orderBy: 'downloaded_at DESC');
  }

  static Future<void> deleteDownloadRecord(int id) async {
    final db = await database;
    await db.delete(_tableDownloads, where: 'id = ?', whereArgs: [id]);
  }

  // ─── Watch History ───

  static Future<void> recordView(String contentId, {String? episodeId}) async {
    final db = await database;
    final existing = await db.query(
      _tableHistory,
      where: 'content_id = ?',
      whereArgs: [contentId],
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert(_tableHistory, {
        'content_id': contentId,
        'last_watched': DateTime.now().toIso8601String(),
        'watch_count': 1,
        'last_episode_id': episodeId,
      });
    } else {
      await db.update(
        _tableHistory,
        {
          'last_watched': DateTime.now().toIso8601String(),
          'watch_count': (existing.first['watch_count'] as int) + 1,
          'last_episode_id': episodeId ?? existing.first['last_episode_id'],
        },
        where: 'content_id = ?',
        whereArgs: [contentId],
      );
    }
  }

  static Future<List<String>> getRecentlyViewedIds({int limit = 20}) async {
    final db = await database;
    final maps = await db.query(
      _tableHistory,
      columns: ['content_id'],
      orderBy: 'last_watched DESC',
      limit: limit,
    );
    return maps.map((m) => m['content_id'] as String).toList();
  }

  static Future<String?> getLastEpisodeId(String contentId) async {
    final db = await database;
    final maps = await db.query(
      _tableHistory,
      columns: ['last_episode_id'],
      where: 'content_id = ?',
      whereArgs: [contentId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first['last_episode_id'] as String?;
  }

  // ─── Helpers ───

  static Map<String, dynamic> _contentToMap(ContentItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'description': item.description,
      'poster_url': item.posterUrl,
      'backdrop_url': item.backdropUrl,
      'category': item.category.id,
      'genres': jsonEncode(item.genres),
      'release_year': item.releaseYear,
      'rating': item.rating,
      'duration_minutes': item.durationMinutes,
      'language': item.language,
      'country': item.country,
      'is_featured': item.isFeatured ? 1 : 0,
      'is_trending': item.isTrending ? 1 : 0,
      'is_new': item.isNew ? 1 : 0,
      'watch_links':
          jsonEncode(item.watchLinks.map((l) => l.toJson()).toList()),
      'download_links':
          jsonEncode(item.downloadLinks.map((l) => l.toJson()).toList()),
      'seasons': jsonEncode([]), // Simplified for SQLite (use separate table for real app)
      'added_at': item.addedAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  static ContentItem _mapToContent(Map<String, dynamic> map) {
    final watchLinksJson =
        jsonDecode(map['watch_links'] as String) as List<dynamic>;
    final downloadLinksJson =
        jsonDecode(map['download_links'] as String) as List<dynamic>;
    final genresJson = jsonDecode(map['genres'] as String) as List<dynamic>;

    return ContentItem(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      posterUrl: map['poster_url'] as String,
      backdropUrl: map['backdrop_url'] as String?,
      category: ContentCategory.values.firstWhere(
        (c) => c.id == map['category'],
        orElse: () => ContentCategory.movies,
      ),
      genres: genresJson.cast<String>(),
      releaseYear: map['release_year'] as int?,
      rating: (map['rating'] as num).toDouble(),
      durationMinutes: map['duration_minutes'] as int?,
      language: map['language'] as String?,
      country: map['country'] as String?,
      isFeatured: (map['is_featured'] as int) == 1,
      isTrending: (map['is_trending'] as int) == 1,
      isNew: (map['is_new'] as int) == 1,
      watchLinks: watchLinksJson
          .map((e) => VideoLink.fromJson(e as Map<String, dynamic>))
          .toList(),
      downloadLinks: downloadLinksJson
          .map((e) => VideoLink.fromJson(e as Map<String, dynamic>))
          .toList(),
      addedAt: DateTime.parse(map['added_at'] as String),
    );
  }

  // ─── Stats for admin ───

  static Future<Map<String, int>> getContentStats() async {
    final db = await database;
    final stats = <String, int>{};

    for (final cat in ContentCategory.values) {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableContent WHERE category = ?',
        [cat.id],
      );
      stats[cat.id] = Sqflite.firstIntValue(result) ?? 0;
    }

    final total = await db
        .rawQuery('SELECT COUNT(*) as count FROM $_tableContent');
    stats['total'] = Sqflite.firstIntValue(total) ?? 0;

    final watchlist = await db
        .rawQuery('SELECT COUNT(*) as count FROM $_tableWatchlist');
    stats['watchlist'] = Sqflite.firstIntValue(watchlist) ?? 0;

    final downloads = await db
        .rawQuery('SELECT COUNT(*) as count FROM $_tableDownloads');
    stats['downloads'] = Sqflite.firstIntValue(downloads) ?? 0;

    return stats;
  }

  static Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}
