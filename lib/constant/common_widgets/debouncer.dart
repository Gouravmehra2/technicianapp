import 'dart:async';

/// A utility class that delays executing [action] until [delay] has elapsed
/// since the last call. Ideal for search inputs, API calls, etc.
///
/// ## Usage
/// ```dart
/// // Create once, typically in a controller or State:
/// final _debouncer = Debouncer(delay: Duration(milliseconds: 400));
///
/// // In onChanged:
/// _debouncer.run(() => searchApi(query));
///
/// // Always cancel in dispose:
/// _debouncer.cancel();
/// ```
///
/// Custom delays per screen:
/// ```dart
/// Debouncer(delay: Duration(milliseconds: 600))  // slower API
/// Debouncer(delay: Duration(milliseconds: 200))  // fast local filter
/// Debouncer.fast()   // 200 ms  — local/in-memory filtering
/// Debouncer.normal() // 400 ms  — default network calls
/// Debouncer.slow()   // 700 ms  — heavy / expensive API calls
/// ```
class Debouncer {
  /// How long to wait after the last call before firing [action].
  final Duration delay;

  Timer? _timer;

  Debouncer({required this.delay});

  // ── Named constructors for common timings ──────────────────────────────────

  /// 200 ms — suited for fast local / in-memory filtering.
  factory Debouncer.fast() => Debouncer(delay: const Duration(milliseconds: 200));

  /// 400 ms — default timing for most network search calls.
  factory Debouncer.normal() => Debouncer(delay: const Duration(milliseconds: 400));

  /// 700 ms — suited for slow or expensive remote API calls.
  factory Debouncer.slow() => Debouncer(delay: const Duration(milliseconds: 700));

  // ── API ────────────────────────────────────────────────────────────────────

  /// Schedule [action] to run after [delay]. Any previously pending call is
  /// cancelled before the new timer starts.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancel any pending timer without running [action].
  void cancel() => _timer?.cancel();

  /// Whether a call is currently pending.
  bool get isPending => _timer?.isActive ?? false;
}
