// lib/screens/watchlist_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../data/content_provider.dart';
import '../models/content_model.dart';
import '../theme/app_theme.dart';
import 'detail_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContentProvider>();
    final items = provider.watchlist;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Watchlist'),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClearAll(context, provider),
              child: const Text(
                'Clear All',
                style: TextStyle(color: AppTheme.primary, fontSize: 13),
              ),
            ),
        ],
      ),
      body: items.isEmpty ? _EmptyWatchlist() : _WatchlistContent(items: items),
    );
  }

  void _confirmClearAll(BuildContext context, ContentProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        title: const Text('Clear Watchlist',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'Remove all items from your watchlist?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              // Toggle all off
              for (final item in provider.watchlist.toList()) {
                provider.toggleWatchlist(item.id);
              }
              Navigator.pop(context);
            },
            child:
                const Text('Clear', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }
}

class _EmptyWatchlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.bookmark_border_rounded,
                color: AppTheme.textMuted, size: 40),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your watchlist is empty',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Save movies and shows to watch later',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.explore_rounded),
            label: const Text('Explore Content'),
          ),
        ],
      ),
    );
  }
}

class _WatchlistContent extends StatelessWidget {
  final List<ContentItem> items;

  const _WatchlistContent({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            '${items.length} saved item${items.length == 1 ? '' : 's'}',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WatchlistCard(item: item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WatchlistCard extends StatelessWidget {
  final ContentItem item;

  const _WatchlistCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ContentProvider>();

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_remove_rounded, color: AppTheme.primary, size: 26),
            SizedBox(height: 4),
            Text('Remove',
                style: TextStyle(color: AppTheme.primary, fontSize: 11)),
          ],
        ),
      ),
      onDismissed: (_) => provider.toggleWatchlist(item.id),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(item: item)),
        ),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Poster
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: item.posterUrl,
                  width: 74,
                  height: 110,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 74,
                    color: AppTheme.surfaceLight,
                    child: const Icon(Icons.movie, color: AppTheme.textMuted),
                  ),
                ),
              ),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: (AppTheme.categoryColors[item.category.id] ??
                                  AppTheme.primary)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.category.displayName,
                          style: TextStyle(
                            color: AppTheme.categoryColors[item.category.id] ??
                                AppTheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppTheme.accent, size: 13),
                          const SizedBox(width: 3),
                          Text(
                            item.rating.toStringAsFixed(1),
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 12),
                          ),
                          if (item.releaseYear != null) ...[
                            const SizedBox(width: 10),
                            Text(
                              item.releaseYear.toString(),
                              style: const TextStyle(
                                  color: AppTheme.textMuted, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.genres.take(2).join(' · '),
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              // Actions
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DetailScreen(item: item)),
                    ),
                    icon: const Icon(Icons.play_circle_rounded,
                        color: AppTheme.primary, size: 28),
                  ),
                  IconButton(
                    onPressed: () => provider.toggleWatchlist(item.id),
                    icon: const Icon(Icons.bookmark_rounded,
                        color: AppTheme.accent, size: 22),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
