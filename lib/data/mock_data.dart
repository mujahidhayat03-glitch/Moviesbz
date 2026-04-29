// lib/data/mock_data.dart
import '../models/content_model.dart';

class MockData {
  static final List<ContentItem> allContent = [
    // ─────────────── MOVIES ───────────────
    ContentItem(
      id: 'm001',
      title: 'Oppenheimer',
      description:
          'The story of J. Robert Oppenheimer and his role in the development of the atomic bomb during World War II. A visually stunning and intellectually gripping epic that explores the moral complexities of scientific discovery.',
      posterUrl: 'https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/original/rLb2cwF3Pazuxaj0sRXQ037tGI1.jpg',
      category: ContentCategory.movies,
      genres: ['Biography', 'Drama', 'History'],
      releaseYear: 2023,
      rating: 8.9,
      durationMinutes: 180,
      language: 'English',
      isFeatured: true,
      isTrending: true,
      watchLinks: [
        VideoLink(url: 'https://example.com/watch/oppenheimer-1080p', quality: Quality.fullHD, label: '1080p'),
        VideoLink(url: 'https://example.com/watch/oppenheimer-720p', quality: Quality.hd, label: '720p'),
      ],
      downloadLinks: [
        VideoLink(url: 'https://example.com/dl/oppenheimer-1080p', quality: Quality.fullHD, label: '1080p • 4.2GB', isDownload: true),
        VideoLink(url: 'https://example.com/dl/oppenheimer-720p', quality: Quality.hd, label: '720p • 1.8GB', isDownload: true),
      ],
      addedAt: DateTime(2024, 1, 15),
    ),
    ContentItem(
      id: 'm002',
      title: 'Dune: Part Two',
      description:
          'Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators who destroyed his family. A breathtaking continuation of the sci-fi saga.',
      posterUrl: 'https://image.tmdb.org/t/p/w500/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/original/xOMo8BRK7PfcJv9JCnx7s5hj0PX.jpg',
      category: ContentCategory.movies,
      genres: ['Sci-Fi', 'Adventure', 'Drama'],
      releaseYear: 2024,
      rating: 8.5,
      durationMinutes: 166,
      language: 'English',
      isFeatured: true,
      isNew: true,
      watchLinks: [
        VideoLink(url: 'https://example.com/watch/dune2-4k', quality: Quality.uhd4K, label: '4K HDR'),
        VideoLink(url: 'https://example.com/watch/dune2-1080p', quality: Quality.fullHD, label: '1080p'),
      ],
      downloadLinks: [
        VideoLink(url: 'https://example.com/dl/dune2-1080p', quality: Quality.fullHD, label: '1080p • 5.1GB', isDownload: true),
      ],
      addedAt: DateTime(2024, 3, 1),
    ),
    ContentItem(
      id: 'm003',
      title: 'Joker: Folie à Deux',
      description:
          'Arthur Fleck is incarcerated at Arkham while awaiting trial for his crimes as Joker. He finds love with a woman named Harley Quinn as he struggles to reconcile with his alter ego.',
      posterUrl: 'https://image.tmdb.org/t/p/w500/eEslKSwcqmiNS6va24Pbou7kZEs.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/original/lktCmIReDW2X8qMMbsZsZkPqAHR.jpg',
      category: ContentCategory.movies,
      genres: ['Crime', 'Drama', 'Music'],
      releaseYear: 2024,
      rating: 5.4,
      durationMinutes: 138,
      language: 'English',
      isNew: true,
      watchLinks: [
        VideoLink(url: 'https://example.com/watch/joker2-1080p', quality: Quality.fullHD, label: '1080p'),
      ],
      downloadLinks: [
        VideoLink(url: 'https://example.com/dl/joker2-720p', quality: Quality.hd, label: '720p • 2.1GB', isDownload: true),
      ],
      addedAt: DateTime(2024, 10, 4),
    ),
    ContentItem(
      id: 'm004',
      title: 'The Batman',
      description:
          'When a sadistic serial killer begins murdering key political figures in Gotham, Batman is forced to investigate the city\'s hidden corruption and question his family\'s involvement.',
      posterUrl: 'https://image.tmdb.org/t/p/w500/74xTEgt7R36Fpooo50r9T25onhq.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/original/5P8SmMzSNYikXpxil6BYzJ16611.jpg',
      category: ContentCategory.movies,
      genres: ['Action', 'Crime', 'Drama'],
      releaseYear: 2022,
      rating: 7.8,
      durationMinutes: 176,
      language: 'English',
      isTrending: true,
      watchLinks: [
        VideoLink(url: 'https://example.com/watch/batman-1080p', quality: Quality.fullHD, label: '1080p'),
        VideoLink(url: 'https://example.com/watch/batman-hd', quality: Quality.hd, label: '720p'),
      ],
      downloadLinks: [
        VideoLink(url: 'https://example.com/dl/batman-1080p', quality: Quality.fullHD, label: '1080p • 3.8GB', isDownload: true),
        VideoLink(url: 'https://example.com/dl/batman-720p', quality: Quality.hd, label: '720p • 1.5GB', isDownload: true),
      ],
      addedAt: DateTime(2023, 6, 10),
    ),
    ContentItem(
      id: 'm005',
      title: 'Interstellar',
      description:
          'A team of explorers travel through a wormhole in space in an attempt to ensure humanity\'s survival in this Christopher Nolan sci-fi masterpiece.',
      posterUrl: 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/original/xJHokMbljvjADYdit5fK5VQsXEG.jpg',
      category: ContentCategory.movies,
      genres: ['Sci-Fi', 'Drama', 'Adventure'],
      releaseYear: 2014,
      rating: 8.7,
      durationMinutes: 169,
      language: 'English',
      isTrending: true,
      watchLinks: [
        VideoLink(url: 'https://example.com/watch/interstellar-4k', quality: Quality.uhd4K, label: '4K UHD'),
        VideoLink(url: 'https://example.com/watch/interstellar-1080p', quality: Quality.fullHD, label: '1080p'),
      ],
      downloadLinks: [
        VideoLink(url: 'https://example.com/dl/interstellar-1080p', quality: Quality.fullHD, label: '1080p • 4.5GB', isDownload: true),
      ],
      addedAt: DateTime(2023, 1, 5),
    ),

    // ─────────────── WEB SERIES ───────────────
    ContentItem(
      id: 'ws001',
      title: 'House of the Dragon',
      description:
          'An internal succession war within House Targaryen at the height of its power, 172 years before the birth of Daenerys Targaryen. Dragons fly, allegiances shift, and the Iron Throne beckons.',
      posterUrl: 'https://image.tmdb.org/t/p/w500/z2yahl2uefxDCl0nogcRBstwruJ.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/original/suopoADq0k8YZr4dQXcU6szRFZp.jpg',
      category: ContentCategory.webSeries,
      genres: ['Fantasy', 'Drama', 'Action'],
      releaseYear: 2022,
      rating: 8.4,
      language: 'English',
      isFeatured: true,
      isTrending: true,
      watchLinks: [],
      downloadLinks: [],
      seasons: [
        Season(
          seasonNumber: 1,
          title: 'Season 1',
          episodes: List.generate(
            10,
            (i) => Episode(
              id: 'ws001_s1e${i + 1}',
              episodeNumber: i + 1,
              title: [
                'The Heirs of the Dragon',
                'The Rogue Prince',
                'Second of His Name',
                'King of the Narrow Sea',
                'We Light the Way',
                'The Princess and the Queen',
                'Driftmark',
                'The Lord of the Tides',
                'The Green Council',
                'The Black Queen',
              ][i],
              durationMinutes: 55 + (i % 3) * 5,
              watchLinks: [
                VideoLink(url: 'https://example.com/hotd/s1e${i + 1}/1080p', quality: Quality.fullHD, label: '1080p'),
              ],
              downloadLinks: [
                VideoLink(url: 'https://example.com/dl/hotd/s1e${i + 1}', quality: Quality.hd, label: '720p • 800MB', isDownload: true),
              ],
            ),
          ),
        ),
        Season(
          seasonNumber: 2,
          title: 'Season 2',
          episodes: List.generate(
            8,
            (i) => Episode(
              id: 'ws001_s2e${i + 1}',
              episodeNumber: i + 1,
              title: 'A Son for a Son',
              durationMinutes: 60,
              watchLinks: [
                VideoLink(url: 'https://example.com/hotd/s2e${i + 1}/1080p', quality: Quality.fullHD, label: '1080p'),
              ],
              downloadLinks: [
                VideoLink(url: 'https://example.com/dl/hotd/s2e${i + 1}', quality: Quality.hd, label: '720p • 850MB', isDownload: true),
              ],
            ),
          ),
        ),
      ],
      addedAt: DateTime(2024, 2, 20),
    ),
    ContentItem(
      id: 'ws002',
      title: 'The Last of Us',
      description:
          'Joel and Ellie must survive in a post-apocalyptic America overrun by a fungal infection. An emotional journey about love, loss, and what it means to be human.',
      posterUrl: 'https://image.tmdb.org/t/p/w500/uKvVjHNqB5VmOrdxqAt2F7J78ED.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/original/uDgy6hyPd7qkoDd0OwKhM17IFsL.jpg',
      category: ContentCategory.webSeries,
      genres: ['Drama', 'Horror', 'Thriller'],
      releaseYear: 2023,
      rating: 8.8,
      language: 'English',
      isTrending: true,
      isNew: true,
      watchLinks: [],
      downloadLinks: [],
      seasons: [
        Season(
          seasonNumber: 1,
          episodes: List.generate(9, (i) => Episode(
            id: 'ws002_s1e${i+1}',
            episodeNumber: i + 1,
            title: 'Episode ${i + 1}',
            durationMinutes: 50,
            watchLinks: [VideoLink(url: 'https://example.com/tlou/s1e${i+1}', quality: Quality.fullHD, label: '1080p')],
            downloadLinks: [VideoLink(url: 'https://example.com/dl/tlou/s1e${i+1}', quality: Quality.hd, label: '720p • 750MB', isDownload: true)],
          )),
        ),
      ],
      addedAt: DateTime(2024, 1, 10),
    ),
    ContentItem(
      id: 'ws003',
      title: 'Squid Game',
      description:
          'Hundreds of cash-strapped players accept a strange invitation to compete in children\'s games. Inside, a tempting prize awaits — with deadly high stakes.',
      posterUrl: 'https://image.tmdb.org/t/p/w500/dDlEmu3EZ0Pgg93K2SVNLCjCSvE.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/original/qw3J9cNeLioOLoR68WX7z79aCdK.jpg',
      category: ContentCategory.webSeries,
      genres: ['Drama', 'Thriller', 'Action'],
      releaseYear: 2021,
      rating: 8.0,
      language: 'Korean',
      isTrending: true,
      watchLinks: [],
      downloadLinks: [],
      seasons: [
        Season(
          seasonNumber: 1,
          episodes: List.generate(9, (i) => Episode(
            id: 'ws003_s1e${i+1}',
            episodeNumber: i + 1,
            title: 'Episode ${i + 1}',
            durationMinutes: 55,
            watchLinks: [VideoLink(url: 'https://example.com/squid/s1e${i+1}', quality: Quality.fullHD, label: '1080p')],
            downloadLinks: [VideoLink(url: 'https://example.com/dl/squid/s1e${i+1}', quality: Quality.hd, label: '720p • 700MB', isDownload: true)],
          )),
        ),
      ],
      addedAt: DateTime(2023, 8, 5),
    ),

    // ─────────────── COMEDY SHOWS ───────────────
    ContentItem(
      id: 'cs001',
      title: 'Fifty Fifty',
      description:
          'A hilarious Pakistani comedy show featuring Umer Sharif, Zeba Shehnaz, and Shakeel Siddiqui in uproarious sketches and situational comedy that became a cultural phenomenon.',
      posterUrl: 'https://picsum.photos/seed/comedy1/400/600',
      backdropUrl: 'https://picsum.photos/seed/comedy1bg/1280/720',
      category: ContentCategory.comedyShows,
      genres: ['Comedy', 'Sketch', 'Variety'],
      releaseYear: 1992,
      rating: 9.2,
      language: 'Urdu',
      country: 'Pakistan',
      isFeatured: true,
      watchLinks: [],
      downloadLinks: [],
      seasons: List.generate(
        3,
        (s) => Season(
          seasonNumber: s + 1,
          episodes: List.generate(13, (i) => Episode(
            id: 'cs001_s${s+1}e${i+1}',
            episodeNumber: i + 1,
            title: 'Episode ${i + 1}',
            durationMinutes: 45,
            watchLinks: [VideoLink(url: 'https://example.com/fiftyfifty/s${s+1}e${i+1}', quality: Quality.sd, label: 'Watch')],
            downloadLinks: [VideoLink(url: 'https://example.com/dl/fiftyfifty/s${s+1}e${i+1}', quality: Quality.sd, label: '480p • 300MB', isDownload: true)],
          )),
        ),
      ),
      addedAt: DateTime(2023, 5, 1),
    ),
    ContentItem(
      id: 'cs002',
      title: 'The Office (US)',
      description:
          'A mockumentary on a group of typical office workers, where the workday consists of ego clashes, inappropriate behavior, and tedium.',
      posterUrl: 'https://image.tmdb.org/t/p/w500/qWnJzyZhyy74gjpSjIXWmuk0ifX.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/original/6zDPuuEiTXJhBFJwVWRlXs0uIq1.jpg',
      category: ContentCategory.comedyShows,
      genres: ['Comedy', 'Mockumentary'],
      releaseYear: 2005,
      rating: 9.0,
      language: 'English',
      isTrending: true,
      watchLinks: [],
      downloadLinks: [],
      seasons: List.generate(9, (s) => Season(
        seasonNumber: s + 1,
        episodes: List.generate(s == 0 ? 6 : 22, (i) => Episode(
          id: 'cs002_s${s+1}e${i+1}',
          episodeNumber: i + 1,
          title: 'Episode ${i + 1}',
          durationMinutes: 22,
          watchLinks: [VideoLink(url: 'https://example.com/office/s${s+1}e${i+1}', quality: Quality.hd, label: '720p')],
          downloadLinks: [VideoLink(url: 'https://example.com/dl/office/s${s+1}e${i+1}', quality: Quality.hd, label: '720p • 200MB', isDownload: true)],
        )),
      )),
      addedAt: DateTime(2023, 3, 15),
    ),

    // ─────────────── PAKISTANI DRAMAS ───────────────
    ContentItem(
      id: 'pd001',
      title: 'Humsafar',
      description:
          'A classic Pakistani drama about the tumultuous love story between Ashar and Khirad. Misunderstandings, betrayal, and undying love make this one of the most beloved dramas in Pakistani television history.',
      posterUrl: 'https://picsum.photos/seed/drama1/400/600',
      backdropUrl: 'https://picsum.photos/seed/drama1bg/1280/720',
      category: ContentCategory.pakistaniDramas,
      genres: ['Romance', 'Drama', 'Family'],
      releaseYear: 2011,
      rating: 9.1,
      language: 'Urdu',
      country: 'Pakistan',
      isFeatured: true,
      isTrending: true,
      watchLinks: [],
      downloadLinks: [],
      seasons: [
        Season(
          seasonNumber: 1,
          episodes: List.generate(23, (i) => Episode(
            id: 'pd001_e${i+1}',
            episodeNumber: i + 1,
            title: 'Episode ${i + 1}',
            durationMinutes: 45,
            watchLinks: [VideoLink(url: 'https://example.com/humsafar/e${i+1}', quality: Quality.hd, label: 'HD')],
            downloadLinks: [VideoLink(url: 'https://example.com/dl/humsafar/e${i+1}', quality: Quality.hd, label: '720p • 400MB', isDownload: true)],
          )),
        ),
      ],
      addedAt: DateTime(2023, 4, 10),
    ),
    ContentItem(
      id: 'pd002',
      title: 'Meray Qatil Meray Dildar',
      description:
          'A gripping Pakistani drama exploring love, crime, and justice. A woman discovers a dark secret about the man she loves, leading to a thrilling and emotional journey.',
      posterUrl: 'https://picsum.photos/seed/drama2/400/600',
      backdropUrl: 'https://picsum.photos/seed/drama2bg/1280/720',
      category: ContentCategory.pakistaniDramas,
      genres: ['Drama', 'Thriller', 'Romance'],
      releaseYear: 2024,
      rating: 8.3,
      language: 'Urdu',
      country: 'Pakistan',
      isNew: true,
      isTrending: true,
      watchLinks: [],
      downloadLinks: [],
      seasons: [
        Season(
          seasonNumber: 1,
          episodes: List.generate(28, (i) => Episode(
            id: 'pd002_e${i+1}',
            episodeNumber: i + 1,
            title: 'Episode ${i + 1}',
            durationMinutes: 42,
            watchLinks: [VideoLink(url: 'https://example.com/merayqatil/e${i+1}', quality: Quality.hd, label: 'HD')],
            downloadLinks: [VideoLink(url: 'https://example.com/dl/merayqatil/e${i+1}', quality: Quality.hd, label: '720p • 380MB', isDownload: true)],
          )),
        ),
      ],
      addedAt: DateTime(2024, 3, 5),
    ),
    ContentItem(
      id: 'pd003',
      title: 'Tere Bin',
      description:
          'A passionate love story between Murtasim and Meerab — two strong personalities who clash and eventually fall deeply in love, navigating family, tradition, and personal growth.',
      posterUrl: 'https://picsum.photos/seed/drama3/400/600',
      backdropUrl: 'https://picsum.photos/seed/drama3bg/1280/720',
      category: ContentCategory.pakistaniDramas,
      genres: ['Romance', 'Drama'],
      releaseYear: 2023,
      rating: 8.7,
      language: 'Urdu',
      country: 'Pakistan',
      isFeatured: true,
      watchLinks: [],
      downloadLinks: [],
      seasons: [
        Season(
          seasonNumber: 1,
          episodes: List.generate(52, (i) => Episode(
            id: 'pd003_e${i+1}',
            episodeNumber: i + 1,
            title: 'Episode ${i + 1}',
            durationMinutes: 44,
            watchLinks: [VideoLink(url: 'https://example.com/terebin/e${i+1}', quality: Quality.hd, label: 'HD')],
            downloadLinks: [VideoLink(url: 'https://example.com/dl/terebin/e${i+1}', quality: Quality.hd, label: '720p • 400MB', isDownload: true)],
          )),
        ),
      ],
      addedAt: DateTime(2023, 9, 20),
    ),
  ];

  static List<ContentItem> byCategory(ContentCategory category) =>
      allContent.where((c) => c.category == category).toList();

  static List<ContentItem> get featured =>
      allContent.where((c) => c.isFeatured).toList();

  static List<ContentItem> get trending =>
      allContent.where((c) => c.isTrending).toList();

  static List<ContentItem> get recentlyAdded {
    final sorted = List<ContentItem>.from(allContent)
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return sorted.take(10).toList();
  }

  static List<ContentItem> search(String query) {
    final q = query.toLowerCase();
    return allContent.where((c) =>
        c.title.toLowerCase().contains(q) ||
        c.description.toLowerCase().contains(q) ||
        c.genres.any((g) => g.toLowerCase().contains(q))).toList();
  }
}
