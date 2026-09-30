import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/common_widgets/app_snackbar.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/core/utils/route_progress.dart';
import 'package:technicianapp/core/services/location_sharing_service.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_controller.dart';

// Minimum metres device must move before the traveled trail is redrawn.
const _kTraveledRedrawThresholdMetres = 8.0;

class NavigationController extends GetxController {
  // ── Job ──────────────────────────────────────────────────────────────────────
  late final ScheduledJobModel job;

  // ── State ────────────────────────────────────────────────────────────────────
  final currentPosition = Rxn<LatLng>();
  final distanceKm      = 0.0.obs;
  final etaMinutes      = 0.obs;
  final hasReached      = false.obs;
  final isMapReady      = false.obs;
  final isNavigating    = false.obs;
  final isLoadingRoute  = false.obs;

  /// True during the one-time startup route fetch (autoStart / resume path).
  final isResuming = false.obs;

  // ── Bearing for camera rotation ───────────────────────────────────────────────
  final currentBearing = 0.0.obs;

  // ── Map ──────────────────────────────────────────────────────────────────────
  GoogleMapController? _mapController;
  final markers   = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;

  // ── Location stream ──────────────────────────────────────────────────────────
  StreamSubscription<Position>? _locationSub;

  // ── Route — fetched ONCE on navigation start, never again ────────────────────
  List<LatLng> _routePoints        = [];
  double?      _routeSecondsPerMetre;

  // ── Traveled breadcrumb trail ─────────────────────────────────────────────────
  final List<LatLng> _traveledPoints     = [];
  LatLng?            _lastTraveledRedraw;

  final isApproximateDistance = true.obs;
  bool _starting = false;
  bool _closed   = false;
  Worker? _trackingErrorWorker;

  // ── Destination ──────────────────────────────────────────────────────────────
  LatLng? get _dest => job.lat != null && job.lng != null
      ? LatLng(job.lat!, job.lng!)
      : null;

  // ─────────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    job = Get.arguments as ScheduledJobModel;
    _addDestinationMarker();
    _trackingErrorWorker = ever(LocationSharingService.to.error, (msg) {
      if (msg != null && isNavigating.value) {
        AppSnackbar.error(msg, title: 'Tracking');
      }
    });
    final resume = job.status == JobStatus.onTheWay;
    _initPreview(autoStart: resume);
  }

  @override
  void onClose() {
    _closed = true;
    _trackingErrorWorker?.dispose();
    _locationSub?.cancel();
    _traveledPoints.clear();
    _lastTraveledRedraw = null;
    _mapController?.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // INIT — get position, fetch route ONCE, optionally auto-start tracking
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> _initPreview({bool autoStart = false}) async {
    if (autoStart) isResuming.value = true;
    try {
      await LocationSharingService.to.ensurePermission();
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (_closed) return;
      final latLng = LatLng(pos.latitude, pos.longitude);
      currentPosition.value = latLng;
      _updateMyMarker(latLng);

      // ── Route fetched ONCE here ──────────────────────────────────────────
      await _fetchRouteOnce(latLng);

      if (autoStart && !_closed) await _beginTracking();
    } catch (e) {
      if (!_closed) AppSnackbar.error(e.toString(), title: 'Location');
    } finally {
      if (autoStart) isResuming.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // START NAVIGATION (user taps the button)
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> startNavigation() async {
    if (_starting || isNavigating.value || _closed) return;
    _starting = true;
    try {
      final id = job.rawJobId;
      if (id == null || id.isEmpty || _dest == null) {
        throw StateError('Job destination is missing.');
      }
      await LocationSharingService.to.ensurePermission();
      await Get.find<ApiRepo>().startNavigationApi(id);
      if (!_closed) await _beginTracking();
    } catch (e) {
      if (!_closed) {
        AppSnackbar.error(e.toString(), title: 'Unable to start navigation');
      }
    } finally {
      _starting = false;
    }
  }

  Future<void> _beginTracking() async {
    final id = job.rawJobId;
    if (id == null || id.isEmpty) throw StateError('Job ID missing.');
    _startLocationStream();
    await LocationSharingService.to.startForJobs([id]);
    if (_closed) return;
    isNavigating.value = true;
    // Seed the UI with the latest known fix
    final latest = LocationSharingService.to.position.value;
    if (latest != null) _onPosition(latest);
  }

  void _startLocationStream() {
    _locationSub?.cancel();
    _locationSub = LocationSharingService.to.positions.listen(_onPosition);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // GPS POSITION UPDATE
  // Every new fix → move marker + camera + update breadcrumb + recalc ETA.
  // NO network calls are made here. Route was already fetched once on start.
  // ─────────────────────────────────────────────────────────────────────────────

  void _onPosition(Position pos) {
    if (hasReached.value || _closed) return;

    final latLng = LatLng(pos.latitude, pos.longitude);
    currentPosition.value = latLng;
    currentBearing.value  = pos.heading;

    _updateMyMarker(latLng);
    _animateCameraToNavigation(latLng, pos.heading);
    _appendTraveledPoint(latLng);
    _recalcEtaLocally(latLng);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // LOCAL ETA RECALC — pure in-memory, zero network calls
  // ─────────────────────────────────────────────────────────────────────────────

  void _recalcEtaLocally(LatLng from) {
    if (_routePoints.isEmpty) {
      final dest = _dest;
      if (dest != null) distanceKm.value = _haversine(from, dest) / 1000;
      return;
    }
    final progress = RouteProgress.calculate(from, _routePoints);
    if (progress == null) return;
    distanceKm.value = progress.remainingMetres / 1000;
    final spm = _routeSecondsPerMetre;
    etaMinutes.value =
        spm == null ? 0 : (progress.remainingMetres * spm / 60).ceil();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // ONE-TIME ROUTE FETCH — POST /api/routes/directions
  // Called exactly once per navigation session (on init). Never called again.
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> _fetchRouteOnce(LatLng origin) async {
    final dest = _dest;
    if (dest == null || _closed) return;

    isLoadingRoute.value = true;
    try {
      final result = await Get.find<ApiRepo>().getDirectionsApi(
        originLat: origin.latitude,
        originLng: origin.longitude,
        destLat: dest.latitude,
        destLng: dest.longitude,
      );

      if (_closed || hasReached.value) return;

      if (!result.success || result.data == null) {
        _drawFallbackLine(origin);
        return;
      }

      final data      = result.data!;
      distanceKm.value  = data.distanceKm;
      etaMinutes.value  = data.durationMinutes;

      final allPoints = _decodePolyline(data.encodedPolyline);
      if (allPoints.isEmpty) {
        _drawFallbackLine(origin);
        return;
      }

      // Keep full points for local ETA recalc; draw a simplified version.
      _routePoints          = allPoints;
      isApproximateDistance.value = false;
      _routeSecondsPerMetre = data.distanceKm > 0
          ? data.durationMinutes * 60 / (data.distanceKm * 1000)
          : null;

      _setRoutePolyline(
        PolylineSimplifier.simplify(allPoints, kMaxRoutePoints),
      );
    } catch (_) {
      _drawFallbackLine(origin);
    } finally {
      isLoadingRoute.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TRAVELED BREADCRUMB TRAIL
  // ─────────────────────────────────────────────────────────────────────────────

  void _appendTraveledPoint(LatLng latLng) {
    final last = _lastTraveledRedraw;
    if (last != null) {
      final moved = Geolocator.distanceBetween(
        last.latitude, last.longitude,
        latLng.latitude, latLng.longitude,
      );
      if (moved < _kTraveledRedrawThresholdMetres) return;
    }

    _traveledPoints.add(latLng);
    // Pre-cap raw buffer before simplification
    if (_traveledPoints.length > kMaxTraveledPoints * 3) {
      _traveledPoints.removeAt(0);
    }

    _lastTraveledRedraw = latLng;
    _redrawTraveledTrail();
  }

  void _redrawTraveledTrail() {
    if (_traveledPoints.length < 2) return;

    final simplified = PolylineSimplifier.simplify(
      _traveledPoints, kMaxTraveledPoints,
    );

    // Preserve the route polyline; replace only the traveled polyline
    final route = polylines.toList().firstWhereOrNull(
      (p) => p.polylineId.value == 'route',
    );

    polylines.assignAll([
      Polyline(
        polylineId: const PolylineId('traveled'),
        points: simplified,
        color: const Color(0xFFBDBDBD),
        width: 6,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
      if (route != null) route,
    ]);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // POLYLINE HELPERS
  // ─────────────────────────────────────────────────────────────────────────────

  void _setRoutePolyline(List<LatLng> points) {
    if (_closed) return;
    final traveled = polylines.toList().firstWhereOrNull(
      (p) => p.polylineId.value == 'traveled',
    );
    polylines.assignAll([
      if (traveled != null) traveled,
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: const Color(0xFF4A6CF7),
        width: 8,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    ]);
  }

  void _drawFallbackLine(LatLng from) {
    final dest = _dest;
    if (dest == null || _closed) return;
    _routePoints          = [];
    _routeSecondsPerMetre = null;
    isApproximateDistance.value = true;
    distanceKm.value = _haversine(from, dest) / 1000;
    etaMinutes.value = 0;
    polylines.assignAll([
      Polyline(
        polylineId: const PolylineId('route'),
        points: [from, dest],
        color: const Color(0xFF4A6CF7),
        width: 8,
        patterns: [PatternItem.dash(20), PatternItem.gap(8)],
      ),
    ]);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // POLYLINE DECODER — Google encoded polyline algorithm
  // ─────────────────────────────────────────────────────────────────────────────

  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0, lat = 0, lng = 0;
    while (index < encoded.length) {
      int shift = 0, result = 0, b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      shift = 0; result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // MARKERS
  // ─────────────────────────────────────────────────────────────────────────────

  void _addDestinationMarker() {
    final dest = _dest;
    if (dest == null) return;
    markers.add(Marker(
      markerId: const MarkerId('destination'),
      position: dest,
      infoWindow: InfoWindow(title: job.title, snippet: 'Destination'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
  }

  void _updateMyMarker(LatLng pos) {
    markers.removeWhere((m) => m.markerId.value == 'me');
    markers.add(Marker(
      markerId: const MarkerId('me'),
      position: pos,
      infoWindow: const InfoWindow(title: 'You'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // CAMERA
  // ─────────────────────────────────────────────────────────────────────────────

  void onMapCreated(GoogleMapController c) {
    _mapController = c;
    isMapReady.value = true;
    final cur  = currentPosition.value;
    final dest = _dest;
    if (cur != null && dest != null) {
      Future.delayed(
        const Duration(milliseconds: 300),
        () => _fitBothPoints(cur, dest),
      );
    } else if (dest != null) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: dest, zoom: 14)),
      );
    }
  }

  void _animateCameraToNavigation(LatLng pos, double bearing) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: pos, zoom: 17, tilt: 50, bearing: bearing),
      ),
    );
  }

  void _fitBothPoints(LatLng a, LatLng b) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            min(a.latitude, b.latitude),
            min(a.longitude, b.longitude),
          ),
          northeast: LatLng(
            max(a.latitude, b.latitude),
            max(a.longitude, b.longitude),
          ),
        ),
        80,
      ),
    );
  }

  void recenter() {
    final cur = currentPosition.value;
    if (cur == null) return;
    if (isNavigating.value) {
      _animateCameraToNavigation(cur, currentBearing.value);
    } else {
      final dest = _dest;
      if (dest != null) {
        _fitBothPoints(cur, dest);
      } else {
        _mapController?.animateCamera(CameraUpdate.newLatLng(cur));
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // REACHED
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> markReached() async {
    final jobId = job.rawJobId;
    final fix   = LocationSharingService.to.position.value;
    final pos   = fix != null &&
            LocationSharingService.isUsable(fix, DateTime.now())
        ? LatLng(fix.latitude, fix.longitude)
        : null;

    if (jobId == null || pos == null) {
      AppSnackbar.error('Location not available yet.', title: 'Error');
      return;
    }

    try {
      final result = await Get.find<ApiRepo>().markReachedApi(
        jobId,
        lat: pos.latitude,
        lng: pos.longitude,
      );

      if (result.success) {
        hasReached.value  = true;
        isNavigating.value = false;

        _locationSub?.cancel();
        _locationSub = null;
        _traveledPoints.clear();
        _lastTraveledRedraw = null;

        try { await LocationSharingService.to.stopForJob(jobId); } catch (_) {}

        AppSnackbar.success(
          result.message ?? 'You have reached the location.',
          title: 'Reached',
        );

        try {
          Get.find<ScheduleJobController>().resetAndStartElapsedTimer();
        } catch (_) {}

        Get.offNamed(AppRoutes.scheduleJobDetailScreen, arguments: job);
      } else {
        AppSnackbar.error(
          result.message ?? 'Failed to mark reached.',
          title: 'Error',
        );
      }
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Error');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // DISPLAY HELPERS
  // ─────────────────────────────────────────────────────────────────────────────

  String get distanceText {
    final d = distanceKm.value;
    if (currentPosition.value == null) return '--';
    final prefix = isApproximateDistance.value ? '≈ ' : '';
    return d < 1
        ? '$prefix${(d * 1000).toStringAsFixed(0)} m'
        : '$prefix${d.toStringAsFixed(1)} km';
  }

  String get etaText {
    final m = etaMinutes.value;
    if (m == 0) return '--';
    return m < 60 ? '$m min' : '${m ~/ 60}h ${m % 60}m';
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // UTILITIES
  // ─────────────────────────────────────────────────────────────────────────────

  double _haversine(LatLng a, LatLng b) {
    const R    = 6371000.0;
    final lat1 = a.latitude  * pi / 180;
    final lat2 = b.latitude  * pi / 180;
    final dLat = (b.latitude  - a.latitude)  * pi / 180;
    final dLng = (b.longitude - a.longitude) * pi / 180;
    final sinLat = sin(dLat / 2);
    final sinLng = sin(dLng / 2);
    return R * 2 * asin(sqrt(
      sinLat * sinLat + cos(lat1) * cos(lat2) * sinLng * sinLng,
    ));
  }
}
