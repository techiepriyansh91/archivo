/// Injectable time source. Repositories depend on this instead of calling
/// `DateTime.now()` directly, so tests can assert exact `updatedAt` values
/// (the LWW clock) deterministically.
abstract interface class Clock {
  /// Current time as epoch milliseconds.
  int nowMs();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  int nowMs() => DateTime.now().millisecondsSinceEpoch;
}
