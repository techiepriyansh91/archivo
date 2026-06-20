import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection/injection.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../notes/presentation/cubit/notes_cubit.dart';
import '../../../notes/presentation/cubit/notes_state.dart';
import '../../../notes/presentation/pages/note_editor_page.dart';
import '../../../settings/presentation/pages/backup_settings_page.dart';

class VaultHomePage extends StatefulWidget {
  const VaultHomePage({super.key});

  @override
  State<VaultHomePage> createState() => _VaultHomePageState();
}

const _kNudgeThreshold = 5;
const _kNudgeDismissedKey = 'archivo_drive_nudge_dismissed';

class _VaultHomePageState extends State<VaultHomePage> {
  final _prefs = getIt<SharedPreferences>();
  bool _nudgeDismissed = true; // start true to avoid flash before prefs load

  @override
  void initState() {
    super.initState();
    context.read<NotesCubit>().watch(archived: false);
    _nudgeDismissed = _prefs.getBool(_kNudgeDismissedKey) ?? false;
  }

  void _dismissNudge() {
    _prefs.setBool(_kNudgeDismissedKey, true);
    setState(() => _nudgeDismissed = true);
  }

  Future<void> _openEditor([Note? note]) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<NotesCubit>(),
          child: NoteEditorPage(note: note),
        ),
      ),
    );
  }

  void _showCaptureMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _CaptureSheet(onNote: () {
        Navigator.pop(context);
        _openEditor();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        leading: IconButton(
          icon: const Icon(LucideIcons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text(
          'Archivo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<NotesCubit, NotesState>(
        builder: (context, state) {
          final notes = switch (state) {
            NotesLoaded(:final notes) => notes,
            _ => <Note>[],
          };

          final pinned = notes.where((n) => n.isFavorite).toList();
          final recent = notes.where((n) => !n.isFavorite).toList();

          return CustomScrollView(
            slivers: [
              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(23),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.search,
                            size: 18,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Search your vault...',
                              style: tt.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const Icon(
                            LucideIcons.mic,
                            size: 18,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Drive nudge — shown once after 5+ notes are created
              if (!_nudgeDismissed && notes.length >= _kNudgeThreshold)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _DriveNudgeBanner(
                      noteCount: notes.length,
                      onConnect: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const BackupSettingsPage(),
                        ),
                      ),
                      onDismiss: _dismissNudge,
                    ),
                  ),
                ),

              if (notes.isEmpty)
                SliverFillRemaining(
                  child: _EmptyVault(onCreate: _openEditor),
                )
              else ...[
                // Pinned section
                if (pinned.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: 'Pinned Items',
                      action: 'VIEW ALL',
                      onAction: () {},
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        itemCount: pinned.length,
                        itemBuilder: (_, i) => _PinnedCard(
                          note: pinned[i],
                          onTap: () => _openEditor(pinned[i]),
                        ),
                      ),
                    ),
                  ),
                ],

                // Recent Activity
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: 'Recent Activity',
                    action: null,
                    onAction: null,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  sliver: SliverList.builder(
                    itemCount: recent.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ActivityTile(
                        note: recent[i],
                        onTap: () => _openEditor(recent[i]),
                        onFavoriteToggle: () =>
                            context.read<NotesCubit>().update(
                              recent[i].copyWith(
                                isFavorite: !recent[i].isFavorite,
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCaptureMenu,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
      ),
    );
  }
}

// ---------- Section header ----------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Text(
            title,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: tt.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------- Pinned horizontal card ----------

class _PinnedCard extends StatelessWidget {
  const _PinnedCard({required this.note, required this.onTap});

  final Note note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.typeNote.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                LucideIcons.fileText,
                size: 16,
                color: AppColors.typeNote,
              ),
            ),
            const Spacer(),
            Text(
              note.title.isEmpty ? 'Untitled' : note.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              _relativeTime(note.updatedAt),
              style: tt.labelMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Recent activity tile ----------

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.note,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            // 4px type strip
            Container(
              width: 4,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.typeNote,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.typeNote.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                LucideIcons.fileText,
                size: 18,
                color: AppColors.typeNote,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    note.title.isEmpty ? 'Untitled' : note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    note.body.trim().isEmpty
                        ? _relativeTime(note.updatedAt)
                        : '${note.body.trim().split('\n').first}  •  ${_relativeTime(note.updatedAt)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.labelMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // 3-dot menu
            IconButton(
              icon: const Icon(
                LucideIcons.moreVertical,
                size: 18,
                color: AppColors.onSurfaceVariant,
              ),
              onPressed: () => _showMenu(context),
              padding: const EdgeInsets.all(8),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(LucideIcons.star),
              title: Text(
                note.isFavorite ? 'Remove from pinned' : 'Pin to top',
              ),
              onTap: () {
                Navigator.pop(context);
                onFavoriteToggle();
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.edit2),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                onTap();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ---------- Drive nudge banner ----------

class _DriveNudgeBanner extends StatelessWidget {
  const _DriveNudgeBanner({
    required this.noteCount,
    required this.onConnect,
    required this.onDismiss,
  });

  final int noteCount;
  final VoidCallback onConnect;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.upload,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Back up your vault',
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your $noteCount notes live only on this device. '
                  'Connect Google Drive to keep them safe.',
                  style: tt.labelMedium?.copyWith(
                    color: AppColors.secondary.withValues(alpha: 0.75),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onConnect,
                  child: Text(
                    'Connect Google Drive →',
                    style: tt.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(LucideIcons.x, size: 16),
            color: AppColors.secondary.withValues(alpha: 0.6),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ---------- Empty state ----------

class _EmptyVault extends StatelessWidget {
  const _EmptyVault({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                LucideIcons.archive,
                size: 40,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your vault is empty',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to capture your first\nnote, file, link, or voice memo.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Add your first item'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Capture bottom sheet ----------

class _CaptureSheet extends StatelessWidget {
  const _CaptureSheet({required this.onNote});
  final VoidCallback onNote;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add to vault',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _CaptureOption(
              icon: LucideIcons.fileText,
              color: AppColors.typeNote,
              title: 'Note',
              subtitle: 'Rich text, formatting, and tags',
              onTap: onNote,
            ),
            _CaptureOption(
              icon: LucideIcons.file,
              color: AppColors.typeFile,
              title: 'File',
              subtitle: 'PDF, images, and documents',
              onTap: () => Navigator.pop(context),
            ),
            _CaptureOption(
              icon: LucideIcons.link,
              color: AppColors.typeLink,
              title: 'Link',
              subtitle: 'Saved URLs and bookmarks',
              onTap: () => Navigator.pop(context),
            ),
            _CaptureOption(
              icon: LucideIcons.mic,
              color: AppColors.typeVoice,
              title: 'Voice',
              subtitle: 'Audio memo and transcriptions',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _CaptureOption extends StatelessWidget {
  const _CaptureOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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

String _relativeTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  const months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  if (dt.year == now.year) return '${months[dt.month]} ${dt.day}';
  return '${months[dt.month]} ${dt.day}, ${dt.year}';
}
