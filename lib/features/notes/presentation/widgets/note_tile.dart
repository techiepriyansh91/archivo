import 'package:flutter/material.dart';

import '../../domain/entities/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onArchiveToggle,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onArchiveToggle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final title = note.title.trim().isEmpty ? 'Untitled' : note.title;

    return Card(
      color: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row + star
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      note.isFavorite
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 20,
                      color: note.isFavorite
                          ? const Color(0xFFD4A853)
                          : cs.onSurfaceVariant,
                    ),
                    onPressed: onFavoriteToggle,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                    tooltip: note.isFavorite
                        ? 'Remove from favorites'
                        : 'Add to favorites',
                  ),
                ],
              ),

              // Body preview
              if (note.body.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  note.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // Footer: timestamp + archive
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _relativeTime(note.updatedAt),
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      note.isArchived
                          ? Icons.unarchive_outlined
                          : Icons.archive_outlined,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                    onPressed: onArchiveToggle,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                    tooltip: note.isArchived ? 'Unarchive' : 'Archive',
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (dt.year == now.year) return '${_mon(dt.month)} ${dt.day}';
    return '${_mon(dt.month)} ${dt.day}, ${dt.year}';
  }

  String _mon(int m) => const [
        '',
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][m];
}
