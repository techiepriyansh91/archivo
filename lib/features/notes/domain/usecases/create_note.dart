import 'package:equatable/equatable.dart';

import '../../../../core/usecase/usecase.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class CreateNote implements UseCase<Note, CreateNoteParams> {
  const CreateNote(this._repository);

  final NotesRepository _repository;

  @override
  Future<Note> call(CreateNoteParams params) =>
      _repository.createNote(title: params.title, body: params.body);
}

class CreateNoteParams extends Equatable {
  const CreateNoteParams({required this.title, required this.body});

  final String title;
  final String body;

  @override
  List<Object?> get props => [title, body];
}
