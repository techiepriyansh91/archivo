import 'package:flutter/material.dart';

import '../../domain/entities/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    required this.onTap,
    required this.onArchiveToggle,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onArchiveToggle;

  @override
  Widget build(BuildContext context) {
    final title = note.title.trim().isEmpty ? 'Untitled' : note.title;
    return ListTile(
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: note.body.trim().isEmpty
          ? null
          : Text(note.body, maxLines: 2, overflow: TextOverflow.ellipsis),
      onTap: onTap,
      trailing: IconButton(
        tooltip: note.isArchived ? 'Unarchive' : 'Archive',
        icon: Icon(
          note.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
        ),
        onPressed: onArchiveToggle,
      ),
    );
  }
}
