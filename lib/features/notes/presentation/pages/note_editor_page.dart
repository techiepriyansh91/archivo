import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/note.dart';
import '../cubit/notes_cubit.dart';

class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({super.key, this.note});

  final Note? note;

  bool get isEditing => note != null;

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late final TextEditingController _title = TextEditingController(
    text: widget.note?.title ?? '',
  );
  late final TextEditingController _body = TextEditingController(
    text: widget.note?.body ?? '',
  );
  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    _wordCount = _countWords(_body.text);
    _body.addListener(() {
      setState(() => _wordCount = _countWords(_body.text));
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  int _countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  Future<bool> _saveAndPop() async {
    final cubit = context.read<NotesCubit>();
    final title = _title.text.trim();
    final body = _body.text.trim();

    if (title.isEmpty && body.isEmpty) return true;

    final existing = widget.note;
    if (existing == null) {
      await cubit.create(title: title, body: body);
    } else {
      // Only save if something changed.
      if (existing.title != title || existing.body != body) {
        await cubit.update(existing.copyWith(title: title, body: body));
      }
    }
    return true;
  }

  Future<void> _delete() async {
    final note = widget.note;
    if (note == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<NotesCubit>().delete(note.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _saveAndPop();
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          backgroundColor: cs.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () async {
              await _saveAndPop();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
          actions: [
            if (widget.isEditing)
              IconButton(
                tooltip: 'Delete note',
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: cs.error,
                ),
                onPressed: _delete,
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    TextField(
                      controller: _title,
                      textInputAction: TextInputAction.next,
                      style: tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle: tt.headlineSmall?.copyWith(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w700,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    Divider(color: cs.outlineVariant, height: 1),
                    const SizedBox(height: 8),
                    // Body
                    Expanded(
                      child: TextField(
                        controller: _body,
                        expands: true,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        style: tt.bodyLarge?.copyWith(
                          color: cs.onSurface,
                          height: 1.6,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Start writing…',
                          hintStyle: tt.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom status bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                border: Border(
                  top: BorderSide(color: cs.outlineVariant, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    size: 16,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$_wordCount ${_wordCount == 1 ? 'word' : 'words'}',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Auto-saved',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.cloud_done_outlined,
                    size: 14,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
