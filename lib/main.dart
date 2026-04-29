// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/content_provider.dart';
import 'models/content_model.dart';
import 'screens/home_screen.dart';
import 'screens/category_screen.dart';
import 'screens/search_screen.dart';
import 'screens/watchlist_screen.dart';
import 'screens/downloads_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase Initialize
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ContentProvider()..initialize(),
      child: const MoviesBzApp(),
    ),
  );
}

class MoviesBzApp extends StatelessWidget {
  const MoviesBzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'movies.bz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/splash',
      routes: {
        '/splash':    (_) => const SplashScreen(),
        '/main':      (_) => const MainShell(),
        '/search':    (_) => const SearchScreen(),
        '/watchlist': (_) => const WatchlistScreen(),
        '/downloads': (_) => const DownloadsScreen(),
        '/settings':  (_) => const SettingsScreen(),
        '/admin':     (_) => const AdminScreen(),
      },
    );
  }
}

// ─────────────────────────────────────────────
//  Main Shell
// ─────────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  int _logoTapCount = 0;
  DateTime? _firstLogoTap;

  static const _tabs = [
    _NavConfig(icon: Icons.home_rounded,                       label: 'Home'),
    _NavConfig(icon: Icons.movie_rounded,                      label: 'Movies'),
    _NavConfig(icon: Icons.tv_rounded,                         label: 'Series'),
    _NavConfig(icon: Icons.sentiment_very_satisfied_rounded,   label: 'Comedy'),
    _NavConfig(icon: Icons.favorite_rounded,                   label: 'Dramas'),
  ];

  static const _pages = <Widget>[
    HomeScreen(),
    CategoryScreen(category: ContentCategory.movies),
    CategoryScreen(category: ContentCategory.webSeries),
    CategoryScreen(category: ContentCategory.comedyShows),
    CategoryScreen(category: ContentCategory.pakistaniDramas),
  ];

  void _handleTap(int i) {
    if (i == 0) {
      // Secret: tap Home 7× fast to open admin
      final now = DateTime.now();
      if (_firstLogoTap == null ||
          now.difference(_firstLogoTap!) > const Duration(seconds: 3)) {
        _firstLogoTap = now;
        _logoTapCount = 1;
      } else {
        _logoTapCount++;
        if (_logoTapCount >= 7) {
          _logoTapCount = 0;
          Navigator.pushNamed(context, '/admin');
          return;
        }
      }
    }
    setState(() => _currentIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    final watchlistCount = context.watch<ContentProvider>().watchlist.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: _AppDrawer(watchlistCount: watchlistCount),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        tabs: _tabs,
        onTap: _handleTap,
      ),
    );
  }
}

// ─── Bottom Navigation Bar ───
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavConfig> tabs;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(top: BorderSide(color: AppTheme.divider, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 58,
          child: Row(
            children: tabs.asMap().entries.map((e) {
              final i = e.key;
              final tab = e.value;
              final selected = currentIndex == i;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  splashColor: AppTheme.primary.withOpacity(0.1),
                  highlightColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.primary.withOpacity(0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          tab.icon,
                          color: selected ? AppTheme.primary : AppTheme.textMuted,
                          size: 21,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        tab.label,
                        style: TextStyle(
                          color: selected ? AppTheme.primary : AppTheme.textMuted,
                          fontSize: 9.5,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Side Drawer ───
class _AppDrawer extends StatelessWidget {
  final int watchlistCount;

  const _AppDrawer({required this.watchlistCount});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Brand header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.movie_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'movies',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                        TextSpan(
                          text: '.bz',
                          style: TextStyle(color: AppTheme.primary, fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppTheme.divider, height: 1),
            const SizedBox(height: 6),

            // My Library
            _drawerSection('MY LIBRARY'),
            _DrawerItem(
              icon: Icons.bookmark_rounded,
              label: 'Watchlist',
              badge: watchlistCount > 0 ? watchlistCount.toString() : null,
              onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/watchlist'); },
            ),
            _DrawerItem(
              icon: Icons.download_for_offline_rounded,
              label: 'Downloads',
              onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/downloads'); },
            ),
            _DrawerItem(
              icon: Icons.search_rounded,
              label: 'Search',
              onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/search'); },
            ),

            _drawerSection('CATEGORIES'),
            _DrawerItem(icon: Icons.movie_rounded,                    label: 'Movies',            color: AppTheme.categoryColors['movies'],      onTap: () => Navigator.pop(context)),
            _DrawerItem(icon: Icons.tv_rounded,                       label: 'Web Series',        color: AppTheme.categoryColors['web_series'],  onTap: () => Navigator.pop(context)),
            _DrawerItem(icon: Icons.sentiment_very_satisfied_rounded, label: 'Comedy Shows',      color: AppTheme.categoryColors['comedy'],      onTap: () => Navigator.pop(context)),
            _DrawerItem(icon: Icons.favorite_rounded,                 label: 'Pakistani Dramas',  color: AppTheme.categoryColors['dramas'],      onTap: () => Navigator.pop(context)),

            const Spacer(),
            const Divider(color: AppTheme.divider, height: 1),
            _DrawerItem(
              icon: Icons.settings_rounded,
              label: 'Settings',
              onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/settings'); },
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _drawerSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      horizontalTitleGap: 8,
      leading: Icon(icon, color: color ?? AppTheme.textSecondary, size: 20),
      title: Text(label,
          style: const TextStyle(
              color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
              child: Text(badge!,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            )
          : null,
      onTap: onTap,
    );
  }
}

class _NavConfig {
  final IconData icon;
  final String label;

  const _NavConfig({required this.icon, required this.label});
}
