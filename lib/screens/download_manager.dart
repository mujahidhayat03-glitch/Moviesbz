// lib/screens/download_manager.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/content_model.dart';
import '../theme/app_theme.dart';

class DownloadManager {
  static final Dio _dio = Dio();
  static final Map<String, double> _activeDownloads = {};

  static Future<void> startDownload(BuildContext context, VideoLink link) async {
    // Check storage permission
    final status = await Permission.storage.request();
    if (!status.isGranted && !status.isLimited) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission required for downloads')),
        );
      }
      return;
    }

    // Show progress dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _DownloadProgressDialog(link: link),
      );
    }

    try {
      final dir = await _getDownloadDirectory();
      final fileName = _extractFileName(link.url);
      final filePath = '${dir.path}/$fileName';

      await _dio.download(
        link.url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _activeDownloads[link.url] = received / total;
          }
        },
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
        ),
      );

      _activeDownloads.remove(link.url);

      if (context.mounted) {
        Navigator.pop(context); // Close progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded: $fileName'),
            backgroundColor: AppTheme.success,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () {
                // Open file
              },
            ),
          ),
        );
      }
    } on DioException catch (e) {
      _activeDownloads.remove(link.url);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Download/movies.bz')
        ..createSync(recursive: true);
    } else {
      final docs = await getApplicationDocumentsDirectory();
      return Directory('${docs.path}/movies.bz/downloads')
        ..createSync(recursive: true);
    }
  }

  static String _extractFileName(String url) {
    final uri = Uri.parse(url);
    final segment = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'video';
    if (segment.contains('.')) return segment;
    return '$segment.mp4';
  }
}

class _DownloadProgressDialog extends StatefulWidget {
  final VideoLink link;

  const _DownloadProgressDialog({required this.link});

  @override
  State<_DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<_DownloadProgressDialog> {
  double _progress = 0;
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    _listenProgress();
  }

  void _listenProgress() async {
    while (!_cancelled && _progress < 1.0) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() {
          _progress = DownloadManager._activeDownloads[widget.link.url] ?? _progress;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.download_rounded, color: AppTheme.primary),
          SizedBox(width: 10),
          Text('Downloading', style: TextStyle(color: AppTheme.textPrimary)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.link.label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress > 0 ? _progress : null,
              backgroundColor: AppTheme.divider,
              color: AppTheme.primary,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _progress > 0 ? '${(_progress * 100).toStringAsFixed(0)}%' : 'Connecting...',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() => _cancelled = true);
            DownloadManager._dio.close(force: true);
            Navigator.pop(context);
          },
          child: const Text('Cancel', style: TextStyle(color: AppTheme.primary)),
        ),
      ],
    );
  }
}
