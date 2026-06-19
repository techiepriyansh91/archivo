import '../../../../core/usecase/usecase.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class UpdateNote implements UseCase<void, Note> {
  const UpdateNote(this._repository);

  final NotesRepository _repository;

  @override
  Future<void> call(Note params) => _repository.updateNote(params);
}
