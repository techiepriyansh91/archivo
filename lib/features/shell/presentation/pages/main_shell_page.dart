import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/services/vault_lock_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection/injection.dart';
import '../../../notes/presentation/cubit/notes_cubit.dart';
import '../../../settings/presentation/pages/backup_settings_page.dart';
import '../../../vault_home/presentation/pages/vault_home_page.dart';
import '../../../vault_lock/presentation/pages/lock_screen_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage>
    with WidgetsBindingObserver {
  final _lockService = getIt<VaultLockService>();
  int _tab = 0;
  bool _wasInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _wasInBackground = true;
    } else if (state == AppLifecycleState.resumed && _wasInBackground) {
      _wasInBackground = false;
      if (_lockService.isLockEnabled) {
        _showLockScreen();
      }
    }
  }

  void _showLockScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => LockScreenPage(
          onUnlocked: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotesCubit>(
      create: (_) => getIt<NotesCubit>(),
      child: Scaffold(
        body: IndexedStack(
          index: _tab,
          children: [
            const VaultHomePage(),
            const _FolderPlaceholder(),
            const _GraphPlaceholder(),
            const _SettingsPlaceholder(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(LucideIcons.home),
              selectedIcon: Icon(LucideIcons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.folder),
              selectedIcon: Icon(LucideIcons.folderOpen),
              label: 'Folders',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.network),
              selectedIcon: Icon(LucideIcons.network),
              label: 'Graph',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.settings),
              selectedIcon: Icon(LucideIcons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Tab placeholders (Folders / Graph / Settings) ----------

class _FolderPlaceholder extends StatelessWidget {
  const _FolderPlaceholder();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(LucideIcons.shieldCheck, color: Colors.white, size: 20),
        ),
        title: const Text('Folders'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(LucideIcons.folderOpen,
                  size: 36, color: cs.primary),
            ),
            const SizedBox(height: 16),
            Text('Folders', style: tt.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Organize your vault items\ninto folders. Coming soon.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GraphPlaceholder extends StatelessWidget {
  const _GraphPlaceholder();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(LucideIcons.shieldCheck, color: Colors.white, size: 20),
        ),
        title: const Text('Graph'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(LucideIcons.network, size: 36, color: cs.secondary),
            ),
            const SizedBox(height: 16),
            Text('Knowledge Graph', style: tt.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Visualize connections between\nyour notes with wiki-links. Coming soon.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsPlaceholder extends StatelessWidget {
  const _SettingsPlaceholder();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(LucideIcons.shieldCheck, color: Colors.white, size: 20),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Vault Secure banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vault Secure',
                      style: tt.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '256-bit AES Encryption active',
                      style: tt.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(
                  LucideIcons.shieldCheck,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 28,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Settings rows
          _SettingsCard(children: [
            _SettingsRow(
              icon: LucideIcons.lock,
              title: 'App Lock',
              subtitle: 'Biometric and PIN protection',
              onTap: () {},
            ),
            const Divider(height: 1, indent: 56),
            _SettingsRow(
              icon: LucideIcons.upload,
              title: 'Backup & Export',
              subtitle: 'Secure cloud sync and local export',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const BackupSettingsPage(),
                ),
              ),
            ),
            const Divider(height: 1, indent: 56),
            _SettingsRow(
              icon: LucideIcons.database,
              title: 'Storage',
              subtitle: 'Manage local vault storage',
              onTap: () {},
            ),
            const Divider(height: 1, indent: 56),
            _SettingsRow(
              icon: LucideIcons.info,
              title: 'About',
              subtitle: 'Version 1.0.0',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 16),
          Center(
            child: Text(
              'PRIVACY FIRST ARCHITECTURE',
              style: tt.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
      title: Text(title, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: tt.labelMedium?.copyWith(color: AppColors.onSurfaceVariant),
      ),
      trailing: const Icon(LucideIcons.chevronRight, size: 16,
          color: AppColors.onSurfaceVariant),
    );
  }
}
