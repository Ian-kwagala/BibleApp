import 'package:flutter/material.dart';
import '../state/app_state.dart';

class VersionsBackupScreen extends StatelessWidget {
  final AppState appState;
  final bool showProfileFocus;

  const VersionsBackupScreen({
    super.key,
    required this.appState,
    this.showProfileFocus = false,
  });

  void _confirmDeleteAllData(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            'Delete Cloud & Local Data?',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'This will permanently delete your user_bible_sync.json backup inside your Google Drive hidden appDataFolder as well as all local highlights, notes, bookmarks, and streak history on this device.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await appState.deleteAllCloudAndLocalData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'All Google Drive appDataFolder & local study data deleted.',
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Everything'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final annotationsList = appState.annotations.values.toList()
      ..sort((a, b) => b.updatedAtMs.compareTo(a.updatedAtMs));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Title Row matching Page 4 Mockup
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Versions & Cloud Backup',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              // Online / Offline Simulator Switch for testing Blueprint Offline rules
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: appState.isPhoneOnline
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: InkWell(
                  onTap: () =>
                      appState.toggleOnlineMode(!appState.isPhoneOnline),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        appState.isPhoneOnline
                            ? Icons.wifi_rounded
                            : Icons.wifi_off_rounded,
                        size: 15,
                        color: appState.isPhoneOnline
                            ? const Color(0xFF15803D)
                            : const Color(0xFFB91C1C),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        appState.isPhoneOnline ? 'Online' : 'Offline Mode',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: appState.isPhoneOnline
                              ? const Color(0xFF15803D)
                              : const Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Google Account Backup Card matching Page 4 Mockup + Blueprint v2.0 Fix #3
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Google Account Backup',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    TextButton(
                      onPressed: () => appState.toggleGoogleSignIn(),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        appState.isSignedInWithGoogle
                            ? 'Switch Account'
                            : 'Sign in with Google',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_to_drive_rounded,
                        color: Color(0xFF2563EB),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.isSignedInWithGoogle
                                ? 'Signed in with Google (${appState.googleUserEmail})'
                                : 'Not signed in (Local storage only)',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Synced to your personal Google Drive hidden folder (drive.appdata • CRDT Merge Active)',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF16A34A),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Last backup: ${appState.lastBackupLabel}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: appState.isSyncingDrive ||
                              !appState.isPhoneOnline ||
                              !appState.isSignedInWithGoogle
                          ? null
                          : () => appState.syncNowWithGoogleDrive(),
                      icon: appState.isSyncingDrive
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync_rounded, size: 16),
                      label: Text(
                        appState.isSyncingDrive ? 'Syncing...' : 'Sync Now',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Bible Versions Library Card matching Page 4 Mockup
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bible Versions Library (100% Free & Offline)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Public Domain translations • Per-book indexed for instant offline reading',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),
                ...appState.repository.versions.map((ver) {
                  final isDownloaded = appState.repository.downloadedVersions
                      .contains(ver.code);
                  final progress = appState.downloadProgress[ver.code];
                  final isActive = appState.activeVersion == ver.code;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFFEF3C7).withValues(alpha: 0.45)
                            : const Color(0xFFFAF7F2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFFD97706)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${ver.name} (${ver.code})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD97706),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'Active',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ver.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (progress != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LinearProgressIndicator(value: progress),
                                const SizedBox(height: 4),
                                Text(
                                  'Downloading offline pack (${(progress * 100).round()}%)...',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF2563EB),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          else if (isDownloaded)
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF16A34A),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Saved Offline (${ver.sizeMb} MB)',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                if (!isActive)
                                  TextButton(
                                    onPressed: () {
                                      appState.loadChapter(
                                        book: appState.currentBook,
                                        chapter: appState.currentChapter,
                                        version: ver.code,
                                        countForAd: false,
                                      );
                                      appState.setTabIndex(1);
                                    },
                                    child: const Text(
                                      'Open in Reader →',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          else
                            InkWell(
                              onTap: () =>
                                  appState.downloadBibleVersion(ver.code),
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.download_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Download Offline (${ver.sizeMb} MB)',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Saved Highlights, Notes & Bookmarks Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved Highlights, Bookmarks & Study Notes (${annotationsList.length})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 10),
                if (annotationsList.isEmpty)
                  const Text(
                    'No saved highlights or study notes yet. Tap any verse in the Bible Reader to highlight or add a note.',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                  )
                else
                  ...annotationsList.map((ann) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: Icon(
                        ann.isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.format_color_fill_rounded,
                        color: const Color(0xFFD97706),
                      ),
                      title: Text(
                        '${ann.book} ${ann.chapter}:${ann.verse}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      subtitle: ann.note != null && ann.note!.isNotEmpty
                          ? Text('Note: ${ann.note}')
                          : const Text('Highlighted / Bookmarked Verse'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        appState.loadChapter(
                          book: ann.book,
                          chapter: ann.chapter,
                          highlightScrollVerse: ann.verse,
                        );
                        appState.setTabIndex(1);
                      },
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Play Store Data Safety & UMP Consent Section (Blueprint v2.0 Fix #7)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Privacy, Google UMP Consent & Data Safety',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Manage your Google AdMob UMP consent preferences (GDPR/CCPA) or permanently delete your cloud & local data.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'AdMob UMP Consent Mode:',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    DropdownButton<String>(
                      value: appState.umpConsentStatus,
                      isDense: true,
                      items: const [
                        DropdownMenuItem(
                          value: 'personalized',
                          child: Text('Personalized Ads'),
                        ),
                        DropdownMenuItem(
                          value: 'non_personalized',
                          child: Text('Non-Personalized (GDPR)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          appState.updateUmpConsent(val);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDeleteAllData(context),
                    icon: const Icon(
                      Icons.delete_forever_rounded,
                      color: Color(0xFFDC2626),
                    ),
                    label: const Text(
                      'Delete Cloud & Local Data (Play Store Compliance)',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
