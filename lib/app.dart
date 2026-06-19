import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/notes/presentation/cubit/notes_cubit.dart';
import 'features/notes/presentation/pages/notes_list_page.dart';
import 'injection/injection.dart';

class ArchivoApp extends StatelessWidget {
  const ArchivoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provided above MaterialApp so pushed routes (the editor) can read it.
    return BlocProvider<NotesCubit>(
      create: (_) => getIt<NotesCubit>(),
      child: MaterialApp(
        title: 'archivo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        ),
        // Slice 1: a single global notes list. Slice 1b inserts the auth gate
        // here once Firebase is configured.
        home: const NotesListPage(),
      ),
    );
  }
}
