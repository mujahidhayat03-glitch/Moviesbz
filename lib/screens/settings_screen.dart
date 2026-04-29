// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/content_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoplay = true;
  bool _saveWifiOnly = true;
  bool _showSubtitles = false;
  String _defaultQuality = 'HD';
  String _downloadPath = '/Download/movies.bz';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoplay = prefs.getBool('autoplay') ?? true;
      _saveWifiOnly = prefs.getBool('wifi_only') ?? true;
      _showSubtitles = prefs.getBool('subtitles') ?? false;
      _defaultQuality = prefs.getString('default_quality') ?? 'HD';
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
    });
  }

  Future<void> _savePref(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is String) await prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ─── Playback ───
          _SectionHeader(title: 'Playback'),
          _SettingSwitch(
            icon: Icons.play_circle_outline_rounded,
            title: 'Autoplay',
            subtitle: 'Automatically play next episode',
            value: _autoplay,
            onChanged: (v) {
              setState(() => _autoplay = v);
              _savePref('autoplay', v);
            },
          ),
          _SettingSwitch(
            icon: Icons.subtitles_outlined,
            title: 'Subtitles',
            subtitle: 'Show subtitles when available',
            value: _showSubtitles,
            onChanged: (v) {
              setState(() => _showSubtitles = v);
              _savePref('subtitles', v);
            },
          ),
          _SettingSelect<String>(
            icon: Icons.hd_rounded,
            title: 'Default Quality',
            subtitle: 'Preferred streaming quality',
            value: _defaultQuality,
            options: const ['SD', 'HD', '1080p', '4K'],
            onChanged: (v) {
              setState(() => _defaultQuality = v);
              _savePref('default_quality', v);
            },
          ),

          // ─── Downloads ───
          _SectionHeader(title: 'Downloads'),
          _SettingSwitch(
            icon: Icons.wifi_rounded,
            title: 'Wi-Fi Only',
            subtitle: 'Only download on Wi-Fi connection',
            value: _saveWifiOnly,
            onChanged: (v) {
              setState(() => _saveWifiOnly = v);
              _savePref('wifi_only', v);
            },
          ),
          _SettingInfo(
            icon: Icons.folder_rounded,
            title: 'Download Location',
            subtitle: _downloadPath,
            onTap: () {},
          ),
          _SettingAction(
            icon: Icons.delete_sweep_rounded,
            title: 'Clear Downloaded Files',
            subtitle: 'Free up storage space',
            actionColor: AppTheme.primary,
            onTap: () => _showClearDownloadsDialog(context),
          ),

          // ─── Notifications ───
          _SectionHeader(title: 'Notifications'),
          _SettingSwitch(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Get notified about new content',
            value: _notificationsEnabled,
            onChanged: (v) {
              setState(() => _notificationsEnabled = v);
              _savePref('notifications', v);
            },
          ),

          // ─── Data & Privacy ───
          _SectionHeader(title: 'Data & Privacy'),
          _SettingAction(
            icon: Icons.history_rounded,
            title: 'Clear Watch History',
            subtitle: 'Remove all viewing history',
            onTap: () => _showClearHistoryDialog(context),
          ),
          _SettingAction(
            icon: Icons.bookmark_remove_rounded,
            title: 'Clear Watchlist',
            subtitle: 'Remove all saved items',
            onTap: () => _showClearWatchlistDialog(context),
          ),

          // ─── About ───
          _SectionHeader(title: 'About'),
          _SettingInfo(
            icon: Icons.info_outline_rounded,
            title: 'Version',
            subtitle: '1.0.0 (Build 1)',
          ),
          _SettingInfo(
            icon: Icons.movie_rounded,
            title: 'movies.bz',
            subtitle: 'Stream • Download • Enjoy',
          ),
          _SettingAction(
            icon: Icons.policy_outlined,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () {},
          ),
          _SettingAction(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Usage terms and conditions',
            onTap: () {},
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showClearDownloadsDialog(BuildContext context) {
    _showConfirmDialog(
      context,
      title: 'Clear Downloads',
      message: 'This will delete all downloaded files from your device.',
      confirmLabel: 'Clear',
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloads cleared')),
        );
      },
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    _showConfirmDialog(
      context,
      title: 'Clear Watch History',
      message: 'All viewing history will be permanently removed.',
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('History cleared')),
        );
      },
    );
  }

  void _showClearWatchlistDialog(BuildContext context) {
    _showConfirmDialog(
      context,
      title: 'Clear Watchlist',
      message: 'All saved items will be removed from your watchlist.',
      onConfirm: () {
        final provider = context.read<ContentProvider>();
        for (final item in provider.watchlist.toList()) {
          provider.toggleWatchlist(item.id);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Watchlist cleared')),
        );
      },
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        title:
            Text(title, style: const TextStyle(color: AppTheme.textPrimary)),
        content: Text(message,
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(confirmLabel,
                style: const TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─── Switch Setting ───
class _SettingSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.textSecondary, size: 18),
        ),
        title: Text(title,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle,
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primary,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      ),
    );
  }
}

// ─── Select Setting ───
class _SettingSelect<T> extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final T value;
  final List<T> options;
  final ValueChanged<T> onChanged;

  const _SettingSelect({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.textSecondary, size: 18),
        ),
        title: Text(title,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle,
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 12)),
        trailing: DropdownButton<T>(
          value: value,
          dropdownColor: AppTheme.surfaceLight,
          underline: const SizedBox(),
          style: const TextStyle(
              color: AppTheme.textSecondary, fontSize: 13),
          items: options
              .map((o) => DropdownMenuItem(
                    value: o,
                    child: Text(o.toString()),
                  ))
              .toList(),
          onChanged: (v) => onChanged(v as T),
        ),
      ),
    );
  }
}

// ─── Info Setting (read-only) ───
class _SettingInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingInfo({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.textSecondary, size: 18),
        ),
        title: Text(title,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        trailing: Text(subtitle,
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 13)),
      ),
    );
  }
}

// ─── Action Setting (tap to trigger) ───
class _SettingAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? actionColor;

  const _SettingAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.actionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              color: actionColor ?? AppTheme.textSecondary, size: 18),
        ),
        title: Text(title,
            style: TextStyle(
                color: actionColor ?? AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle,
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: AppTheme.textMuted, size: 20),
      ),
    );
  }
}
