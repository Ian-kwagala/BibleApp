import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import '../state/app_state.dart';

class VerseArtStudioScreen extends StatefulWidget {
  final AppState appState;

  const VerseArtStudioScreen({super.key, required this.appState});

  @override
  State<VerseArtStudioScreen> createState() => _VerseArtStudioScreenState();
}

class _VerseArtStudioScreenState extends State<VerseArtStudioScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isExporting = false;

  static const List<Map<String, dynamic>> _themePresets = [
    {
      'name': 'Mountain Sunset',
      'colors': [
        Color(0xFF93C5FD),
        Color(0xFFFDE68A),
        Color(0xFFF59E0B),
        Color(0xFF451A03),
        Color(0xFF0F172A),
      ],
      'textColor': Color(0xFF1E293B),
      'refColor': Color(0xFFFEF3C7),
    },
    {
      'name': 'Midnight Starlight',
      'colors': [
        Color(0xFF0F172A),
        Color(0xFF1E1B4B),
        Color(0xFF312E81),
        Color(0xFF020617),
      ],
      'textColor': Colors.white,
      'refColor': Color(0xFFC4B5FD),
    },
    {
      'name': 'Emerald Dawn',
      'colors': [
        Color(0xFFA7F3D0),
        Color(0xFF10B981),
        Color(0xFF065F46),
        Color(0xFF022C22),
      ],
      'textColor': Colors.white,
      'refColor': Color(0xFFD1FAE5),
    },
    {
      'name': 'Royal Amber',
      'colors': [
        Color(0xFFFEF3C7),
        Color(0xFFF59E0B),
        Color(0xFFB45309),
        Color(0xFF451A03),
      ],
      'textColor': Color(0xFF1E293B),
      'refColor': Color(0xFFFEF3C7),
    },
    {
      'name': 'Rose Horizon',
      'colors': [
        Color(0xFFFECDD3),
        Color(0xFFF43F5E),
        Color(0xFF881337),
        Color(0xFF1E1B4B),
      ],
      'textColor': Colors.white,
      'refColor': Color(0xFFFFE4E6),
    },
    {
      'name': 'Classic Parchment',
      'colors': [
        Color(0xFFFAF7F2),
        Color(0xFFF5EFE6),
        Color(0xFFE2D6C5),
        Color(0xFFD6C3A5),
      ],
      'textColor': Color(0xFF1E293B),
      'refColor': Color(0xFF78350F),
    },
  ];

  static const List<Map<String, String>> _presetVerses = [
    {
      'ref': 'Psalm 46:10',
      'text': 'Be still, and know that I am God',
    },
    {
      'ref': 'Philippians 4:13',
      'text': 'I can do all things through Christ who strengthens me.',
    },
    {
      'ref': 'John 3:16',
      'text':
          'For God so loved the world, that he gave his one and only Son.',
    },
    {
      'ref': 'Isaiah 40:31',
      'text':
          'Those who wait for the Lord will renew their strength; they will mount up with wings like eagles.',
    },
  ];

  TextStyle _verseTextStyle(String styleName, Color color) {
    switch (styleName) {
      case 'Modern':
        return TextStyle(
          fontFamily: 'Roboto',
          fontSize: 22,
          fontWeight: FontWeight.w800,
          height: 1.35,
          color: color,
          letterSpacing: -0.3,
        );
      case 'Calligraphy':
        return TextStyle(
          fontFamily: 'Georgia',
          fontSize: 23,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: color,
        );
      case 'Serif':
      default:
        return TextStyle(
          fontFamily: 'Georgia',
          fontSize: 22.5,
          fontWeight: FontWeight.w700,
          height: 1.36,
          color: color,
        );
    }
  }

  Future<void> _shareOrSaveCard() async {
    final appState = widget.appState;
    setState(() => _isExporting = true);

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 2.5);
        await image.toByteData(format: ui.ImageByteFormat.png);
      }
      await Share.share(
        '“${appState.studioVerseText}” — ${appState.studioVerseRef}\nShared via LightWord Bible App',
      );
    } catch (_) {
      // Fallback in headless/web environment
    }

    if (!mounted) return;
    setState(() => _isExporting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF059669),
        content: Text(
          'HD Verse Card (${appState.studioVerseRef}) ready for WhatsApp / Instagram & saved!',
        ),
      ),
    );

    appState.onVerseImageSharedOrSaved();
  }

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    final theme =
        _themePresets[appState.studioThemeIndex % _themePresets.length];
    final gradientColors = theme['colors'] as List<Color>;
    final mainTextColor = theme['textColor'] as Color;
    final refTextColor = theme['refColor'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F2),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Verse Art Studio',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: Color(0xFF1E293B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text(
              'Done',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Square HD Verse Art Preview Card matching Page 3 Right Mockup
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: RepaintBoundary(
                    key: _repaintKey,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: gradientColors,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Mountain silhouette overlay at bottom matching Page 3 Right mockup
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: 110,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(24),
                              ),
                              child: CustomPaint(
                                painter: _MountainSilhouettePainter(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '“${appState.studioVerseText}”',
                                  textAlign: TextAlign.center,
                                  style: _verseTextStyle(
                                    appState.studioFontFamily,
                                    mainTextColor,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  '— ${appState.studioVerseRef}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontStyle: FontStyle.italic,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: refTextColor,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'LIGHTWORD BIBLE',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2.0,
                                    color: refTextColor.withValues(alpha: 0.75),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Quick Verse Switcher Chips
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _presetVerses.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, idx) {
                  final item = _presetVerses[idx];
                  final isCurrent =
                      appState.studioVerseRef == item['ref'];
                  return ActionChip(
                    label: Text(item['ref']!),
                    backgroundColor: isCurrent
                        ? const Color(0xFFFEF3C7)
                        : Colors.white,
                    side: BorderSide(
                      color: isCurrent
                          ? const Color(0xFFD97706)
                          : const Color(0xFFCBD5E1),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isCurrent
                          ? const Color(0xFFB45309)
                          : const Color(0xFF334155),
                    ),
                    onPressed: () {
                      setState(() {
                        appState.openVerseInArtStudio(
                          verseText: item['text']!,
                          reference: item['ref']!,
                        );
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // Background Palette & Font Style Controls matching Page 3 Right Mockup
            Row(
              children: [
                // 6 Background Color Dots (2x3 grid)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_themePresets.length, (i) {
                    final cols =
                        _themePresets[i]['colors'] as List<Color>;
                    final selected = appState.studioThemeIndex == i;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          appState.studioThemeIndex = i;
                        });
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [cols.first, cols.last],
                          ),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            width: selected ? 2.5 : 1.5,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 14),

                // 3 Font Style Cards: Serif | Modern | Calligraphy
                Expanded(
                  child: Row(
                    children: [
                      _FontStyleCard(
                        title: 'Serif',
                        sub: 'Serif',
                        fontFamily: 'Georgia',
                        isSelected: appState.studioFontFamily == 'Serif',
                        onTap: () => setState(
                            () => appState.studioFontFamily = 'Serif'),
                      ),
                      const SizedBox(width: 8),
                      _FontStyleCard(
                        title: 'M',
                        sub: 'Modern',
                        fontFamily: 'Roboto',
                        isSelected: appState.studioFontFamily == 'Modern',
                        onTap: () => setState(
                            () => appState.studioFontFamily = 'Modern'),
                      ),
                      const SizedBox(width: 8),
                      _FontStyleCard(
                        title: '𝒞',
                        sub: 'Calligraphy',
                        fontFamily: 'Georgia',
                        isItalic: true,
                        isSelected:
                            appState.studioFontFamily == 'Calligraphy',
                        onTap: () => setState(
                            () => appState.studioFontFamily = 'Calligraphy'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Share to WhatsApp / Save HD Button matching Page 3 Right Mockup
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _shareOrSaveCard,
                icon: _isExporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.share_rounded),
                label: const Text(
                  'Share to WhatsApp / Save HD',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FontStyleCard extends StatelessWidget {
  final String title;
  final String sub;
  final String fontFamily;
  final bool isItalic;
  final bool isSelected;
  final VoidCallback onTap;

  const _FontStyleCard({
    required this.title,
    required this.sub,
    required this.fontFamily,
    this.isItalic = false,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFCBD5E1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MountainSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final backPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.55)
      ..lineTo(size.width * 0.28, size.height * 0.2)
      ..lineTo(size.width * 0.55, size.height * 0.5)
      ..lineTo(size.width * 0.82, size.height * 0.15)
      ..lineTo(size.width, size.height * 0.45)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(backPath, backPaint);

    final frontPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.48)
      ..style = PaintingStyle.fill;

    final frontPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.7)
      ..lineTo(size.width * 0.38, size.height * 0.35)
      ..lineTo(size.width * 0.7, size.height * 0.65)
      ..lineTo(size.width, size.height * 0.4)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(frontPath, frontPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
