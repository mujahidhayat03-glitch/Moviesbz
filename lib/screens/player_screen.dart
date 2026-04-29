// lib/screens/player_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/content_model.dart';
import '../theme/app_theme.dart';

class PlayerScreen extends StatefulWidget {
  final String title;
  final List<VideoLink> watchLinks;

  const PlayerScreen({
    super.key,
    required this.title,
    required this.watchLinks,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  int _selectedQualityIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Force landscape for video playback
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    _initializePlayer(widget.watchLinks[_selectedQualityIndex]);
  }

  Future<void> _initializePlayer(VideoLink link) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _chewieController?.dispose();
      await _videoController?.dispose();

      _videoController = VideoPlayerController.networkUrl(Uri.parse(link.url));
      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowPlaybackSpeedChanging: true,
        playbackSpeeds: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
        materialProgressColors: ChewieProgressColors(
          playedColor: AppTheme.primary,
          handleColor: AppTheme.primary,
          backgroundColor: AppTheme.divider,
          bufferedColor: AppTheme.textMuted,
        ),
        placeholder: Container(color: Colors.black),
        autoInitialize: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white60, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Unable to play video\n$errorMessage',
                  style: const TextStyle(color: Colors.white60),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load video: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        actions: [
          if (widget.watchLinks.length > 1)
            PopupMenuButton<int>(
              color: AppTheme.surfaceLight,
              onSelected: (i) {
                setState(() => _selectedQualityIndex = i);
                _initializePlayer(widget.watchLinks[i]);
              },
              itemBuilder: (_) => widget.watchLinks.asMap().entries.map((e) =>
                PopupMenuItem(
                  value: e.key,
                  child: Row(
                    children: [
                      if (e.key == _selectedQualityIndex)
                        const Icon(Icons.check_rounded, size: 16, color: AppTheme.primary),
                      SizedBox(width: e.key == _selectedQualityIndex ? 8 : 24),
                      Text(e.value.label),
                    ],
                  ),
                ),
              ).toList(),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.hd_rounded, color: Colors.white70, size: 20),
                    SizedBox(width: 4),
                    Text('Quality', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primary),
                  SizedBox(height: 16),
                  Text('Loading video...', style: TextStyle(color: Colors.white54)),
                ],
              )
            : _errorMessage != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.white38, size: 56),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.white54),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _initializePlayer(widget.watchLinks[_selectedQualityIndex]),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  )
                : _chewieController != null
                    ? Chewie(controller: _chewieController!)
                    : const SizedBox(),
      ),
    );
  }
}
