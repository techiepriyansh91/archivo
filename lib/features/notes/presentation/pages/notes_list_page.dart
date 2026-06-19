import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/note.dart';
import '../cubit/notes_cubit.dart';
import '../cubit/notes_state.dart';
import '../widgets/note_tile.dart';
import 'note_editor_page.dart';

class NotesListPage extends StatefulWidget {
  const NotesListPage({super.key});

  @override
  State<NotesListPage> createState() => _NotesListPageState();
}

class _NotesListPageState extends State<NotesListPage> {
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    context.read<NotesCubit>().watch(archived: _showArchived);
  }

  void _toggleArchivedView() {
    setState(() => _showArchived = !_showArchived);
    context.read<NotesCubit>().watch(archived: _showArchived);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showArchived ? 'Archive' : 'Notes'),
        actions: [
          IconButton(
            tooltip: _showArchived ? 'Show notes' : 'Show archive',
            icon: Icon(_showArchived ? Icons.notes : Icons.archive_outlined),
            onPressed: _toggleArchivedView,
          ),
        ],
      ),
      body: BlocBuilder<NotesCubit, NotesState>(
        builder: (context, state) {
          return switch (state) {
            NotesInitial() ||
            NotesLoading() => const Center(child: CircularProgressIndicator()),
            NotesError(:final message) => _Message(
              icon: Icons.error_outline,
              text: message,
            ),
            NotesLoaded(:final notes) when notes.isEmpty => _Message(
              icon: _showArchived
                  ? Icons.archive_outlined
                  : Icons.note_add_outlined,
              text: _showArchived
                  ? 'Nothing archived yet.'
                  : 'No notes yet. Tap + to create one.',
            ),
            NotesLoaded(:final notes) => ListView.separated(
              itemCount: notes.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final note = notes[i];
                return NoteTile(
                  note: note,
                  onTap: () => _openEditor(note),
                  onArchiveToggle: () => context.read<NotesCubit>().setArchived(
                    id: note.id,
                    archived: !note.isArchived,
                  ),
                );
              },
            ),
          };
        },
      ),
      floatingActionButton: _showArchived
          ? null
          : FloatingActionButton(
              onPressed: _openEditor,
              tooltip: 'New note',
              child: const Icon(Icons.add),
            ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
