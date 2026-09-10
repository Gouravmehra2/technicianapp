import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:technicianapp/core/services/auth_service.dart';
import 'package:technicianapp/core/services/socket_service.dart';

/// Manages GPS → Socket.IO location sharing for active jobs.
///
/// Uses a position stream with distanceFilter so coordinates only emit
/// when the device has physically moved — eliminates repeated same-coordinate
/// emissions that the old Timer + getCurrentPosition approach caused.
///
/// Usage:
///   LocationSharingService.to.startForJobs(['jobId1', 'jobId2']);
///   LocationSharingService.to.pause();   // call when NavigationController is active
///   LocationSharingService.to.resume();  // call when NavigationController closes
///   LocationSharingService.to.stop();
class LocationSharingService extends GetxService {
  static LocationSharingService get to =>
      Get.find<LocationSharingService>();

  StreamSubscription<Position>? _positionSub;
  List<String> _activeJobIds = [];

  // ── Deduplication: only emit when coordinates actually changed ─────────────
  double? _lastEmittedLat;
  double? _lastEmittedLng;

  // ── Paused flag: set true while NavigationController owns the stream ────────
  bool _paused = false;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Start sharing location for the given [jobIds].
  /// Fires only when the device moves ≥ 15 m (distanceFilter), so the backend
  /// never receives the same coordinate twice in a row.
  /// Calling again with a new list replaces the previous one.
  Future<void> startForJobs(List<String> jobIds) async {
    if (jobIds.isEmpty) {
      stop();
      return;
    }

    _activeJobIds = jobIds;
    _paused = false;

    // Cancel any existing stream before opening a new one.
    await _positionSub?.cancel();
    _positionSub = null;
    _lastEmittedLat = null;
    _lastEmittedLng = null;

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15, // only fire when moved ≥ 15 m
      ),
    ).listen(
      _onPosition,
      onError: (e) => print('[LocationSharing] Stream error: $e'),
      cancelOnError: false,
    );

    print('[LocationSharing] Started stream for jobs: $_activeJobIds');
  }

  /// Temporarily pause emissions without cancelling the stream.
  /// Call this when NavigationController becomes active for the same job so
  /// the two sources don't race each other to the backend.
  void pause() {
    _paused = true;
    print('[LocationSharing] Paused (NavigationController is active)');
  }

  /// Resume emissions after NavigationController closes.
  void resume() {
    _paused = false;
    print('[LocationSharing] Resumed');
  }

  /// Stop sharing entirely and release the stream.
  Future<void> stop() async {
    await _positionSub?.cancel();
    _positionSub = null;
    _activeJobIds = [];
    _lastEmittedLat = null;
    _lastEmittedLng = null;
    _paused = false;
    print('[LocationSharing] Stopped');
  }

  bool get isSharing => _positionSub != null;

  // ── Internal ───────────────────────────────────────────────────────────────

  void _onPosition(Position position) {
    // Skip if paused (NavigationController is handling this job live).
    if (_paused) return;

    final technicianId = _technicianId;
    if (technicianId == null || _activeJobIds.isEmpty) return;

    if (!SocketService.instance.isConnected) {
      print('[LocationSharing] Socket not connected — skipping emit');
      return;
    }

    // ── Deduplication guard ─────────────────────────────────────────────────
    // distanceFilter already prevents most duplicates, but GPS can still
    // return identical coordinates on some devices. Skip if unchanged.
    if (_lastEmittedLat == position.latitude &&
        _lastEmittedLng == position.longitude) {
      print('[LocationSharing] Same coordinate — skipping emit');
      return;
    }
    _lastEmittedLat = position.latitude;
    _lastEmittedLng = position.longitude;

    for (final jobId in _activeJobIds) {
      SocketService.instance.emit('technician:location', {
        'jobId': jobId,
        'technicianId': technicianId,
        'lat': position.latitude,
        'lng': position.longitude,
      });
    }

    print(
      '[LocationSharing] Emitted for ${_activeJobIds.length} job(s) '
      '→ ${position.latitude}, ${position.longitude}',
    );
  }

  String? get _technicianId {
    try {
      return AuthService.to.user.value?.user?.id;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> onClose() async {
    await stop();
    super.onClose();
  }
}
