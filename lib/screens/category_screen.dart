// lib/screens/category_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../data/content_provider.dart';
import '../models/content_model.dart';
import '../theme/app_theme.dart';
import '../widgets/content_card.dart';
import 'detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  final ContentCategory category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String? _selectedGenre;
  String _sortBy = 'newest';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContentProvider>();
    var items = provider.byCategory(widget.category);

    // Filter by genre
    if (_selectedGenre != null) {
      items = items.where((i) => i.genres.contains(_selectedGenre)).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'rating':
        items.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'year':
        items.sort((a, b) => (b.releaseYear ?? 0).compareTo(a.releaseYear ?? 0));
        break;
      case 'newest':
      default:
        items.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    }

    // Collect all genres
    final allGenres = <String>{};
    for (final item in provider.byCategory(widget.category)) {
      allGenres.addAll(item.genres);
    }

    final categoryColor = AppTheme.categoryColors[widget.category.id] ?? AppTheme.primary;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.category.displayName),
        titleTextStyle: TextStyle(
          color: categoryColor,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
        ),
        actions: [
          PopupMenuButton<String>(
            color: AppTheme.surfaceLight,
            onSelected: (v) => setState(() => _sortBy = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'newest', child: Text('Newest First')),
              const PopupMenuItem(value: 'rating', child: Text('Highest Rated')),
              const PopupMenuItem(value: 'year', child: Text('Release Year')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: const [
                  Text('Sort', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  SizedBox(width: 4),
                  Icon(Icons.sort_rounded, color: AppTheme.textSecondary, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Genre filter chips
          if (allGenres.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  GenreChip(
                    genre: 'All',
                    isSelected: _selectedGenre == null,
                    onTap: () => setState(() => _selectedGenre = null),
                  ),
                  const SizedBox(width: 8),
                  ...allGenres.map((g) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GenreChip(
                      genre: g,
                      isSelected: _selectedGenre == g,
                      onTap: () => setState(() => _selectedGenre = _selectedGenre == g ? null : g),
                    ),
                  )),
                ],
              ),
            ),

          // Grid
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'No content found',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  )
                : MasonryGridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ContentPosterCard(
                        item: item,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DetailScreen(item: item)),
                        ),
                        width: double.infinity,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
