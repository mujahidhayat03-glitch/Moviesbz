// lib/models/content_model.dart

enum ContentCategory {
  movies,
  webSeries,
  comedyShows,
  pakistaniDramas,
}

extension ContentCategoryExtension on ContentCategory {
  String get displayName {
    switch (this) {
      case ContentCategory.movies:
        return 'Movies';
      case ContentCategory.webSeries:
        return 'Web Series';
      case ContentCategory.comedyShows:
        return 'Comedy Shows';
      case ContentCategory.pakistaniDramas:
        return 'Pakistani Dramas';
    }
  }

  String get id {
    switch (this) {
      case ContentCategory.movies:
        return 'movies';
      case ContentCategory.webSeries:
        return 'web_series';
      case ContentCategory.comedyShows:
        return 'comedy';
      case ContentCategory.pakistaniDramas:
        return 'dramas';
    }
  }
}

enum Quality { sd, hd, fullHD, uhd4K }

extension QualityExtension on Quality {
  String get label {
    switch (this) {
      case Quality.sd:
        return 'SD';
      case Quality.hd:
        return 'HD';
      case Quality.fullHD:
        return '1080p';
      case Quality.uhd4K:
        return '4K';
    }
  }
}

class VideoLink {
  final String url;
  final Quality quality;
  final String label;
  final bool isDownload;

  const VideoLink({
    required this.url,
    required this.quality,
    required this.label,
    this.isDownload = false,
  });

  factory VideoLink.fromJson(Map<String, dynamic> json) {
    return VideoLink(
      url: json['url'] as String,
      quality: Quality.values.firstWhere(
        (q) => q.name == json['quality'],
        orElse: () => Quality.hd,
      ),
      label: json['label'] as String,
      isDownload: json['isDownload'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'quality': quality.name,
        'label': label,
        'isDownload': isDownload,
      };
}

class Episode {
  final String id;
  final int episodeNumber;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final int? durationMinutes;
  final List<VideoLink> watchLinks;
  final List<VideoLink> downloadLinks;

  const Episode({
    required this.id,
    required this.episodeNumber,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.durationMinutes,
    required this.watchLinks,
    required this.downloadLinks,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] as String,
      episodeNumber: json['episodeNumber'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      durationMinutes: json['durationMinutes'] as int?,
      watchLinks: (json['watchLinks'] as List<dynamic>?)
              ?.map((e) => VideoLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      downloadLinks: (json['downloadLinks'] as List<dynamic>?)
              ?.map((e) => VideoLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Season {
  final int seasonNumber;
  final String? title;
  final List<Episode> episodes;

  const Season({
    required this.seasonNumber,
    this.title,
    required this.episodes,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      seasonNumber: json['seasonNumber'] as int,
      title: json['title'] as String?,
      episodes: (json['episodes'] as List<dynamic>)
          .map((e) => Episode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ContentItem {
  final String id;
  final String title;
  final String? originalTitle;
  final String description;
  final String posterUrl;
  final String? backdropUrl;
  final String? trailerUrl;
  final ContentCategory category;
  final List<String> genres;
  final int? releaseYear;
  final double rating;
  final int? durationMinutes;
  final String? language;
  final String? country;
  final bool isFeatured;
  final bool isTrending;
  final bool isNew;
  final List<VideoLink> watchLinks;
  final List<VideoLink> downloadLinks;
  final List<Season> seasons; // For series
  final DateTime addedAt;

  const ContentItem({
    required this.id,
    required this.title,
    this.originalTitle,
    required this.description,
    required this.posterUrl,
    this.backdropUrl,
    this.trailerUrl,
    required this.category,
    required this.genres,
    this.releaseYear,
    required this.rating,
    this.durationMinutes,
    this.language,
    this.country,
    this.isFeatured = false,
    this.isTrending = false,
    this.isNew = false,
    required this.watchLinks,
    required this.downloadLinks,
    this.seasons = const [],
    required this.addedAt,
  });

  bool get isSerial =>
      category == ContentCategory.webSeries ||
      category == ContentCategory.pakistaniDramas ||
      category == ContentCategory.comedyShows;

  String get formattedDuration {
    if (durationMinutes == null) return '';
    final h = durationMinutes! ~/ 60;
    final m = durationMinutes! % 60;
    if (h == 0) return '${m}m';
    return '${h}h ${m}m';
  }

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] as String,
      title: json['title'] as String,
      originalTitle: json['originalTitle'] as String?,
      description: json['description'] as String,
      posterUrl: json['posterUrl'] as String,
      backdropUrl: json['backdropUrl'] as String?,
      trailerUrl: json['trailerUrl'] as String?,
      category: ContentCategory.values.firstWhere(
        (c) => c.id == json['category'],
        orElse: () => ContentCategory.movies,
      ),
      genres: List<String>.from(json['genres'] as List),
      releaseYear: json['releaseYear'] as int?,
      rating: (json['rating'] as num).toDouble(),
      durationMinutes: json['durationMinutes'] as int?,
      language: json['language'] as String?,
      country: json['country'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isTrending: json['isTrending'] as bool? ?? false,
      isNew: json['isNew'] as bool? ?? false,
      watchLinks: (json['watchLinks'] as List<dynamic>?)
              ?.map((e) => VideoLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      downloadLinks: (json['downloadLinks'] as List<dynamic>?)
              ?.map((e) => VideoLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      seasons: (json['seasons'] as List<dynamic>?)
              ?.map((e) => Season.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'originalTitle': originalTitle,
        'description': description,
        'posterUrl': posterUrl,
        'backdropUrl': backdropUrl,
        'trailerUrl': trailerUrl,
        'category': category.id,
        'genres': genres,
        'releaseYear': releaseYear,
        'rating': rating,
        'durationMinutes': durationMinutes,
        'language': language,
        'country': country,
        'isFeatured': isFeatured,
        'isTrending': isTrending,
        'isNew': isNew,
        'watchLinks': watchLinks.map((l) => l.toJson()).toList(),
        'downloadLinks': downloadLinks.map((l) => l.toJson()).toList(),
        'addedAt': addedAt.toIso8601String(),
      };

  ContentItem copyWith({
    String? title,
    String? description,
    String? posterUrl,
    String? backdropUrl,
    ContentCategory? category,
    List<String>? genres,
    int? releaseYear,
    double? rating,
    int? durationMinutes,
    bool? isFeatured,
    bool? isTrending,
    bool? isNew,
    List<VideoLink>? watchLinks,
    List<VideoLink>? downloadLinks,
    List<Season>? seasons,
  }) {
    return ContentItem(
      id: id,
      title: title ?? this.title,
      originalTitle: originalTitle,
      description: description ?? this.description,
      posterUrl: posterUrl ?? this.posterUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      category: category ?? this.category,
      genres: genres ?? this.genres,
      releaseYear: releaseYear ?? this.releaseYear,
      rating: rating ?? this.rating,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isFeatured: isFeatured ?? this.isFeatured,
      isTrending: isTrending ?? this.isTrending,
      isNew: isNew ?? this.isNew,
      watchLinks: watchLinks ?? this.watchLinks,
      downloadLinks: downloadLinks ?? this.downloadLinks,
      seasons: seasons ?? this.seasons,
      addedAt: addedAt,
    );
  }
}
