// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/content_provider.dart';
import '../models/content_model.dart';
import '../theme/app_theme.dart';
import '../widgets/content_card.dart';
import 'detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContentProvider>();

    if (provider.isLoading) {
      return const _LoadingScreen();
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ─── App Bar ───
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppTheme.background,
            title: _BrandLogo(),
            actions: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
                icon: const Icon(Icons.search_rounded, color: AppTheme.textPrimary),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined, color: AppTheme.textPrimary),
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ─── Content ───
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Featured Banner
                if (provider.featured.isNotEmpty)
                  _FeaturedBanner(items: provider.featured),

                // Trending Row
                SectionHeader(
                  title: '🔥 Trending Now',
                  accentColor: AppTheme.primary,
                  actionLabel: 'See All',
                ),
                _HorizontalScrollRow(
                  items: provider.trending,
                  cardType: CardType.landscape,
                ),

                // Recently Added
                SectionHeader(
                  title: '✨ Recently Added',
                  accentColor: AppTheme.accent,
                  actionLabel: 'See All',
                ),
                _HorizontalScrollRow(
                  items: provider.recentlyAdded,
                  cardType: CardType.poster,
                ),

                // Movies Section
                SectionHeader(
                  title: '🎬 Movies',
                  accentColor: AppTheme.categoryColors['movies']!,
                  actionLabel: 'See All',
                ),
                _HorizontalScrollRow(
                  items: provider.byCategory(ContentCategory.movies),
                  cardType: CardType.poster,
                ),

                // Web Series Section
                SectionHeader(
                  title: '📺 Web Series',
                  accentColor: AppTheme.categoryColors['web_series']!,
                  actionLabel: 'See All',
                ),
                _HorizontalScrollRow(
                  items: provider.byCategory(ContentCategory.webSeries),
                  cardType: CardType.landscape,
                ),

                // Comedy Shows Section
                SectionHeader(
                  title: '😂 Comedy Shows',
                  accentColor: AppTheme.categoryColors['comedy']!,
                  actionLabel: 'See All',
                ),
                _HorizontalScrollRow(
                  items: provider.byCategory(ContentCategory.comedyShows),
                  cardType: CardType.poster,
                ),

                // Pakistani Dramas Section
                SectionHeader(
                  title: '🇵🇰 Pakistani Dramas',
                  accentColor: AppTheme.categoryColors['dramas']!,
                  actionLabel: 'See All',
                ),
                _HorizontalScrollRow(
                  items: provider.byCategory(ContentCategory.pakistaniDramas),
                  cardType: CardType.poster,
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Brand Logo ───
class _BrandLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'movies',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          TextSpan(
            text: '.bz',
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Featured Banner (PageView with auto-scroll) ───
class _FeaturedBanner extends StatefulWidget {
  final List<ContentItem> items;

  const _FeaturedBanner({required this.items});

  @override
  State<_FeaturedBanner> createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends State<_FeaturedBanner> {
  final PageController _controller = PageController();
  int _current = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), _startAutoPlay);
  }

  void _startAutoPlay() {
    if (!mounted) return;
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      final next = (_current + 1) % widget.items.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      _startAutoPlay();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenH * 0.52,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: widget.items.length,
            itemBuilder: (_, i) {
              final item = widget.items[i];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailScreen(item: item)),
                ),
                child: _BannerSlide(item: item),
              );
            },
          ),
          // Dot indicators
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.items.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _current == i ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _current == i ? AppTheme.primary : Colors.white30,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerSlide extends StatelessWidget {
  final ContentItem item;

  const _BannerSlide({required this.item});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        Image.network(
          item.backdropUrl ?? item.posterUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: AppTheme.surfaceLight),
        ),
        // Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: const [0, 0.5, 1],
              colors: [
                AppTheme.background,
                AppTheme.background.withOpacity(0.4),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Content info
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Genres
              Row(
                children: item.genres
                    .take(3)
                    .map((g) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            g.toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 6),
              // Title
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              // Action buttons
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetailScreen(item: item)),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: const Text('Watch Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetailScreen(item: item)),
                    ),
                    icon: const Icon(Icons.info_outline_rounded, size: 18, color: Colors.white),
                    label: const Text('More Info', style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Horizontal Scroll Row ───
enum CardType { poster, landscape }

class _HorizontalScrollRow extends StatelessWidget {
  final List<ContentItem> items;
  final CardType cardType;

  const _HorizontalScrollRow({required this.items, required this.cardType});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox(
        height: 60,
        child: Center(
          child: Text('No content yet', style: TextStyle(color: AppTheme.textMuted)),
        ),
      );
    }

    return SizedBox(
      height: cardType == CardType.poster ? 220 : 165,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: cardType == CardType.poster
                ? ContentPosterCard(
                    item: item,
                    onTap: () => _navigate(context, item),
                    width: 110,
                  )
                : ContentLandscapeCard(
                    item: item,
                    onTap: () => _navigate(context, item),
                    width: 240,
                  ),
          );
        },
      ),
    );
  }

  void _navigate(BuildContext context, ContentItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(item: item)),
    );
  }
}

// ─── Loading Screen ───
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'movies',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(
                    text: '.bz',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
