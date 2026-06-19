/// Per-row sync state, stored as the column's integer index.
/// Order is load-bearing — do not reorder (it maps to DB values). See PLAN.md §3.1.
enum SyncStatus {
  /// In sync with the server.
  synced,

  /// Local write not yet pushed; the sync queue will reconcile it (Slice 2).
  pending,

  /// Local and remote diverged; awaiting conflict resolution (Slice 2, §4.3).
  conflict,
}
