import '../../../../core/usecase/usecase.dart';
import '../repositories/notes_repository.dart';

class DeleteNote implements UseCase<void, String> {
  const DeleteNote(this._repository);

  final NotesRepository _repository;

  @override
  Future<void> call(String params) => _repository.deleteNote(params);
}
