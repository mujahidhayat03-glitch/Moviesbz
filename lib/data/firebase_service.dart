// lib/data/firebase_service.dart
// 🔥 Full Firebase/Firestore Service — Content + Admin Panel

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_model.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _contentCol = 'content';
  static const String _watchlistCol = 'watchlists';
  static const String _historyCol = 'watch_history';
  static const String _settingsDoc = 'app_settings';
  static const String _metaCol = 'meta';

  // ─────────────────────────────────────────────
  //  CONTENT — Read
  // ─────────────────────────────────────────────

  /// Sab content Firestore se lao (one-time)
  static Future<List<ContentItem>> getAllContent() async {
    final snap = await _db
        .collection(_contentCol)
        .orderBy('addedAt', descending: true)
        .get();
    return snap.docs.map((d) => _docToItem(d)).toList();
  }

  /// Real-time stream — app automatically update hoga jab admin change kare
  static Stream<List<ContentItem>> contentStream() {
    return _db
        .collection(_contentCol)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _docToItem(d)).toList());
  }

  /// Category ke hisab se filter
  static Future<List<ContentItem>> getByCategory(
      ContentCategory category) async {
    final snap = await _db
        .collection(_contentCol)
        .where('category', isEqualTo: category.id)
        .orderBy('addedAt', descending: true)
        .get();
    return snap.docs.map((d) => _docToItem(d)).toList();
  }

  /// Search
  static Future<List<ContentItem>> search(String query) async {
    // Firestore mein full-text search nahi hota, isliye title se match karein
    final q = query.toLowerCase();
    final snap = await _db.collection(_contentCol).get();
    return snap.docs
        .map((d) => _docToItem(d))
        .where((item) =>
            item.title.toLowerCase().contains(q) ||
            item.description.toLowerCase().contains(q) ||
            item.genres.any((g) => g.toLowerCase().contains(q)))
        .toList();
  }

  // ─────────────────────────────────────────────
  //  CONTENT — Admin Write
  // ─────────────────────────────────────────────

  /// Naya content add karo (Admin Panel)
  static Future<void> addContent(ContentItem item) async {
    await _db
        .collection(_contentCol)
        .doc(item.id)
        .set(_itemToMap(item));
    await _incrementStat(item.category.id, 1);
  }

  /// Content update karo (Admin Panel)
  static Future<void> updateContent(ContentItem item) async {
    final map = _itemToMap(item);
    map['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection(_contentCol).doc(item.id).update(map);
  }

  /// Content delete karo (Admin Panel)
  static Future<void> deleteContent(String id, ContentCategory category) async {
    await _db.collection(_contentCol).doc(id).delete();
    await _incrementStat(category.id, -1);
  }

  /// Featured toggle karo
  static Future<void> setFeatured(String id, bool value) async {
    await _db.collection(_contentCol).doc(id).update({'isFeatured': value});
  }

  /// Trending toggle karo
  static Future<void> setTrending(String id, bool value) async {
    await _db.collection(_contentCol).doc(id).update({'isTrending': value});
  }

  // ─────────────────────────────────────────────
  //  WATCHLIST (per device/user)
  // ─────────────────────────────────────────────

  static Future<List<String>> getWatchlistIds(String deviceId) async {
    final doc =
        await _db.collection(_watchlistCol).doc(deviceId).get();
    if (!doc.exists) return [];
    final data = doc.data()!;
    return List<String>.from(data['ids'] ?? []);
  }

  static Future<void> saveWatchlist(
      String deviceId, List<String> ids) async {
    await _db.collection(_watchlistCol).doc(deviceId).set({
      'ids': ids,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─────────────────────────────────────────────
  //  WATCH HISTORY
  // ─────────────────────────────────────────────

  static Future<void> recordView(String deviceId, String contentId,
      {String? episodeId}) async {
    final docId = '${deviceId}_$contentId';
    final ref = _db.collection(_historyCol).doc(docId);
    final snap = await ref.get();
    if (snap.exists) {
      await ref.update({
        'lastWatched': FieldValue.serverTimestamp(),
        'watchCount': FieldValue.increment(1),
        if (episodeId != null) 'lastEpisodeId': episodeId,
      });
    } else {
      await ref.set({
        'deviceId': deviceId,
        'contentId': contentId,
        'lastWatched': FieldValue.serverTimestamp(),
        'watchCount': 1,
        'lastEpisodeId': episodeId,
      });
    }
  }

  static Future<List<String>> getRecentlyViewedIds(String deviceId,
      {int limit = 20}) async {
    final snap = await _db
        .collection(_historyCol)
        .where('deviceId', isEqualTo: deviceId)
        .orderBy('lastWatched', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => d.data()['contentId'] as String)
        .toList();
  }

  // ─────────────────────────────────────────────
  //  ADMIN — Stats
  // ─────────────────────────────────────────────

  /// Real-time stats stream (Admin Dashboard ke liye)
  static Stream<Map<String, int>> statsStream() {
    return _db
        .collection(_metaCol)
        .doc(_settingsDoc)
        .snapshots()
        .map((snap) {
      if (!snap.exists) return {};
      final data = snap.data()!;
      return {
        'total': (data['total'] ?? 0) as int,
        'movies': (data['movies'] ?? 0) as int,
        'web_series': (data['web_series'] ?? 0) as int,
        'comedy': (data['comedy'] ?? 0) as int,
        'dramas': (data['dramas'] ?? 0) as int,
      };
    });
  }

  /// Poore stats recalculate karo (Admin ke liye sync button)
  static Future<Map<String, int>> recalculateStats() async {
    final snap = await _db.collection(_contentCol).get();
    final stats = <String, int>{'total': snap.docs.length};
    for (final cat in ContentCategory.values) {
      stats[cat.id] =
          snap.docs.where((d) => d['category'] == cat.id).length;
    }
    await _db.collection(_metaCol).doc(_settingsDoc).set(stats);
    return stats;
  }

  // ─────────────────────────────────────────────
  //  BATCH IMPORT — Mock data Firestore pe upload
  // ─────────────────────────────────────────────

  /// Pehli baar: mock data ko Firestore pe upload karo
  static Future<void> batchImport(List<ContentItem> items) async {
    const batchSize = 400; // Firestore limit 500
    for (int i = 0; i < items.length; i += batchSize) {
      final batch = _db.batch();
      final chunk = items.skip(i).take(batchSize);
      for (final item in chunk) {
        final ref = _db.collection(_contentCol).doc(item.id);
        batch.set(ref, _itemToMap(item));
      }
      await batch.commit();
    }
    await recalculateStats();
  }

  // ─────────────────────────────────────────────
  //  Converters
  // ─────────────────────────────────────────────

  static ContentItem _docToItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return ContentItem.fromJson(data);
  }

  static Map<String, dynamic> _itemToMap(ContentItem item) {
    final map = item.toJson();
    // Firestore timestamp ke liye addedAt string hi rakho
    return map;
  }

  static Future<void> _incrementStat(String key, int delta) async {
    final ref = _db.collection(_metaCol).doc(_settingsDoc);
    await ref.set({
      key: FieldValue.increment(delta),
      'total': FieldValue.increment(delta),
    }, SetOptions(merge: true));
  }
}
