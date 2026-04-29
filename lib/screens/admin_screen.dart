// lib/screens/admin_screen.dart
// 🔥 Firebase-powered Admin Panel — real-time Firestore control

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/content_provider.dart';
import '../data/firebase_service.dart';
import '../models/content_model.dart';
import '../theme/app_theme.dart';
import 'admin_edit_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ContentCategory _filterCategory = ContentCategory.movies;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_rounded,
                color: AppTheme.primary, size: 22),
            SizedBox(width: 8),
            Text('Admin Panel',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
            SizedBox(width: 8),
            // 🔥 Firebase badge
            _FirebaseBadge(),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Content'),
            Tab(text: 'Add New'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DashboardTab(),
          _ContentTab(
            filterCategory: _filterCategory,
            onCategoryChange: (c) => setState(() => _filterCategory = c),
          ),
          AdminEditScreen(
            onSaved: () => _tabController.animateTo(1),
          ),
        ],
      ),
    );
  }
}

// ─── Firebase Live Badge ───
class _FirebaseBadge extends StatelessWidget {
  const _FirebaseBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6D00).withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFFF6D00).withOpacity(0.4)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded,
              color: Color(0xFFFF6D00), size: 10),
          SizedBox(width: 3),
          Text('LIVE',
              style: TextStyle(
                  color: Color(0xFFFF6D00),
                  fontSize: 9,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// ─── Dashboard Tab ───
class _DashboardTab extends StatefulWidget {
  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  bool _syncing = false;

  Future<void> _syncStats() async {
    setState(() => _syncing = true);
    try {
      await context.read<ContentProvider>().recalculateStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Stats synced with Firestore!'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContentProvider>();
    final total = provider.allContent.length;
    final categoryCounts = {
      for (final cat in ContentCategory.values)
        cat: provider.byCategory(cat).length,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─ Firebase Status Banner ─
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2A1A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 8),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Firestore Real-Time Connected — moviesbz-1',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ),
                InkWell(
                  onTap: _syncing ? null : _syncStats,
                  child: _syncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.green),
                        )
                      : const Icon(Icons.sync_rounded,
                          color: Colors.green, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ─ Stats ─
          const Text('Overview',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _StatCard(
            icon: Icons.movie_rounded,
            label: 'Total Content (Firestore)',
            value: total.toString(),
            color: AppTheme.primary,
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: ContentCategory.values
                .map((cat) => _StatCard(
                      icon: Icons.folder_rounded,
                      label: cat.displayName,
                      value: '${categoryCounts[cat]}',
                      color:
                          AppTheme.categoryColors[cat.id] ?? AppTheme.primary,
                      small: true,
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),

          // ─ Quick Actions ─
          const Text('Quick Actions',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _QuickAction(
            icon: Icons.add_rounded,
            label: 'Add New Content',
            subtitle: 'Directly save to Firestore database',
            badge: 'FIREBASE',
            badgeColor: const Color(0xFFFF6D00),
            onTap: () {},
          ),
          _QuickAction(
            icon: Icons.trending_up_rounded,
            label: 'Manage Featured & Trending',
            subtitle: 'Toggle from Content tab — saves instantly',
            onTap: () {},
          ),
          _QuickAction(
            icon: Icons.delete_sweep_rounded,
            label: 'Bulk Delete',
            subtitle: 'Remove multiple items from Firestore',
            onTap: () => _showComingSoon(context, 'Bulk Delete'),
            badge: 'SOON',
            badgeColor: AppTheme.warning,
          ),
          _QuickAction(
            icon: Icons.upload_file_rounded,
            label: 'Import JSON to Firestore',
            subtitle: 'Bulk upload content from JSON file',
            onTap: () => _showComingSoon(context, 'JSON Import'),
            badge: 'SOON',
            badgeColor: AppTheme.warning,
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — coming soon!'),
        backgroundColor: AppTheme.warning,
      ),
    );
  }
}

// ─── Content Management Tab ───
class _ContentTab extends StatelessWidget {
  final ContentCategory filterCategory;
  final ValueChanged<ContentCategory> onCategoryChange;

  const _ContentTab(
      {required this.filterCategory, required this.onCategoryChange});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContentProvider>();
    final items = provider.byCategory(filterCategory);

    return Column(
      children: [
        // Category filter chips
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: ContentCategory.values
                .map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat.displayName),
                        selected: filterCategory == cat,
                        onSelected: (_) => onCategoryChange(cat),
                        selectedColor: AppTheme.primary.withOpacity(0.2),
                        checkmarkColor: AppTheme.primary,
                        labelStyle: TextStyle(
                          color: filterCategory == cat
                              ? AppTheme.primary
                              : AppTheme.textMuted,
                          fontSize: 12,
                        ),
                        backgroundColor: AppTheme.surface,
                        side: BorderSide(
                          color: filterCategory == cat
                              ? AppTheme.primary
                              : AppTheme.divider,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),

        // Content count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department_rounded,
                  color: Color(0xFFFF6D00), size: 14),
              const SizedBox(width: 4),
              Text(
                '${items.length} items in Firestore',
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Text('No content in this category',
                      style: TextStyle(color: AppTheme.textMuted)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return _ContentListTile(item: item);
                  },
                ),
        ),
      ],
    );
  }
}

// ─── Content List Tile with Firebase actions ───
class _ContentListTile extends StatelessWidget {
  final ContentItem item;

  const _ContentListTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ContentProvider>();

    return Card(
      color: AppTheme.surface,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              item.posterUrl,
              width: 40,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 40,
                height: 56,
                color: AppTheme.surfaceLight,
                child: const Icon(Icons.movie,
                    color: AppTheme.textMuted, size: 16),
              ),
            ),
          ),
          title: Text(item.title,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.releaseYear ?? 'N/A'} • ⭐ ${item.rating}',
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 4),
              // Featured / Trending badges
              Row(
                children: [
                  _FirestoreToggleBadge(
                    label: 'Featured',
                    active: item.isFeatured,
                    onTap: () => provider.toggleFeatured(item.id),
                  ),
                  const SizedBox(width: 6),
                  _FirestoreToggleBadge(
                    label: 'Trending',
                    active: item.isTrending,
                    color: Colors.orange,
                    onTap: () => provider.toggleTrending(item.id),
                  ),
                ],
              ),
            ],
          ),
          isThreeLine: true,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AdminEditScreen(item: item)),
                ),
                icon: const Icon(Icons.edit_rounded,
                    color: AppTheme.textSecondary, size: 18),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
              ),
              // Delete
              IconButton(
                onPressed: () => _confirmDelete(context, provider),
                icon: const Icon(Icons.delete_rounded,
                    color: Colors.red, size: 18),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ContentProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🔥 Delete from Firestore',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
        content: Text(
          '"${item.title}" Firestore se permanently delete ho jayega.\n\nKya aap sure hain?',
          style: const TextStyle(color: AppTheme.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.deleteContent(item.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${item.title}" deleted from Firestore'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── Firestore Toggle Badge (Featured / Trending) ───
class _FirestoreToggleBadge extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color color;

  const _FirestoreToggleBadge({
    required this.label,
    required this.active,
    required this.onTap,
    this.color = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: active ? color : AppTheme.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? color : AppTheme.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─── Shared Widgets ───
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool small;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(small ? 12 : 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: small ? 16 : 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: small ? 18 : 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: small ? 10 : 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;
  final Color badgeColor;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.badge,
    this.badgeColor = AppTheme.warning,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(label,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border:
                    Border.all(color: badgeColor.withOpacity(0.4)),
              ),
              child: Text(badge!,
                  style: TextStyle(
                      color: badgeColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w800)),
            ),
          ],
        ],
      ),
      subtitle: Text(subtitle,
          style:
              const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppTheme.textMuted),
      onTap: onTap,
    );
  }
}
