import 'package:archivo/core/utils/clock.dart';

/// Deterministic clock so tests can assert exact `updatedAt` values.
class FixedClock implements Clock {
  FixedClock(this.ms);

  int ms;

  @override
  int nowMs() => ms;
}
