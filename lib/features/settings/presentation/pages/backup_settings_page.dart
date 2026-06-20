import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';

class BackupSettingsPage extends StatelessWidget {
  const BackupSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Backup & Export',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Google Drive card ──────────────────────────────────────────
          _DriveCard(tt: tt),
          const SizedBox(height: 24),

          // ── Export section ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'EXPORT OPTIONS',
              style: tt.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _Card(
            children: [
              _Row(
                icon: LucideIcons.fileCode,
                iconColor: AppColors.typeNote,
                title: 'Export as JSON',
                subtitle: 'All notes as structured data',
                badge: 'SOON',
                onTap: () => _showComingSoon(context, 'JSON Export'),
              ),
              const Divider(height: 1, indent: 56),
              _Row(
                icon: LucideIcons.fileText,
                iconColor: AppColors.typeFile,
                title: 'Export as PDF',
                subtitle: 'Human-readable document archive',
                badge: 'SOON',
                onTap: () => _showComingSoon(context, 'PDF Export'),
              ),
              const Divider(height: 1, indent: 56),
              _Row(
                icon: LucideIcons.hardDrive,
                iconColor: AppColors.typeLink,
                title: 'Local device backup',
                subtitle: 'Save encrypted archive to device',
                badge: 'SOON',
                onTap: () => _showComingSoon(context, 'Local Backup'),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Privacy note ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  LucideIcons.shieldCheck,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your data, your control',
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Google Drive access is limited to a single private folder '
                        'named "Archivo Vault". We never read or write anywhere else '
                        'in your Drive. You can revoke access at any time from your '
                        'Google account settings.',
                        style: tt.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ComingSoonSheet(),
    );
  }
}

// ── Google Drive connection card ────────────────────────────────────────────

class _DriveCard extends StatelessWidget {
  const _DriveCard({required this.tt});
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  LucideIcons.upload,
                  color: AppColors.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Google Drive Backup',
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Not connected',
                            style: tt.labelSmall?.copyWith(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'Back up your entire vault to your own Google Drive. Only you can '
            'access it — Archivo never touches your other Drive files.',
            style: tt.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 8),

          // Feature bullets
          ...[
            (LucideIcons.refreshCw, 'Automatic sync after every change'),
            (LucideIcons.lock, 'End-to-end encrypted before upload'),
            (LucideIcons.smartphone, 'Restore to any device instantly'),
          ].map(
            (e) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(e.$1, size: 14, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    e.$2,
                    style: tt.labelMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Connect button
          FilledButton.icon(
            onPressed: () => _showConnectSheet(context),
            icon: const Icon(LucideIcons.upload, size: 18),
            label: const Text('Connect Google Drive'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConnectSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ComingSoonSheet(),
    );
  }
}

// ── "Coming soon" bottom sheet ──────────────────────────────────────────────

class _ComingSoonSheet extends StatelessWidget {
  const _ComingSoonSheet();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                LucideIcons.upload,
                color: AppColors.secondary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Coming in the next update',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Google Drive backup is being built right now. When ready, '
              'you\'ll sign in once with Google — only to grant access to a '
              'private Archivo folder. Your notes stay encrypted end-to-end.',
              style: tt.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Got it'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared card + row widgets ───────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      title: Row(
        children: [
          Text(
            title,
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge!,
                style: tt.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        subtitle,
        style: tt.labelMedium?.copyWith(color: AppColors.onSurfaceVariant),
      ),
      trailing: const Icon(
        LucideIcons.chevronRight,
        size: 16,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}
