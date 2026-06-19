import 'package:equatable/equatable.dart';

import '../../../../core/usecase/usecase.dart';
import '../repositories/notes_repository.dart';

class ArchiveNote implements UseCase<void, ArchiveNoteParams> {
  const ArchiveNote(this._repository);

  final NotesRepository _repository;

  @override
  Future<void> call(ArchiveNoteParams params) =>
      _repository.setArchived(id: params.id, archived: params.archived);
}

class ArchiveNoteParams extends Equatable {
  const ArchiveNoteParams({required this.id, required this.archived});

  final String id;
  final bool archived;

  @override
  List<Object?> get props => [id, archived];
}
