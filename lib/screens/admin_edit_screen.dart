// lib/screens/admin_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/content_provider.dart';
import '../models/content_model.dart';
import '../theme/app_theme.dart';

class AdminEditScreen extends StatefulWidget {
  final ContentItem? item; // null = new item
  final VoidCallback? onSaved; // callback after save

  const AdminEditScreen({super.key, this.item, this.onSaved});

  @override
  State<AdminEditScreen> createState() => _AdminEditScreenState();
}

class _AdminEditScreenState extends State<AdminEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool get _isEditing => widget.item != null;

  // Controllers
  late final TextEditingController _titleCtrl;
  late final TextEditingController _origTitleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _posterCtrl;
  late final TextEditingController _backdropCtrl;
  late final TextEditingController _genresCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _ratingCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _languageCtrl;
  late final TextEditingController _countryCtrl;

  late ContentCategory _category;
  late bool _isFeatured;
  late bool _isTrending;
  late bool _isNew;

  // Video links
  final List<_LinkEntry> _watchLinks = [];
  final List<_LinkEntry> _downloadLinks = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    _titleCtrl = TextEditingController(text: item?.title ?? '');
    _origTitleCtrl = TextEditingController(text: item?.originalTitle ?? '');
    _descCtrl = TextEditingController(text: item?.description ?? '');
    _posterCtrl = TextEditingController(text: item?.posterUrl ?? '');
    _backdropCtrl = TextEditingController(text: item?.backdropUrl ?? '');
    _genresCtrl =
        TextEditingController(text: item?.genres.join(', ') ?? '');
    _yearCtrl =
        TextEditingController(text: item?.releaseYear?.toString() ?? '');
    _ratingCtrl =
        TextEditingController(text: item?.rating.toString() ?? '7.0');
    _durationCtrl =
        TextEditingController(text: item?.durationMinutes?.toString() ?? '');
    _languageCtrl =
        TextEditingController(text: item?.language ?? '');
    _countryCtrl =
        TextEditingController(text: item?.country ?? '');

    _category = item?.category ?? ContentCategory.movies;
    _isFeatured = item?.isFeatured ?? false;
    _isTrending = item?.isTrending ?? false;
    _isNew = item?.isNew ?? false;

    // Pre-fill links
    for (final l in item?.watchLinks ?? []) {
      _watchLinks.add(_LinkEntry(url: l.url, quality: l.quality, label: l.label));
    }
    for (final l in item?.downloadLinks ?? []) {
      _downloadLinks.add(_LinkEntry(url: l.url, quality: l.quality, label: l.label));
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _origTitleCtrl.dispose();
    _descCtrl.dispose();
    _posterCtrl.dispose();
    _backdropCtrl.dispose();
    _genresCtrl.dispose();
    _yearCtrl.dispose();
    _ratingCtrl.dispose();
    _durationCtrl.dispose();
    _languageCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Content' : 'Add New Content',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveContent,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.primary),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ─── Poster Preview ───
            if (_posterCtrl.text.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    _posterCtrl.text,
                    height: 140,
                    width: 94,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // ─── Basic Info ───
            _sectionTitle('Basic Information'),
            _field('Title *', _titleCtrl,
                validator: (v) => v!.isEmpty ? 'Title is required' : null),
            _field('Original Title (optional)', _origTitleCtrl),
            _field('Description *', _descCtrl,
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Description is required' : null),

            // ─── Media ───
            _sectionTitle('Images'),
            _field('Poster URL *', _posterCtrl,
                hint: 'https://...',
                onChanged: (_) => setState(() {}),
                validator: (v) => v!.isEmpty ? 'Poster URL is required' : null),
            _field('Backdrop URL (optional)', _backdropCtrl,
                hint: 'https://...'),

            // ─── Category & Meta ───
            _sectionTitle('Category & Details'),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: DropdownButtonFormField<ContentCategory>(
                value: _category,
                dropdownColor: AppTheme.surfaceLight,
                decoration: _inputDecoration('Category'),
                items: ContentCategory.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.displayName),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
            ),
            _field('Genres *', _genresCtrl,
                hint: 'Drama, Romance, Thriller',
                validator: (v) => v!.isEmpty ? 'At least one genre required' : null),
            Row(children: [
              Expanded(child: _field('Release Year', _yearCtrl, keyboard: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: _field('Rating (0–10)', _ratingCtrl, keyboard: const TextInputType.numberWithOptions(decimal: true))),
            ]),
            Row(children: [
              Expanded(child: _field('Duration (min)', _durationCtrl, keyboard: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: _field('Language', _languageCtrl, hint: 'e.g. Urdu')),
            ]),
            _field('Country', _countryCtrl, hint: 'e.g. Pakistan'),

            // ─── Flags ───
            _sectionTitle('Display Flags'),
            _toggle('Featured on Home', _isFeatured,
                (v) => setState(() => _isFeatured = v)),
            _toggle('Show in Trending', _isTrending,
                (v) => setState(() => _isTrending = v)),
            _toggle('Mark as New', _isNew,
                (v) => setState(() => _isNew = v)),

            // ─── Watch Links ───
            _sectionTitle('Watch Links'),
            ..._watchLinks.asMap().entries.map((e) =>
                _LinkRow(
                  entry: e.value,
                  index: e.key,
                  isDownload: false,
                  onRemove: () => setState(() => _watchLinks.removeAt(e.key)),
                )),
            _addLinkButton('Add Watch Link', () {
              setState(() => _watchLinks.add(_LinkEntry()));
            }),

            // ─── Download Links ───
            _sectionTitle('Download Links'),
            ..._downloadLinks.asMap().entries.map((e) =>
                _LinkRow(
                  entry: e.value,
                  index: e.key,
                  isDownload: true,
                  onRemove: () => setState(() => _downloadLinks.removeAt(e.key)),
                )),
            _addLinkButton('Add Download Link', () {
              setState(() => _downloadLinks.add(_LinkEntry()));
            }),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveContent,
                icon: const Icon(Icons.save_rounded),
                label: Text(_isEditing ? 'Update Content' : 'Save Content'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
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

  Widget _field(
    String label,
    TextEditingController ctrl, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboard,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboard,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        onChanged: onChanged,
        validator: validator,
        decoration: _inputDecoration(label, hint: hint),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
      hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SwitchListTile(
        title: Text(label,
            style:
                const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primary,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      ),
    );
  }

  Widget _addLinkButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.divider),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, color: AppTheme.primary, size: 18),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Future<void> _saveContent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final genres = _genresCtrl.text
        .split(',')
        .map((g) => g.trim())
        .where((g) => g.isNotEmpty)
        .toList();

    final watchLinks = _watchLinks
        .where((e) => e.urlCtrl.text.isNotEmpty)
        .map((e) => VideoLink(
              url: e.urlCtrl.text.trim(),
              quality: e.quality,
              label: e.labelCtrl.text.isNotEmpty
                  ? e.labelCtrl.text.trim()
                  : e.quality.label,
            ))
        .toList();

    final downloadLinks = _downloadLinks
        .where((e) => e.urlCtrl.text.isNotEmpty)
        .map((e) => VideoLink(
              url: e.urlCtrl.text.trim(),
              quality: e.quality,
              label: e.labelCtrl.text.isNotEmpty
                  ? e.labelCtrl.text.trim()
                  : '${e.quality.label} Download',
              isDownload: true,
            ))
        .toList();

    final item = ContentItem(
      id: widget.item?.id ?? 'c_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      originalTitle: _origTitleCtrl.text.trim().isEmpty
          ? null
          : _origTitleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      posterUrl: _posterCtrl.text.trim(),
      backdropUrl: _backdropCtrl.text.trim().isEmpty
          ? null
          : _backdropCtrl.text.trim(),
      category: _category,
      genres: genres,
      releaseYear: int.tryParse(_yearCtrl.text),
      rating: double.tryParse(_ratingCtrl.text) ?? 7.0,
      durationMinutes: int.tryParse(_durationCtrl.text),
      language: _languageCtrl.text.trim().isEmpty
          ? null
          : _languageCtrl.text.trim(),
      country: _countryCtrl.text.trim().isEmpty
          ? null
          : _countryCtrl.text.trim(),
      isFeatured: _isFeatured,
      isTrending: _isTrending,
      isNew: _isNew,
      watchLinks: watchLinks,
      downloadLinks: downloadLinks,
      seasons: widget.item?.seasons ?? [],
      addedAt: widget.item?.addedAt ?? DateTime.now(),
    );

    if (!mounted) return;

    try {
      await context.read<ContentProvider>().upsertContent(item);
      setState(() => _isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(_isEditing
                ? '"${item.title}" Firestore mein update ho gaya!'
                : '"${item.title}" Firestore mein add ho gaya!')),
          ]),
          backgroundColor: AppTheme.success,
        ),
      );
      widget.onSaved?.call();
      if (widget.item != null) Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

// ─── Link Entry Model ───
class _LinkEntry {
  final TextEditingController urlCtrl;
  final TextEditingController labelCtrl;
  Quality quality;

  _LinkEntry({String url = '', String label = '', Quality? quality})
      : urlCtrl = TextEditingController(text: url),
        labelCtrl = TextEditingController(text: label),
        quality = quality ?? Quality.hd;
}

// ─── Link Row Widget ───
class _LinkRow extends StatefulWidget {
  final _LinkEntry entry;
  final int index;
  final bool isDownload;
  final VoidCallback onRemove;

  const _LinkRow({
    required this.entry,
    required this.index,
    required this.isDownload,
    required this.onRemove,
  });

  @override
  State<_LinkRow> createState() => _LinkRowState();
}

class _LinkRowState extends State<_LinkRow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: (widget.isDownload
                          ? AppTheme.accent
                          : AppTheme.primary)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '${widget.index + 1}',
                    style: TextStyle(
                      color: widget.isDownload
                          ? AppTheme.accent
                          : AppTheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<Quality>(
                  value: widget.entry.quality,
                  dropdownColor: AppTheme.surfaceLight,
                  underline: const SizedBox(),
                  isDense: true,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                  items: Quality.values
                      .map((q) => DropdownMenuItem(
                            value: q,
                            child: Text(q.label),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => widget.entry.quality = v!),
                ),
              ),
              IconButton(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.close_rounded,
                    color: AppTheme.textMuted, size: 18),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.entry.urlCtrl,
            style:
                const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: widget.isDownload
                  ? 'Download URL (direct link)'
                  : 'Stream URL',
              hintStyle: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 8),
              isDense: true,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: widget.entry.labelCtrl,
            style:
                const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText:
                  widget.isDownload ? 'e.g. 1080p • 2.3GB' : 'e.g. 1080p HD',
              hintStyle: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 8),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}
