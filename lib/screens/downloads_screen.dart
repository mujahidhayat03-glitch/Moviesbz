// lib/screens/downloads_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  List<_DownloadItem> _downloads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // TODO: Load from DatabaseHelper.getDownloads()
    setState(() {
      _downloads = []; // Replace with real DB query
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          if (_downloads.isNotEmpty)
            IconButton(
              onPressed: _showStorageInfo,
              icon: const Icon(Icons.storage_rounded, color: AppTheme.textSecondary),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : _downloads.isEmpty
              ? _EmptyDownloads()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _downloads.length,
                  itemBuilder: (context, i) =>
                      _DownloadCard(item: _downloads[i], onDelete: () {
                    setState(() => _downloads.removeAt(i));
                  }),
                ),
    );
  }

  void _showStorageInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Storage Used',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.34,
                backgroundColor: AppTheme.divider,
                color: AppTheme.primary,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Used: 3.4 GB',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                Text('Free: 6.6 GB',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.delete_sweep_rounded),
                label: const Text('Clear All Downloads'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDownloads extends StatelessWidget {
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
            child: const Icon(Icons.download_for_offline_rounded,
                color: AppTheme.textMuted, size: 40),
          ),
          const SizedBox(height: 20),
          const Text('No downloads yet',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Download content to watch offline',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
        ],
      ),
    );
  }
}

class _DownloadItem {
  final String id;
  final String title;
  final String posterUrl;
  final String quality;
  final double sizeMb;
  final DateTime downloadedAt;
  final String filePath;

  const _DownloadItem({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.quality,
    required this.sizeMb,
    required this.downloadedAt,
    required this.filePath,
  });
}

class _DownloadCard extends StatelessWidget {
  final _DownloadItem item;
  final VoidCallback onDelete;

  const _DownloadCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade900.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.red),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.posterUrl,
                width: 52,
                height: 78,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 52,
                  height: 78,
                  color: AppTheme.surfaceLight,
                  child: const Icon(Icons.movie,
                      color: AppTheme.textMuted, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(item.quality,
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                          '${(item.sizeMb / 1024).toStringAsFixed(1)} GB',
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    // Play downloaded file
                  },
                  icon: const Icon(Icons.play_circle_rounded,
                      color: AppTheme.primary, size: 28),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_rounded,
                      color: AppTheme.textMuted, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
