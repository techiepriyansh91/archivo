import '../../../../core/database/app_database.dart';
import '../../domain/entities/note.dart';

/// Maps the Drift row class to the domain entity. Mapping lives here, not on the
/// entity, so the domain stays free of persistence concerns.
extension NoteRowMapper on NoteRow {
  Note toEntity() => Note(
    id: id,
    title: title,
    body: body,
    isFavorite: isFavorite,
    isArchived: isArchived,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
  );
}
