import 'package:flutter/material.dart';
import '../state/app_state.dart';

class TermsOnboardingScreen extends StatefulWidget {
  final AppState appState;

  const TermsOnboardingScreen({super.key, required this.appState});

  @override
  State<TermsOnboardingScreen> createState() => _TermsOnboardingScreenState();
}

class _TermsOnboardingScreenState extends State<TermsOnboardingScreen> {
  bool _agreedToTermsAndPrivacy = false;
  bool _confirmedAgeOrGuardian = false;
  String _selectedUmpConsent = 'personalized';

  @override
  Widget build(BuildContext context) {
    final canProceed = _agreedToTermsAndPrivacy && _confirmedAgeOrGuardian;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Brand Icon & Welcome Header
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        width: 84,
                        height: 84,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A8A),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Color(0xFFFDE047),
                            size: 42,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome to LightWord Bible',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Before you begin your offline study journey, please review and accept our Terms & Conditions and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Key Disclosures Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Key App Disclosures & Play Store Summary',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _DisclosureRow(
                          icon: Icons.public_off_rounded,
                          iconColor: Color(0xFF059669),
                          title: '100% Offline-First & Zero Developer Server',
                          description:
                              'Your highlights, study notes, bookmarks, and reading streaks are stored locally on your device. We never collect or sell your personal study data on any developer server.',
                        ),
                        const SizedBox(height: 12),
                        const _DisclosureRow(
                          icon: Icons.add_to_drive_rounded,
                          iconColor: Color(0xFF2563EB),
                          title:
                              'Optional Google Drive Backup (drive.appdata)',
                          description:
                              'If you choose to sign in with Google, your backup (user_bible_sync.json) is stored strictly inside your own hidden Google Drive appDataFolder. You can delete it anytime in-app.',
                        ),
                        const SizedBox(height: 12),
                        const _DisclosureRow(
                          icon: Icons.verified_user_rounded,
                          iconColor: Color(0xFFD97706),
                          title: 'Public Domain Scriptures & Spiritual Use',
                          description:
                              'All included translations (WEB, KJV, BBE, ASV, YLT, Darby, RVR, LSG) are Public Domain. Devotional content is for spiritual encouragement and not medical or legal advice.',
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 12),

                        // Buttons to read full legal texts offline inside the app
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => showLegalDocumentModal(
                                  context,
                                  docType: 'terms',
                                ),
                                icon: const Icon(
                                  Icons.description_outlined,
                                  size: 16,
                                ),
                                label: const Text(
                                  'Read Terms',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1E3A8A),
                                  side: const BorderSide(
                                    color: Color(0xFFCBD5E1),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => showLegalDocumentModal(
                                  context,
                                  docType: 'privacy',
                                ),
                                icon: const Icon(
                                  Icons.privacy_tip_outlined,
                                  size: 16,
                                ),
                                label: const Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1E3A8A),
                                  side: const BorderSide(
                                    color: Color(0xFFCBD5E1),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Google UMP Ad Consent Choice (Required for EU/UK/US Play Store compliance)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF7F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Google AdMob Consent Preference (UMP / GDPR):',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: ChoiceChip(
                                      label: const Text('Personalized Ads'),
                                      selected: _selectedUmpConsent ==
                                          'personalized',
                                      selectedColor: const Color(0xFF1E3A8A),
                                      labelStyle: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: _selectedUmpConsent ==
                                                'personalized'
                                            ? Colors.white
                                            : const Color(0xFF334155),
                                      ),
                                      onSelected: (_) {
                                        setState(() {
                                          _selectedUmpConsent = 'personalized';
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ChoiceChip(
                                      label: const Text('Non-Personalized'),
                                      selected: _selectedUmpConsent ==
                                          'non_personalized',
                                      selectedColor: const Color(0xFF1E3A8A),
                                      labelStyle: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: _selectedUmpConsent ==
                                                'non_personalized'
                                            ? Colors.white
                                            : const Color(0xFF334155),
                                      ),
                                      onSelected: (_) {
                                        setState(() {
                                          _selectedUmpConsent =
                                              'non_personalized';
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Mandatory Checkboxes
                        CheckboxListTile(
                          value: _agreedToTermsAndPrivacy,
                          onChanged: (val) {
                            setState(() {
                              _agreedToTermsAndPrivacy = val ?? false;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: const Color(0xFF1E3A8A),
                          title: const Text(
                            'I have read and agree to the Terms & Conditions and Privacy Policy.',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        CheckboxListTile(
                          value: _confirmedAgeOrGuardian,
                          onChanged: (val) {
                            setState(() {
                              _confirmedAgeOrGuardian = val ?? false;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: const Color(0xFF1E3A8A),
                          title: const Text(
                            'I confirm that I am at least 13 years old (or using this app with parent/guardian permission).',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Primary Agree & Continue Button
                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: canProceed
                          ? () {
                              widget.appState.acceptTermsAndConditions(
                                umpChoice: _selectedUmpConsent,
                              );
                            }
                          : null,
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text(
                        'Agree & Enter LightWord Bible',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: const Color(0xFF0F172A),
                        disabledBackgroundColor: const Color(0xFF334155),
                        disabledForegroundColor: const Color(0xFF94A3B8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DisclosureRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _DisclosureRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.38,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void showLegalDocumentModal(
  BuildContext context, {
  required String docType, // 'terms', 'privacy', or 'copyright'
}) {
  String title;
  List<Map<String, String>> sections;

  if (docType == 'terms') {
    title = 'Terms & Conditions of Use';
    sections = const [
      {
        'h': '1. Acceptance of Terms',
        'p':
            'By installing or using LightWord Bible ("the App"), you agree to these Terms & Conditions. If you do not agree, please discontinue use of the App.'
      },
      {
        'h': '2. Spiritual & Devotional Disclaimer',
        'p':
            'LightWord Bible provides Scripture translations, reading plans, emotion-based verse finders, and trivia quizzes for spiritual encouragement and Bible study. Content in the App is not a substitute for professional medical, mental health, legal, or financial advice.'
      },
      {
        'h': '3. Public Domain Bible Translations',
        'p':
            'All bundled and downloadable Bible translations in the App—World English Bible (WEB), King James Version (KJV), Bible in Basic English (BBE), American Standard Version (ASV 1901), Young\'s Literal Translation (YLT), Darby Translation, Reina-Valera (1909), and French APEE—are in the Public Domain. You may freely read, quote, and share Verse Art cards created in the App.'
      },
      {
        'h': '4. Local Storage & Optional Google Drive Backup',
        'p':
            'Your study notes, highlights, bookmarks, and streaks are saved locally on your device. If you optionally sign in with Google, the App backs up a single configuration file (user_bible_sync.json) inside your personal Google Drive hidden appDataFolder using the restricted drive.appdata scope. We operate zero backend servers and cannot view or recover your personal files.'
      },
      {
        'h': '5. Ad-Supported Service (Google AdMob)',
        'p':
            'To keep LightWord Bible 100% free with \$0 subscription fees, the App displays non-intrusive ads via Google AdMob when online (bottom banner, frequency-capped transition interstitials, and optional rewarded quiz hints). You may change your Personalized vs. Non-Personalized ad consent anytime in the Versions & Backup tab.'
      },
      {
        'h': '6. Limitation of Liability',
        'p':
            'The App is provided "AS IS" without warranties of any kind. To the fullest extent permitted by law, the developer shall not be liable for any damages arising from the use of the App.'
      },
    ];
  } else if (docType == 'privacy') {
    title = 'Privacy Policy & Play Store Data Safety';
    sections = const [
      {
        'h': '1. Zero-Server Architecture (Offline-First)',
        'p':
            'LightWord Bible does not operate any proprietary backend server or central user database. All reading history, daily streaks, highlights, bookmarks, and study notes are stored locally on your device.'
      },
      {
        'h': '2. Google Drive Personal Backup (drive.appdata)',
        'p':
            'When you optionally tap "Sign in with Google", the App requests access strictly to the https://www.googleapis.com/auth/drive.appdata scope. This scope only allows LightWord Bible to read and write its own hidden user_bible_sync.json file (<50 KB) inside your personal Google Drive. The App cannot see or access any other files or photos in your Google Drive.'
      },
      {
        'h': '3. In-App & Web Data Deletion (Play Store Compliance)',
        'p':
            'You can permanently delete both your local study data and your Google Drive hidden backup at any time inside the App by tapping "Delete Cloud & Local Data" in the Versions & Cloud Backup tab, or via Google Drive Settings -> Manage Apps -> LightWord Bible.'
      },
      {
        'h': '4. Google AdMob & UMP Consent (GDPR / CCPA)',
        'p':
            'When online, Google AdMob may use device identifiers (such as the Android Advertising ID declared via com.google.android.gms.permission.AD_ID) to serve ads according to the consent preference (Personalized or Non-Personalized) you select during onboarding or in settings.'
      },
    ];
  } else {
    title = 'Public Domain Bible & Open-Source Licenses';
    sections = const [
      {
        'h': 'World English Bible (WEB)',
        'p':
            'Status: 100% Public Domain (dedicated to the public domain by Rainbow Missions, Inc.). Free for commercial and non-commercial distribution.'
      },
      {
        'h': 'King James Version (KJV 1611/1769)',
        'p':
            'Status: Public Domain worldwide outside UK Crown Letters Patent jurisdiction; bundled for free offline study.'
      },
      {
        'h': 'Bible in Basic English (BBE 1949/1965)',
        'p':
            'Status: Public Domain (Cambridge University Press / Orthological Institute).'
      },
      {
        'h': 'ASV (1901), YLT (1898), Darby (1890), RVR (1909), APEE',
        'p':
            'Status: 100% Public Domain historic translations hosted via GitHub Raw CDN for 1-tap offline download.'
      },
    ];
  }

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.78,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        builder: (_, controller) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: sections.length,
                    itemBuilder: (_, i) {
                      final s = sections[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s['h']!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s['p']!,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.48,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close Document'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
