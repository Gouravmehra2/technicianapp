import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/core/services/auth_service.dart';
import 'package:technicianapp/core/services/socket_service.dart';

/// One GPS owner for an active journey. Screen disposal never ends the journey.
class LocationSharingService extends GetxService with WidgetsBindingObserver {
  LocationSharingService({SocketService? socketService})
    : _socketService = socketService ?? SocketService.instance;
  final SocketService _socketService;

  static LocationSharingService get to => Get.find<LocationSharingService>();
  final position = Rxn<Position>();
  final error = RxnString();
  final lastAcknowledgedAt = Rxn<DateTime>();
  final _positions = StreamController<Position>.broadcast();
  Stream<Position> get positions => _positions.stream;
  StreamSubscription<Position>? _subscription;
  Timer? _timer;
  Set<String> _jobs = {};
  DateTime? _lastSentAt;
  Position? _lastSent;
  int _generation = 0;
  int _sequence = 0;
  String _session = '';
  bool _refreshing = false;
  bool _restoring = false;
  Future<void> _storageWrite = Future.value();

  String get _storageKey =>
      'tracking_jobs_${AuthService.to.user.value?.user?.id}';

  Future<void> _persist() {
    final key = _storageKey;
    final jobs = _jobs.toList();
    _storageWrite = _storageWrite
        .then((_) async {
          final prefs = await SharedPreferences.getInstance();
          if (jobs.isEmpty) {
            await prefs.remove(key);
          } else {
            await prefs.setStringList(key, jobs);
          }
        })
        .catchError((Object e) {
          debugPrint('Could not persist tracking state: $e');
        });
    return _storageWrite;
  }

  @override
  void onReady() {
    super.onReady();
    unawaited(restoreJourney());
  }

  /// Only restore jobs still marked on_the_way by the server for this account.
  Future<void> restoreJourney() async {
    if (isSharing || _restoring || !AuthService.to.isLoggedIn) return;
    _restoring = true;
    final generation = _generation;
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_storageKey) ?? [];
      final active = <String>[];
      for (final id in ids) {
        final job = await Get.find<ApiRepo>().getJobDetailApi(id);
        if (job.status == 'ontheway') active.add(id);
      }
      if (generation != _generation || !AuthService.to.isLoggedIn) return;
      if (active.isEmpty) {
        await prefs.remove(_storageKey);
        return;
      }
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        error.value = 'Allow location access to resume your journey.';
        return;
      }
      if (generation == _generation) await startForJobs(active);
    } catch (_) {
      error.value = 'Could not resume tracking. Open navigation to retry.';
    } finally {
      _restoring = false;
    }
  }

  final Map<String, _PendingLocation> _pending = {};
  bool get isSharing => _jobs.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _socketService.addConnectionListener(_onConnected);
  }

  static bool isUsable(Position p, DateTime now) =>
      p.latitude.isFinite &&
      p.longitude.isFinite &&
      p.latitude.abs() <= 90 &&
      p.longitude.abs() <= 180 &&
      p.accuracy.isFinite &&
      p.accuracy >= 0 &&
      p.accuracy <= 100 &&
      now.difference(p.timestamp) <= const Duration(seconds: 60) &&
      p.timestamp.difference(now) <= const Duration(seconds: 5);

  static bool shouldSend(
    Position current,
    Position? previous,
    DateTime now,
    DateTime? lastSentAt,
  ) {
    if (!isUsable(current, now)) return false;
    if (lastSentAt == null) return true;
    final elapsed = now.difference(lastSentAt);
    if (elapsed < const Duration(seconds: 5)) return false;
    return elapsed >= const Duration(seconds: 30) ||
        previous == null ||
        Geolocator.distanceBetween(
              previous.latitude,
              previous.longitude,
              current.latitude,
              current.longitude,
            ) >=
            10;
  }

  Future<void> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw StateError('Enable location services to start tracking.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      throw StateError('Allow location access in Settings to start tracking.');
    }
  }

  LocationSettings get _settings {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        intervalDuration: const Duration(seconds: 5),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Sharing your journey',
          notificationText:
              'Your location is shared while travelling to the client.',
          enableWakeLock: true,
        ),
      );
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        activityType: ActivityType.automotiveNavigation,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
  }

  Future<void> startForJobs(List<String> jobIds) async {
    final jobs = jobIds.where((id) => id.isNotEmpty).toSet();
    if (jobs.isEmpty) return stop();
    if (setEquals(jobs, _jobs) && _subscription != null) return;
    final generation = ++_generation;
    await ensurePermission();
    if (generation != _generation) return;
    await _subscription?.cancel();
    if (generation != _generation) return;
    _jobs = jobs;
    _pending.clear();
    _lastSent = null;
    _lastSentAt = null;
    position.value = null;
    _session = DateTime.now().microsecondsSinceEpoch.toString();
    _sequence = 0;
    error.value = null;
    _subscription = Geolocator.getPositionStream(locationSettings: _settings)
        .listen(
          (p) {
            if (generation == _generation) _accept(p);
          },
          onError: (Object e) {
            error.value = 'Location unavailable. Check GPS and permissions.';
          },
          onDone: () {
            if (generation == _generation) _subscription = null;
          },
        );
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _tick());
    _socketService.connectAndJoin();
    await _persist();
    await _refresh();
  }

  void _accept(Position p) {
    if (!isSharing || !isUsable(p, DateTime.now())) return;
    if (position.value != null &&
        p.timestamp.isBefore(position.value!.timestamp)) {
      return;
    }
    position.value = p;
    error.value = null;
    _positions.add(p);
    _send();
  }

  Future<void> _refresh() async {
    if (!isSharing || _refreshing) return;
    final generation = _generation;
    _refreshing = true;
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (generation == _generation) _accept(p);
    } catch (_) {
      if (generation == _generation) {
        error.value = 'Waiting for a fresh GPS location.';
      }
    } finally {
      _refreshing = false;
    }
  }

  void _onConnected() {
    if (!isSharing) return;
    _pending.clear();
    _lastSentAt = null;
    unawaited(_refresh());
  }

  void _tick() {
    if (!isSharing) return;
    // Reconnect socket if it dropped
    if (!_socketService.isConnected) {
      _socketService.reconnectIfNeeded();
    }
    // Refresh GPS if the last fix is stale (>30 s old)
    final p = position.value;
    if (p == null ||
        DateTime.now().difference(p.timestamp) >= const Duration(seconds: 30)) {
      unawaited(_refresh());
    }
    // Attempt to send the latest position (throttled internally by shouldSend)
    _send();
    // Retry any pending deliveries that haven't been ACK'd yet
    for (final entry in _pending.entries.toList()) {
      final recordedAt = DateTime.parse(
        entry.value.payload['recordedAt'] as String,
      );
      if (DateTime.now().difference(recordedAt) > const Duration(seconds: 60)) {
        _pending.remove(entry.key);
      } else {
        _deliver(entry.key, entry.value);
      }
    }
  }

  void _send() {
    final p = position.value;
    final now = DateTime.now();
    if (!isSharing ||
        p == null ||
        !isUsable(p, now) ||
        !_socketService.isConnected) {
      return;
    }
    if (!shouldSend(p, _lastSent, now, _lastSentAt)) return;
    final techId = AuthService.to.user.value?.user?.id;
    if (techId == null || !AuthService.to.isLoggedIn) return;
    _lastSent = p;
    _lastSentAt = now;
    final sequence = ++_sequence;
    for (final jobId in _jobs.toList()) {
      final pending = _PendingLocation({
        'jobId': jobId,
        'technicianId': techId,
        'lat': p.latitude,
        'lng': p.longitude,
        'accuracyMeters': p.accuracy,
        'recordedAt': p.timestamp.toUtc().toIso8601String(),
        'sessionId': _session,
        'sequence': sequence,
      });
      _pending[jobId] = pending;
      _deliver(jobId, pending);
    }
  }

  void _deliver(String jobId, _PendingLocation pending) {
    final now = DateTime.now();
    if (!_socketService.isConnected ||
        pending.attempts >= 3 ||
        (pending.sentAt != null &&
            now.difference(pending.sentAt!) < const Duration(seconds: 5))) {
      return;
    }
    pending.attempts++;
    pending.sentAt = now;
    _socketService.emitWithAck('technician:location', pending.payload, (ack) {
      if (!identical(_pending[jobId], pending)) return;
      if (ack is Map && ack['success'] == true) {
        _pending.remove(jobId);
        lastAcknowledgedAt.value = DateTime.now();
      } else if (ack is Map && ack['code'] == 'JOB_INACTIVE') {
        unawaited(stopForJob(jobId));
      }
    });
  }

  Future<void> stopForJob(String jobId) async {
    _jobs.remove(jobId);
    _pending.remove(jobId);
    if (_jobs.isEmpty) {
      await stop();
    } else {
      await _persist();
    }
  }

  Future<void> stop() async {
    ++_generation;
    _jobs = {};
    _timer?.cancel();
    _timer = null;
    final subscription = _subscription;
    _subscription = null;
    _pending.clear();
    position.value = null;
    _lastSent = null;
    _lastSentAt = null;
    error.value = null;
    lastAcknowledgedAt.value = null;
    await _persist();
    await subscription?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !isSharing) {
      unawaited(restoreJourney());
    }
    if (state == AppLifecycleState.resumed && isSharing) {
      _socketService.reconnectIfNeeded();
      if (_subscription == null) {
        unawaited(
          startForJobs(_jobs.toList()).catchError((Object e) {
            error.value = e.toString();
          }),
        );
      } else {
        unawaited(_refresh());
      }
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _socketService.removeConnectionListener(_onConnected);
    unawaited(stop());
    unawaited(_positions.close());
    super.onClose();
  }
}

class _PendingLocation {
  _PendingLocation(this.payload);
  final Map<String, dynamic> payload;
  int attempts = 0;
  DateTime? sentAt;
}
