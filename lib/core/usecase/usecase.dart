/// Base contract for a single business operation. One public [call] keeps each
/// use case single-responsibility — see docs/PLAN.md §1.
abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// Sentinel for use cases that take no arguments.
class NoParams {
  const NoParams();
}
