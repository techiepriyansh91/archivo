import 'package:equatable/equatable.dart';

/// Domain note. Pure business object — no Drift/JSON annotations (those live in
/// the data layer). Sync bookkeeping (syncStatus, deletedAt, etc.) is a data-
/// layer concern and intentionally absent here.
class Note extends Equatable {
  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.isFavorite,
    required this.isArchived,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String body;
  final bool isFavorite;
  final bool isArchived;
  final DateTime updatedAt;

  Note copyWith({
    String? title,
    String? body,
    bool? isFavorite,
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    isFavorite,
    isArchived,
    updatedAt,
  ];
}
