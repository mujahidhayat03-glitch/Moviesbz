# 🎬 movies.bz — Flutter App

A sleek, dark-themed entertainment streaming app for Movies, Web Series, Comedy Shows, and Pakistani Dramas.

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry + bottom navigation shell
├── theme/
│   └── app_theme.dart           # Dark cinematic theme, brand colors
├── models/
│   └── content_model.dart       # ContentItem, Episode, Season, VideoLink models
├── data/
│   ├── mock_data.dart           # Sample content (replace with real API later)
│   └── content_provider.dart   # ChangeNotifier state management
├── screens/
│   ├── home_screen.dart         # Home: featured banner + section rows
│   ├── category_screen.dart     # Category grid with genre filters & sort
│   ├── detail_screen.dart       # Full detail: info + episodes + watch/download
│   ├── player_screen.dart       # Chewie video player with quality selector
│   ├── download_manager.dart    # Dio download with progress dialog
│   ├── search_screen.dart       # Live search with results grid
│   └── admin_screen.dart        # Admin panel (dashboard + content CRUD)
└── widgets/
    └── content_card.dart        # Poster card, landscape card, section header, badges
```

---

## 🚀 Setup

### 1. Prerequisites
```bash
flutter --version  # Requires Flutter 3.x+
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Run on device
```bash
flutter run
```

### 4. Build APK (Android)
```bash
flutter build apk --release
```

---

## 🔑 Features

### ✅ Steps 1 & 2 — Implemented
- **Bottom navigation** with 5 tabs: Home, Movies, Web Series, Comedy, Dramas
- **Featured banner** with auto-scrolling PageView
- **Trending, Recently Added** horizontal scroll rows
- **Category grids** using `flutter_staggered_grid_view`
- **Detail screen** with episode list, backdrop hero, expandable description
- **Chewie video player** with quality selection
- **Download manager** via Dio with progress dialog
- **Watchlist** via SharedPreferences
- **Live search**

### ✅ Step 3 — Admin Panel
- Access: tap the Home nav tab **7 times rapidly**
- Dashboard with content stats
- Content list per category with edit/delete
- Add content form with watch & download link entry

### 🔜 Step 4 — AI Link Discovery
- Admin panel has placeholder for AI-powered link discovery
- Requires OpenAI integration (next phase)
- Will auto-suggest valid watch/download URLs from title search

### 🔜 Step 5 — Backend
- Currently uses local mock data + SharedPreferences
- Easy to swap `MockData.allContent` with Firebase Firestore / REST API

---

## 📱 Navigation

| Tab | Route | Description |
|-----|-------|-------------|
| Home | `/` | Featured, Trending, All categories |
| Movies | - | Movie grid with filters |
| Web Series | - | Series grid with episode support |
| Comedy | - | Comedy show grid |
| Dramas | - | Pakistani drama grid |
| Admin | `/admin` | Hidden (7x tap Home) |

---

## 🛠️ Adding Real Content

Replace `lib/data/mock_data.dart` with:
```dart
// Option A: JSON file
final data = json.decode(await rootBundle.loadString('assets/content.json'));

// Option B: REST API
final res = await dio.get('https://your-api.com/content');

// Option C: Firebase Firestore
final snap = await FirebaseFirestore.instance.collection('content').get();
```

---

## 📦 Key Dependencies

| Package | Use |
|---------|-----|
| `provider` | State management |
| `cached_network_image` | Image caching |
| `chewie` + `video_player` | Video playback |
| `dio` | Downloads + HTTP |
| `flutter_staggered_grid_view` | Masonry grids |
| `shimmer` | Loading placeholders |
| `shared_preferences` | Watchlist persistence |
| `google_fonts` | Inter font |
| `flutter_rating_bar` | Star ratings |
| `permission_handler` | Storage permissions |
