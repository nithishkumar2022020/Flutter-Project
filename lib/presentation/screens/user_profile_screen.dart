import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/smooth_page_route.dart';
import '../providers/settings_provider.dart';
import '../widgets/brutalist_container.dart';
import 'clearance_auth_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.nocturneText : AppTheme.parchmentText;
    final mutedText = isDark ? AppTheme.nocturneMutedText : AppTheme.parchmentMutedText;
    final vermilion = isDark ? AppTheme.nocturneVermilion : AppTheme.parchmentVermilion;
    final borderColor = isDark ? AppTheme.nocturneBorder : AppTheme.parchmentBorder;
    final surfaceColor = isDark ? AppTheme.nocturneSurface : AppTheme.parchmentSurface;

    return Consumer<SettingsProvider>(
      builder: (context, settingsProv, _) {
        final name = settingsProv.researcherName;
        final callSign = settingsProv.callSign;
        final clearance = settingsProv.clearanceLevel.toUpperCase();
        final isGuest = settingsProv.isGuest;

        // Extract initials
        final nameParts = name.trim().split(RegExp(r'\s+'));
        final initials = nameParts.length > 1
            ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
            : (name.isNotEmpty ? name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase() : 'NR');

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'FIELD DOSSIER // OPERATOR PROFILE',
              style: AppTheme.monospace(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2),
              child: Container(color: borderColor, height: 2),
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Dossier Card
                BrutalistContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Avatar Badge with Initials
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: vermilion,
                              border: Border.all(color: borderColor, width: 2),
                              boxShadow: [
                                BoxShadow(color: borderColor, offset: const Offset(3, 3), blurRadius: 0),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: AppTheme.monospace(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.toUpperCase(),
                                  style: AppTheme.slabHeader(color: textColor, fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'CALL SIGN: $callSign',
                                  style: AppTheme.monospace(color: mutedText, fontSize: 11),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: (isDark ? AppTheme.nocturneAmber : AppTheme.parchmentAmber).withValues(alpha: 0.2),
                                    border: Border.all(
                                      color: isDark ? AppTheme.nocturneAmber : AppTheme.parchmentAmber,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    isGuest ? 'LEVEL-1 OBSERVER (GUEST)' : clearance,
                                    style: AppTheme.monospace(
                                      color: isDark ? AppTheme.nocturneAmber : AppTheme.parchmentAmber,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Vector Quota Meter
                Text(
                  'VECTOR RETRIEVAL QUOTA METER',
                  style: AppTheme.monospace(color: mutedText, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                BrutalistContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('14,208 / 50,000 Chunks', style: AppTheme.monospace(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('28.4% CONSUMED', style: AppTheme.monospace(color: vermilion, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.zero,
                        child: LinearProgressIndicator(
                          value: 0.284,
                          minHeight: 12,
                          backgroundColor: isDark ? Colors.white12 : Colors.black12,
                          color: vermilion,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Monthly neural embedding and HNSW candidate limit resets in 19 days.',
                        style: AppTheme.readingSerif(color: mutedText, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Active Session Ledger
                Text(
                  'ACTIVE SESSION LEDGER',
                  style: AppTheme.monospace(color: mutedText, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                BrutalistContainer(
                  child: Column(
                    children: [
                      _buildLedgerRow(
                        title: 'ASSIGNED LLM ENDPOINT',
                        value: 'Claude 3.5 Sonnet / Local vLLM',
                        textColor: textColor,
                        mutedText: mutedText,
                        vermilion: vermilion,
                      ),
                      Divider(color: borderColor.withValues(alpha: 0.3), height: 18),
                      _buildLedgerRow(
                        title: 'DENSE EMBEDDING MODEL',
                        value: 'text-embedding-3-large (1536-D)',
                        textColor: textColor,
                        mutedText: mutedText,
                        vermilion: vermilion,
                      ),
                      Divider(color: borderColor.withValues(alpha: 0.3), height: 18),
                      _buildLedgerRow(
                        title: 'SPARSE RETRIEVER',
                        value: 'BM25 + Token Frequency Hash',
                        textColor: textColor,
                        mutedText: mutedText,
                        vermilion: vermilion,
                      ),
                      Divider(color: borderColor.withValues(alpha: 0.3), height: 18),
                      _buildLedgerRow(
                        title: 'CROSS-ENCODER RERANKER',
                        value: 'bge-reranker-v2-m3 (GPU Accelerated)',
                        textColor: textColor,
                        mutedText: mutedText,
                        vermilion: vermilion,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                GestureDetector(
                  key: const Key('profile_export_audit_btn'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Exported signed cryptographic audit log (SHA-256: 9e4f..8b2).',
                          style: AppTheme.monospace(color: Colors.white, fontSize: 12),
                        ),
                        backgroundColor: vermilion,
                      ),
                    );
                  },
                  child: BrutalistContainer(
                    backgroundColor: surfaceColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download_for_offline_outlined, color: textColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'EXPORT AUDIT LOG',
                          style: AppTheme.monospace(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                GestureDetector(
                  key: const Key('profile_revoke_session_btn'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    await settingsProv.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        SmoothPageRoute(page: const ClearanceAuthScreen()),
                        (route) => false,
                      );
                    }
                  },
                  child: BrutalistContainer(
                    backgroundColor: vermilion,
                    borderColor: borderColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'REVOKE SESSION / SIGN OUT',
                          style: AppTheme.monospace(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLedgerRow({
    required String title,
    required String value,
    required Color textColor,
    required Color mutedText,
    required Color vermilion,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTheme.monospace(color: mutedText, fontSize: 10),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTheme.monospace(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
