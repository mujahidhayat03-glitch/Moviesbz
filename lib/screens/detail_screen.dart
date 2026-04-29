// lib/screens/detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../data/content_provider.dart';
import '../models/content_model.dart';
import '../theme/app_theme.dart';
import 'player_screen.dart';
import 'download_manager.dart';

class DetailScreen extends StatefulWidget {
  final ContentItem item;

  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedSeason = 0;

  @override
  void initState() {
    super.initState();
    final tabCount = widget.item.isSerial ? 2 : 1;
    _tabController = TabController(length: tabCount, vsync: this);
    // Track view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().addToRecentlyViewed(widget.item.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final provider = context.watch<ContentProvider>();
    final isInWatchlist = provider.isInWatchlist(item.id);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ─── Hero Header ───
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppTheme.background,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => provider.toggleWatchlist(item.id),
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isInWatchlist ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    size: 18,
                    color: isInWatchlist ? AppTheme.accent : Colors.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.share_rounded, size: 18),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: item.backdropUrl ?? item.posterUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppTheme.background,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Play button overlay
                  if (item.watchLinks.isNotEmpty || (item.seasons.isNotEmpty && item.seasons.first.episodes.isNotEmpty))
                    Center(
                      child: GestureDetector(
                        onTap: () => _watchItem(context, item),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ─── Body ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (item.originalTitle != null && item.originalTitle != item.title)
                    Text(
                      item.originalTitle!,
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  const SizedBox(height: 10),

                  // Meta row
                  Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      if (item.releaseYear != null)
                        _MetaBadge(icon: Icons.calendar_month_rounded, text: item.releaseYear.toString()),
                      if (item.formattedDuration.isNotEmpty)
                        _MetaBadge(icon: Icons.timer_outlined, text: item.formattedDuration),
                      if (item.language != null)
                        _MetaBadge(icon: Icons.language_rounded, text: item.language!),
                      if (item.country != null)
                        _MetaBadge(icon: Icons.flag_rounded, text: item.country!),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Rating
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: item.rating / 2,
                        itemCount: 5,
                        itemSize: 16,
                        itemBuilder: (_, __) => const Icon(
                          Icons.star_rounded,
                          color: AppTheme.accent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.rating}/10',
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Genres
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: item.genres.map((g) => _GenreTag(genre: g)).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _watchItem(context, item),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(item.isSerial ? 'Watch Episode 1' : 'Watch Now'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (item.downloadLinks.isNotEmpty ||
                          (item.seasons.isNotEmpty && item.seasons.first.episodes.isNotEmpty))
                        OutlinedButton.icon(
                          onPressed: () => _showDownloadSheet(context, item),
                          icon: const Icon(Icons.download_rounded, color: AppTheme.textPrimary),
                          label: const Text('Download', style: TextStyle(color: AppTheme.textPrimary)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.divider),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Overview',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ExpandableText(text: item.description),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ─── Episodes (for series) ───
          if (item.isSerial && item.seasons.isNotEmpty)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Row(
                      children: [
                        const Text(
                          'Episodes',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        if (item.seasons.length > 1)
                          DropdownButton<int>(
                            value: _selectedSeason,
                            dropdownColor: AppTheme.surfaceLight,
                            underline: const SizedBox(),
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                            items: List.generate(
                              item.seasons.length,
                              (i) => DropdownMenuItem(
                                value: i,
                                child: Text('Season ${item.seasons[i].seasonNumber}'),
                              ),
                            ),
                            onChanged: (v) => setState(() => _selectedSeason = v ?? 0),
                          ),
                      ],
                    ),
                  ),
                  ...item.seasons[_selectedSeason].episodes.map(
                    (ep) => _EpisodeRow(
                      episode: ep,
                      onWatch: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlayerScreen(
                            title: '${item.title} S${item.seasons[_selectedSeason].seasonNumber}E${ep.episodeNumber}',
                            watchLinks: ep.watchLinks,
                          ),
                        ),
                      ),
                      onDownload: () => _showEpisodeDownloadSheet(context, ep),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _watchItem(BuildContext context, ContentItem item) {
    List<VideoLink> links;
    String title;

    if (item.watchLinks.isNotEmpty) {
      links = item.watchLinks;
      title = item.title;
    } else if (item.seasons.isNotEmpty && item.seasons.first.episodes.isNotEmpty) {
      links = item.seasons.first.episodes.first.watchLinks;
      title = '${item.title} S1E1';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No watch links available yet')),
      );
      return;
    }

    if (links.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Watch links coming soon!')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(title: title, watchLinks: links),
      ),
    );
  }

  void _showDownloadSheet(BuildContext context, ContentItem item) {
    final links = item.downloadLinks.isNotEmpty
        ? item.downloadLinks
        : item.seasons.isNotEmpty && item.seasons.first.episodes.isNotEmpty
            ? item.seasons.first.episodes.first.downloadLinks
            : [];

    _showLinkSheet(context, 'Download', links.cast<VideoLink>(), isDownload: true);
  }

  void _showEpisodeDownloadSheet(BuildContext context, Episode ep) {
    _showLinkSheet(context, 'Download Episode ${ep.episodeNumber}', ep.downloadLinks, isDownload: true);
  }

  void _showLinkSheet(BuildContext context, String title, List<VideoLink> links, {bool isDownload = false}) {
    if (links.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Links not available yet')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _LinkSheet(title: title, links: links, isDownload: isDownload),
    );
  }
}

// ─── Episode Row ───
class _EpisodeRow extends StatelessWidget {
  final Episode episode;
  final VoidCallback onWatch;
  final VoidCallback onDownload;

  const _EpisodeRow({
    required this.episode,
    required this.onWatch,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${episode.episodeNumber}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (episode.durationMinutes != null)
                  Text(
                    '${episode.durationMinutes}m',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: onWatch,
            icon: const Icon(Icons.play_circle_rounded, color: AppTheme.primary, size: 28),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          IconButton(
            onPressed: onDownload,
            icon: const Icon(Icons.download_rounded, color: AppTheme.textSecondary, size: 22),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ],
      ),
    );
  }
}

// ─── Link Sheet ───
class _LinkSheet extends StatelessWidget {
  final String title;
  final List<VideoLink> links;
  final bool isDownload;

  const _LinkSheet({
    required this.title,
    required this.links,
    required this.isDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isDownload ? 'Select quality to download' : 'Select quality to stream',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ...links.map((link) => ListTile(
            leading: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
              ),
              child: Text(
                link.quality.label,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            title: Text(
              link.label,
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            trailing: Icon(
              isDownload ? Icons.download_rounded : Icons.play_arrow_rounded,
              color: AppTheme.textSecondary,
            ),
            onTap: () {
              Navigator.pop(context);
              if (isDownload) {
                DownloadManager.startDownload(context, link);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayerScreen(title: title, watchLinks: [link]),
                  ),
                );
              }
            },
          )),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// ─── Meta Badge ───
class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.textMuted, size: 14),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      ],
    );
  }
}

// ─── Genre Tag ───
class _GenreTag extends StatelessWidget {
  final String genre;

  const _GenreTag({required this.genre});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Text(
        genre,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─── Expandable Description ───
class _ExpandableText extends StatefulWidget {
  final String text;

  const _ExpandableText({required this.text});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            height: 1.6,
          ),
          maxLines: _expanded ? null : 3,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (widget.text.length > 150)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'Show less' : 'Read more',
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
