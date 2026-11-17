import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/reader_screen.dart';
import 'screens/terms_onboarding_screen.dart';
import 'screens/verse_art_studio_screen.dart';
import 'screens/versions_backup_screen.dart';
import 'state/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LightWordBibleApp());
}

class LightWordBibleApp extends StatefulWidget {
  const LightWordBibleApp({super.key});

  @override
  State<LightWordBibleApp> createState() => _LightWordBibleAppState();
}

class _LightWordBibleAppState extends State<LightWordBibleApp> {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _appState.initialize();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'LightWord Bible',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFFAF7F2),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFB45309),
              primary: const Color(0xFF1E3A8A),
              secondary: const Color(0xFFD97706),
              surface: const Color(0xFFFAF7F2),
            ),
          ),
          home: _appState.isInitialized
              ? (_appState.hasAcceptedTerms
                  ? MainShellScreen(appState: _appState)
                  : TermsOnboardingScreen(appState: _appState))
              : Scaffold(
                  backgroundColor: const Color(0xFF0F172A),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/icon/app_icon.png',
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'LightWord Bible',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Loading Offline Multi-Version Library...',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const CircularProgressIndicator(
                          color: Color(0xFFF59E0B),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class MainShellScreen extends StatelessWidget {
  final AppState appState;

  const MainShellScreen({super.key, required this.appState});

  Widget _buildActiveTab() {
    switch (appState.currentTabIndex) {
      case 0:
        return HomeScreen(appState: appState);
      case 1:
        return ReaderScreen(appState: appState);
      case 2:
        return QuizScreen(appState: appState);
      case 3:
        return VersionsBackupScreen(appState: appState);
      case 4:
        return VerseArtStudioScreen(appState: appState);
      default:
        return HomeScreen(appState: appState);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appState.currentTabIndex == 2
          ? const Color(0xFF0F172A)
          : const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: _buildActiveTab(),
              ),
            ),

            // Controlled Full-Screen Interstitial Ad Overlay (Section 5 of Blueprint + Fix #6)
            if (appState.isShowingInterstitialOverlay && appState.isPhoneOnline)
              Container(
                color: Colors.black.withValues(alpha: 0.88),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'AdMob Interstitial • Policy Safe',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => appState.dismissInterstitialAd(),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Icon(
                          Icons.auto_stories_rounded,
                          size: 48,
                          color: Color(0xFF1E3A8A),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Sponsored: Daily Devotional Journal',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Triggered by rule: ${appState.interstitialTriggerReason ?? "Controlled Transition"} (15s dwell-time & 4-min cooldown verified).',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => appState.dismissInterstitialAd(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Continue to LightWord Bible'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 5-Tab Bottom Navigation Bar matching the Blueprint Mockups
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: appState.currentTabIndex,
              onTap: (idx) => appState.setTabIndex(idx),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFFD97706),
              unselectedItemColor: const Color(0xFF64748B),
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book_rounded),
                  label: 'Read',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.lightbulb_outline_rounded),
                  label: 'Quiz',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.cloud_done_outlined),
                  label: 'Versions',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.palette_outlined),
                  label: 'Art Studio',
                ),
              ],
            ),
          ),

          // Bottom AdMob Banner Strip (Section 5 of Blueprint):
          // Fixed strip at the very bottom when online; automatically collapses to 0 height when offline!
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            child: appState.isPhoneOnline
                ? Container(
                    width: double.infinity,
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    color: const Color(0xFF1E293B),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'Ad',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Flexible(
                          child: Text(
                            'Sponsored: Grow your faith daily • LightWord AdMob Banner (Collapses to 0px Offline)',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
