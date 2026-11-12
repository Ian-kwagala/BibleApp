import 'package:flutter/material.dart';
import '../state/app_state.dart';
import 'verse_art_studio_screen.dart';

class ReaderScreen extends StatefulWidget {
  final AppState appState;

  const ReaderScreen({super.key, required this.appState});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  bool _showComparePanel = true;
  int _compareVerseNum = 16;

  static const List<Map<String, String>> _highlightPalette = [
    {'name': 'Yellow', 'hex': '#FDE68A'},
    {'name': 'Green', 'hex': '#BBF7D0'},
    {'name': 'Blue', 'hex': '#BFDBFE'},
    {'name': 'Pink', 'hex': '#FBCFE8'},
  ];

  Color _parseHex(String hex) {
    final cleaned = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  String _versionDisplayLabel(String code) {
    switch (code) {
      case 'WEB':
        return 'WEB (Modern)';
      case 'KJV':
        return 'KJV (Classic)';
      case 'BBE':
        return 'BBE (Simple)';
      default:
        return code;
    }
  }

  void _openBookChapterPicker(BuildContext context) {
    final appState = widget.appState;
    String tempBook = appState.currentBook;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFAF7F2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final bookInfo = appState.repository.getBookInfo(tempBook);
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              maxChildSize: 0.92,
              minChildSize: 0.5,
              builder: (_, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Book & Chapter',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Row(
                          children: [
                            // Left column: 66 Books
                            Expanded(
                              flex: 3,
                              child: ListView.builder(
                                controller: scrollController,
                                itemCount: appState.repository.books.length,
                                itemBuilder: (_, i) {
                                  final b = appState.repository.books[i];
                                  final selected = b.name == tempBook;
                                  return ListTile(
                                    dense: true,
                                    selected: selected,
                                    selectedTileColor: const Color(0xFFFEF3C7),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    title: Text(
                                      b.name,
                                      style: TextStyle(
                                        fontWeight: selected
                                            ? FontWeight.w800
                                            : FontWeight.w500,
                                        color: selected
                                            ? const Color(0xFFB45309)
                                            : const Color(0xFF1E293B),
                                      ),
                                    ),
                                    trailing: Text(
                                      b.testament,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                    onTap: () {
                                      setModalState(() {
                                        tempBook = b.name;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                            const VerticalDivider(width: 20),
                            // Right column: Chapters Grid
                            Expanded(
                              flex: 2,
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  childAspectRatio: 1.15,
                                ),
                                itemCount: bookInfo.chaptersCount,
                                itemBuilder: (_, cIdx) {
                                  final chNum = cIdx + 1;
                                  final isCurrent =
                                      tempBook == appState.currentBook &&
                                          chNum == appState.currentChapter;
                                  return InkWell(
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      appState.loadChapter(
                                        book: tempBook,
                                        chapter: chNum,
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isCurrent
                                            ? const Color(0xFF1E3A8A)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFFCBD5E1),
                                        ),
                                      ),
                                      child: Text(
                                        '$chNum',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: isCurrent
                                              ? Colors.white
                                              : const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _openSearchModal(BuildContext context) {
    final appState = widget.appState;
    final controller = TextEditingController();
    List<dynamic> results = [];
    bool searching = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFAF7F2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 18,
              ),
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText:
                                  'Search offline Bible (${appState.activeVersion})...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFCBD5E1),
                                ),
                              ),
                            ),
                            onSubmitted: (q) async {
                              setModalState(() => searching = true);
                              final found =
                                  await appState.repository.searchVerses(
                                query: q,
                                versionCode: appState.activeVersion,
                              );
                              setModalState(() {
                                results = found;
                                searching = false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (searching)
                      const Center(child: CircularProgressIndicator())
                    else
                      Expanded(
                        child: results.isEmpty
                            ? const Center(
                                child: Text(
                                  'Type a keyword (e.g., "love", "peace", "shepherd") and press Enter',
                                  style: TextStyle(color: Color(0xFF64748B)),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : ListView.separated(
                                itemCount: results.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (_, idx) {
                                  final item = results[idx];
                                  return ListTile(
                                    title: Text(
                                      '${item.book} ${item.chapter}:${item.verse}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFB45309),
                                        fontSize: 13.5,
                                      ),
                                    ),
                                    subtitle: Text(
                                      item.text as String,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Georgia',
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      appState.loadChapter(
                                        book: item.book as String,
                                        chapter: item.chapter as int,
                                        highlightScrollVerse: item.verse as int,
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openNoteDialog(BuildContext context, int verseNum) {
    final appState = widget.appState;
    final existing = appState.getAnnotation(
      appState.currentBook,
      appState.currentChapter,
      verseNum,
    );
    final controller = TextEditingController(text: existing?.note ?? '');

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            'Study Note • ${appState.currentBook} ${appState.currentChapter}:$verseNum',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          content: TextField(
            controller: controller,
            maxLines: 4,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Write your personal reflection or study note...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            if (existing?.note != null && existing!.note!.isNotEmpty)
              TextButton(
                onPressed: () {
                  appState.saveVerseNote(
                    book: appState.currentBook,
                    chapter: appState.currentChapter,
                    verse: verseNum,
                    noteText: '',
                  );
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'Delete Note',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                appState.saveVerseNote(
                  book: appState.currentBook,
                  chapter: appState.currentChapter,
                  verse: verseNum,
                  noteText: controller.text,
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Note'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    final verses = appState.currentChapterVerses;
    final bookInfo = appState.repository.getBookInfo(appState.currentBook);
    final availableVersions = appState.repository.versions
        .where(
          (v) => appState.repository.downloadedVersions.contains(v.code),
        )
        .toList();

    final compareVerseSafe = verses.isEmpty
        ? 1
        : (appState.selectedVerseNumber ?? _compareVerseNum)
            .clamp(1, verses.length);

    return Column(
      children: [
        // Top Reader Header matching Page 2 Mockup
        Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: const BoxDecoration(
            color: Color(0xFFFAF7F2),
            border: Border(
              bottom: BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
          child: Column(
            children: [
              // Row 1: Prev Chapter | Book & Chapter Title | Search | Next Chapter
              Row(
                children: [
                  IconButton(
                    tooltip: 'Previous Chapter',
                    onPressed: appState.currentChapter > 1
                        ? () => appState.loadChapter(
                              book: appState.currentBook,
                              chapter: appState.currentChapter - 1,
                            )
                        : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                    visualDensity: VisualDensity.compact,
                  ),
                  Expanded(
                    child: Center(
                      child: InkWell(
                        onTap: () => _openBookChapterPicker(context),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${appState.currentBook} ${appState.currentChapter}',
                                style: const TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: Color(0xFF475569),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Search Bible Offline',
                    onPressed: () => _openSearchModal(context),
                    icon: const Icon(Icons.search_rounded, size: 21),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    tooltip: 'Next Chapter',
                    onPressed: appState.currentChapter < bookInfo.chaptersCount
                        ? () => appState.loadChapter(
                              book: appState.currentBook,
                              chapter: appState.currentChapter + 1,
                            )
                        : null,
                    icon: const Icon(Icons.chevron_right_rounded),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Row 2: Version Switcher Pill | Compare Versions Pill | Offline Audio Button
              Row(
                children: [
                  // Version Switcher Dropdown Pill
                  Expanded(
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: availableVersions.any(
                                  (v) => v.code == appState.activeVersion)
                              ? appState.activeVersion
                              : 'WEB',
                          isExpanded: true,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                          items: availableVersions
                              .map(
                                (v) => DropdownMenuItem<String>(
                                  value: v.code,
                                  child: Text(_versionDisplayLabel(v.code)),
                                ),
                              )
                              .toList(),
                          onChanged: (nextCode) {
                            if (nextCode != null) {
                              appState.loadChapter(
                                book: appState.currentBook,
                                chapter: appState.currentChapter,
                                version: nextCode,
                                countForAd: false,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Compare Versions Pill Button
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showComparePanel = !_showComparePanel;
                      });
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _showComparePanel
                            ? const Color(0xFF1E3A8A)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _showComparePanel
                              ? const Color(0xFF1E3A8A)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Text(
                        'Compare Versions',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _showComparePanel
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Offline TTS Speaker Toggle Button
                  InkWell(
                    onTap: () {
                      appState.ttsService.togglePlayPause(
                        book: appState.currentBook,
                        chapter: appState.currentChapter,
                        verses: verses,
                      );
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: appState.ttsService.isPlaying
                            ? const Color(0xFFD97706)
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Icon(
                        appState.ttsService.isPlaying
                            ? Icons.graphic_eq_rounded
                            : Icons.volume_up_rounded,
                        size: 18,
                        color: appState.ttsService.isPlaying
                            ? Colors.white
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Main Scripture Reader Body
        Expanded(
          child: appState.isLoadingChapter
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
                      itemCount: verses.length,
                      itemBuilder: (context, index) {
                        final verseNum = index + 1;
                        final verseText = verses[index];
                        final ann = appState.getAnnotation(
                          appState.currentBook,
                          appState.currentChapter,
                          verseNum,
                        );
                        final isSelected =
                            appState.selectedVerseNumber == verseNum;
                        final isTtsActive = appState.ttsService.isPlaying &&
                            appState.ttsService.activeVerseIndex == index;

                        Color? highlightBg;
                        if (ann?.colorHex != null) {
                          highlightBg = _parseHex(ann!.colorHex!);
                        } else if (isTtsActive) {
                          highlightBg = const Color(0xFFFEF3C7);
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                appState.selectVerse(verseNum);
                                setState(() {
                                  _compareVerseNum = verseNum;
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: highlightBg ?? Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: isSelected || isTtsActive
                                      ? Border.all(
                                          color: const Color(0xFFD97706),
                                          width: 1.4,
                                        )
                                      : null,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '$verseNum ',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFFB45309),
                                        ),
                                      ),
                                      TextSpan(
                                        text: verseText,
                                        style: const TextStyle(
                                          fontFamily: 'Georgia',
                                          fontSize: 16,
                                          height: 1.52,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      if (ann?.isBookmarked == true)
                                        const WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 6),
                                            child: Icon(
                                              Icons.bookmark_rounded,
                                              size: 15,
                                              color: Color(0xFFD97706),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Inline Study Note Box matching Page 2 Mockup (under John 3:16)
                            if (ann?.note != null &&
                                ann!.note!.trim().isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(
                                  left: 14,
                                  right: 6,
                                  top: 4,
                                  bottom: 6,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.edit_note_rounded,
                                      size: 17,
                                      color: Color(0xFFB45309),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Note: ${ann.note}',
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF334155),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () =>
                                          _openNoteDialog(context, verseNum),
                                      child: const Icon(
                                        Icons.edit_outlined,
                                        size: 15,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Inline Verse Action Bar when verse is tapped
                            if (isSelected)
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 4,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    // 4 Color highlight circles
                                    ..._highlightPalette.map((item) {
                                      final hex = item['hex']!;
                                      final col = _parseHex(hex);
                                      final isCurrentCol =
                                          ann?.colorHex == hex;
                                      return GestureDetector(
                                        onTap: () {
                                          appState.setVerseHighlightColor(
                                            book: appState.currentBook,
                                            chapter: appState.currentChapter,
                                            verse: verseNum,
                                            colorHex: isCurrentCol ? null : hex,
                                          );
                                        },
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: col,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isCurrentCol
                                                  ? Colors.white
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                          ),
                                          child: isCurrentCol
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 14,
                                                  color: Color(0xFF1E293B),
                                                )
                                              : null,
                                        ),
                                      );
                                    }),
                                    const SizedBox(width: 4),
                                    _VerseActionChip(
                                      icon: Icons.edit_note_rounded,
                                      label: 'Note',
                                      onTap: () =>
                                          _openNoteDialog(context, verseNum),
                                    ),
                                    _VerseActionChip(
                                      icon: Icons.compare_arrows_rounded,
                                      label: 'Compare',
                                      onTap: () {
                                        setState(() {
                                          _compareVerseNum = verseNum;
                                          _showComparePanel = true;
                                        });
                                      },
                                    ),
                                    _VerseActionChip(
                                      icon: Icons.palette_outlined,
                                      label: 'Verse Art',
                                      onTap: () {
                                        appState.openVerseInArtStudio(
                                          verseText: verseText,
                                          reference:
                                              '${appState.currentBook} ${appState.currentChapter}:$verseNum',
                                        );
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                VerseArtStudioScreen(
                                              appState: appState,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    _VerseActionChip(
                                      icon: ann?.isBookmarked == true
                                          ? Icons.bookmark_rounded
                                          : Icons.bookmark_border_rounded,
                                      label: 'Save',
                                      onTap: () {
                                        appState.toggleVerseBookmark(
                                          book: appState.currentBook,
                                          chapter: appState.currentChapter,
                                          verse: verseNum,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 4),
                          ],
                        );
                      },
                    ),

                    // Floating Offline Audio Bar matching Page 2 Mockup
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Reading ${appState.currentBook} ${appState.currentChapter}:${appState.ttsService.activeVerseIndex + 1} • Offline Voice • ${appState.ttsService.playbackRate}x',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  tooltip: 'Previous Verse',
                                  onPressed: () =>
                                      appState.ttsService.skipPrevious(),
                                  icon: const Icon(Icons.replay_10_rounded),
                                  visualDensity: VisualDensity.compact,
                                ),
                                const SizedBox(width: 12),
                                InkWell(
                                  onTap: () {
                                    appState.ttsService.togglePlayPause(
                                      book: appState.currentBook,
                                      chapter: appState.currentChapter,
                                      verses: verses,
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(999),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1E293B),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      appState.ttsService.isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  tooltip: 'Next Verse',
                                  onPressed: () =>
                                      appState.ttsService.skipNext(),
                                  icon: const Icon(Icons.forward_10_rounded),
                                  visualDensity: VisualDensity.compact,
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () =>
                                      appState.ttsService.cycleSpeed(),
                                  style: OutlinedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                  ),
                                  child: Text(
                                    '${appState.ttsService.playbackRate}x',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),

        // Side-by-Side Version Compare Docked Panel matching Page 2 Mockup
        if (_showComparePanel)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              border: const Border(
                top: BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Version Compare: ${appState.currentBook} ${appState.currentChapter}:$compareVerseSafe',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _showComparePanel = false),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FutureBuilder<Map<String, String>>(
                  future: appState.repository.compareVerseAcrossVersions(
                    bookName: appState.currentBook,
                    chapterNumber: appState.currentChapter,
                    verseNumber: compareVerseSafe,
                  ),
                  builder: (context, snapshot) {
                    final data = snapshot.data ?? {};
                    final cols = [
                      {
                        'code': 'KJV',
                        'sub': 'King James\nVersion',
                        'text': data['KJV'] ?? 'Loading...'
                      },
                      {
                        'code': 'WEB',
                        'sub': 'World English\nBible',
                        'text': data['WEB'] ?? 'Loading...'
                      },
                      {
                        'code': 'BBE',
                        'sub': 'Bible in Basic\nEnglish',
                        'text': data['BBE'] ?? 'Loading...'
                      },
                    ];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: cols.map((col) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF7F2),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  col['code']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                Text(
                                  col['sub']!,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    color: Color(0xFF64748B),
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  col['text']!,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    height: 1.3,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _VerseActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _VerseActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
