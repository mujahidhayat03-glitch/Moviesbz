// lib/data/content_provider.dart
// 🔥 Firebase-powered ContentProvider — real-time Firestore sync

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/content_model.dart';
import 'firebase_service.dart';
import 'mock_data.dart';

class ContentProvider extends ChangeNotifier {
  List<ContentItem> _allContent = [];
  List<String> _watchlistIds = [];
  List<String> _recentlyViewedIds = [];
  bool _isLoading = false;
  String? _error;
  String _deviceId = '';

  StreamSubscription<List<ContentItem>>? _contentSub;

  // ─── Getters ───
  List<ContentItem> get allContent => _allContent;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ContentItem> get featured =>
      _allContent.where((c) => c.isFeatured).toList();
  List<ContentItem> get trending =>
      _allContent.where((c) => c.isTrending).toList();
  List<ContentItem> get recentlyAdded {
    final sorted = List<ContentItem>.from(_allContent)
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return sorted.take(12).toList();
  }

  List<ContentItem> get watchlist =>
      _allContent.where((c) => _watchlistIds.contains(c.id)).toList();

  List<ContentItem> get recentlyViewed => _recentlyViewedIds
      .map((id) => _allContent.firstWhere(
            (c) => c.id == id,
            orElse: () => _allContent.isEmpty ? _dummyItem() : _allContent.first,
          ))
      .where((c) => _recentlyViewedIds.contains(c.id))
      .toList();

  List<ContentItem> byCategory(ContentCategory category) =>
      _allContent.where((c) => c.category == category).toList();

  List<ContentItem> search(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return _allContent
        .where((c) =>
            c.title.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q) ||
            c.genres.any((g) => g.toLowerCase().contains(q)))
        .toList();
  }

  bool isInWatchlist(String id) => _watchlistIds.contains(id);

  // ─────────────────────────────────────────────
  //  Initialize — Firebase real-time stream
  // ─────────────────────────────────────────────

  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('device_id') ??
        DateTime.now().millisecondsSinceEpoch.toString();
    await prefs.setString('device_id', _deviceId);

    try {
      final existing = await FirebaseService.getAllContent();

      if (existing.isEmpty) {
        debugPrint('📦 Firestore empty — mock data upload ho raha hai...');
        await FirebaseService.batchImport(MockData.allContent);
      }

      _watchlistIds = await FirebaseService.getWatchlistIds(_deviceId);
      _recentlyViewedIds = await FirebaseService.getRecentlyViewedIds(_deviceId);

      _startRealTimeStream();
    } catch (e) {
      debugPrint('Firebase error: $e');
      _error = e.toString();
      _allContent = MockData.allContent;
      _watchlistIds = prefs.getStringList('watchlist') ?? [];
      _recentlyViewedIds = prefs.getStringList('recently_viewed') ?? [];
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startRealTimeStream() {
    _contentSub?.cancel();
    _contentSub = FirebaseService.contentStream().listen(
      (items) {
        _allContent = items;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ─── Watchlist ───

  Future<void> toggleWatchlist(String id) async {
    if (_watchlistIds.contains(id)) {
      _watchlistIds.remove(id);
    } else {
      _watchlistIds.add(id);
    }
    notifyListeners();
    await FirebaseService.saveWatchlist(_deviceId, _watchlistIds);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('watchlist', _watchlistIds);
  }

  // ─── Recently Viewed ───

  Future<void> addToRecentlyViewed(String id, {String? episodeId}) async {
    _recentlyViewedIds.remove(id);
    _recentlyViewedIds.insert(0, id);
    if (_recentlyViewedIds.length > 20) {
      _recentlyViewedIds = _recentlyViewedIds.take(20).toList();
    }
    notifyListeners();
    await FirebaseService.recordView(_deviceId, id, episodeId: episodeId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recently_viewed', _recentlyViewedIds);
  }

  // ─── Admin CRUD ───

  Future<void> upsertContent(ContentItem item) async {
    final exists = _allContent.any((c) => c.id == item.id);
    if (exists) {
      await FirebaseService.updateContent(item);
    } else {
      await FirebaseService.addContent(item);
    }
    final index = _allContent.indexWhere((c) => c.id == item.id);
    if (index >= 0) {
      _allContent[index] = item;
    } else {
      _allContent.insert(0, item);
    }
    notifyListeners();
  }

  Future<void> deleteContent(String id) async {
    final item = _allContent.firstWhere((c) => c.id == id);
    await FirebaseService.deleteContent(id, item.category);
    _allContent.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Future<void> toggleFeatured(String id) async {
    final index = _allContent.indexWhere((c) => c.id == id);
    if (index < 0) return;
    final newVal = !_allContent[index].isFeatured;
    await FirebaseService.setFeatured(id, newVal);
    _allContent[index] = _allContent[index].copyWith(isFeatured: newVal);
    notifyListeners();
  }

  Future<void> toggleTrending(String id) async {
    final index = _allContent.indexWhere((c) => c.id == id);
    if (index < 0) return;
    final newVal = !_allContent[index].isTrending;
    await FirebaseService.setTrending(id, newVal);
    _allContent[index] = _allContent[index].copyWith(isTrending: newVal);
    notifyListeners();
  }

  Future<Map<String, int>> recalculateStats() =>
      FirebaseService.recalculateStats();

  void setSearchQuery(String query) => notifyListeners();

  @override
  void dispose() {
    _contentSub?.cancel();
    super.dispose();
  }

  ContentItem _dummyItem() => ContentItem(
        id: '',
        title: '',
        description: '',
        posterUrl: '',
        category: ContentCategory.movies,
        genres: [],
        rating: 0,
        watchLinks: [],
        downloadLinks: [],
        addedAt: DateTime.now(),
      );
}
