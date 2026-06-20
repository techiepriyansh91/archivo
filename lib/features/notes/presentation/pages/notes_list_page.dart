import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
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
  _ViewMode _mode = _ViewMode.all;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<NotesCubit>().watch(archived: false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setMode(_ViewMode mode) {
    setState(() => _mode = mode);
    context.read<NotesCubit>().watch(archived: mode == _ViewMode.archive);
  }

  List<Note> _filter(List<Note> notes) {
    var result = notes;
    if (_mode == _ViewMode.favorites) {
      result = result.where((n) => n.isFavorite).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (n) =>
                n.title.toLowerCase().contains(q) ||
                n.body.toLowerCase().contains(q),
          )
          .toList();
    }
    return result;
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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: const Text(
          'archivo',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: cs.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search notes…',
              leading: const Icon(Icons.search_rounded),
              trailing: _searchQuery.isNotEmpty
                  ? [
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                    ]
                  : null,
              onChanged: (v) => setState(() => _searchQuery = v),
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(
                cs.surfaceContainerHighest,
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // View mode chips
          Container(
            color: cs.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 8,
                children: [
                  _Chip(
                    label: 'All Notes',
                    icon: Icons.notes_rounded,
                    selected: _mode == _ViewMode.all,
                    onTap: () => _setMode(_ViewMode.all),
                  ),
                  _Chip(
                    label: 'Favorites',
                    icon: Icons.star_rounded,
                    selected: _mode == _ViewMode.favorites,
                    onTap: () => _setMode(_ViewMode.favorites),
                  ),
                  _Chip(
                    label: 'Archive',
                    icon: Icons.archive_rounded,
                    selected: _mode == _ViewMode.archive,
                    onTap: () => _setMode(_ViewMode.archive),
                  ),
                ],
              ),
            ),
          ),

          // Notes list
          Expanded(
            child: BlocBuilder<NotesCubit, NotesState>(
              builder: (context, state) {
                return switch (state) {
                  NotesInitial() ||
                  NotesLoading() =>
                    const Center(child: CircularProgressIndicator()),
                  NotesError(:final message) => _EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Something went wrong',
                    subtitle: message,
                  ),
                  NotesLoaded(:final notes) => _buildList(context, notes),
                };
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _mode != _ViewMode.archive
          ? FloatingActionButton.extended(
              onPressed: _openEditor,
              icon: const Icon(Icons.edit_rounded),
              label: const Text('New note'),
            )
          : null,
    );
  }

  Widget _buildList(BuildContext context, List<Note> notes) {
    final filtered = _filter(notes);

    if (filtered.isEmpty) {
      return _emptyForMode();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final note = filtered[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: NoteTile(
            note: note,
            onTap: () => _openEditor(note),
            onFavoriteToggle: () => context.read<NotesCubit>().update(
              note.copyWith(isFavorite: !note.isFavorite),
            ),
            onArchiveToggle: () => context.read<NotesCubit>().setArchived(
              id: note.id,
              archived: !note.isArchived,
            ),
          ),
        );
      },
    );
  }

  Widget _emptyForMode() {
    return switch (_mode) {
      _ViewMode.favorites => const _EmptyState(
        icon: Icons.star_outline_rounded,
        title: 'No favorites yet',
        subtitle: 'Star a note to find it here instantly.',
      ),
      _ViewMode.archive => const _EmptyState(
        icon: Icons.archive_outlined,
        title: 'Archive is empty',
        subtitle: 'Swipe a note to archive to clear your list.',
      ),
      _ViewMode.all when _searchQuery.isNotEmpty => const _EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No results',
        subtitle: 'Try a different search term.',
      ),
      _ => const _EmptyState(
        icon: Icons.edit_note_rounded,
        title: 'Your vault is empty',
        subtitle: 'Tap "New note" to capture your first idea.',
      ),
    };
  }
}

enum _ViewMode { all, favorites, archive }

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label),
      avatar: Icon(icon, size: 16),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: cs.primaryContainer,
      checkmarkColor: cs.onPrimaryContainer,
      labelStyle: TextStyle(
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
      ),
      side: BorderSide.none,
      showCheckmark: false,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

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
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 36, color: cs.onPrimaryContainer),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style:
                  tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
