import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:technicianapp/constant/common_widgets/app_snackbar.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/core/services/auth_service.dart';
import 'package:technicianapp/core/services/location_sharing_service.dart';
import 'package:technicianapp/core/services/socket_service.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_controller.dart';

// ── Replace with your actual Directions API key ──────────────────────────────
const _kDirectionsApiKey = 'AIzaSyBvRTUGcm2AFmUDu-Z_iDqA_DKR9vHEFqQ';

// How far off-route (metres) before we re-fetch from Directions API
const _kOffRouteThresholdMetres = 50.0;

// Minimum metres moved before we consider re-fetching the full route
const _kRefetchMinDistanceMetres = 100.0;

class NavigationController extends GetxController {
  // ── Job ──────────────────────────────────────────────────────────────────────
  late final ScheduledJobModel job;

  // ── State ────────────────────────────────────────────────────────────────────
  final currentPosition = Rxn<LatLng>();
  final distanceKm = 0.0.obs;
  final etaMinutes = 0.obs;
  final hasReached = false.obs;
  final isMapReady = false.obs;
  final isNavigating = false.obs;
  final isLoadingRoute = false.obs;

  // ── Turn-by-turn instruction shown in the banner ─────────────────────────────
  final currentInstruction = ''.obs;
  final nextInstruction = ''.obs;

  // ── Current bearing for map rotation ─────────────────────────────────────────
  final currentBearing = 0.0.obs;

  // ── Map ──────────────────────────────────────────────────────────────────────
  GoogleMapController? _mapController;
  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;

  // ── Location stream ──────────────────────────────────────────────────────────
  StreamSubscription<Position>? _locationSub;

  // ── Full decoded route points (used for trimming + off-route detection) ───────
  List<LatLng> _routePoints = [];

  // ── Traveled path — breadcrumb trail of positions visited ────────────────────
  final List<LatLng> _traveledPoints = [];

  // ── Step-level instructions from Directions API ───────────────────────────────
  final List<_RouteStep> _steps = [];

  // ── Route re-fetch throttle ───────────────────────────────────────────────────
  LatLng? _lastRouteFetchOrigin;
  bool _isFetchingRoute = false;

  // ── Socket throttle + dedup ───────────────────────────────────────────────────
  DateTime _lastSocketEmit = DateTime.fromMillisecondsSinceEpoch(0);
  static const _socketInterval = Duration(seconds: 5);
  double? _lastEmittedLat;
  double? _lastEmittedLng;

  // ── Destination ──────────────────────────────────────────────────────────────
  LatLng? get _dest =>
      job.lat != null && job.lng != null ? LatLng(job.lat!, job.lng!) : null;

  @override
  void onInit() {
    super.onInit();
    job = Get.arguments as ScheduledJobModel;
    _addDestinationMarker();
    // If the technician was already on the way (API status = 'on_the_way'),
    // skip the preview state and go straight into live navigation.
    final resumeNavigation = job.status == JobStatus.onTheWay;
    _initPreview(autoStart: resumeNavigation);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // INIT — one-shot position for preview + initial route draw
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> _initPreview({bool autoStart = false}) async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final latLng = LatLng(pos.latitude, pos.longitude);
      currentPosition.value = latLng;
      _updateMyMarker(latLng);
      await _fetchAndDrawRoute(latLng);

      // Auto-resume live navigation without calling the start-navigation API
      // again (the server already knows the job is on_the_way).
      if (autoStart) {
        isNavigating.value = true;
        final jobId = job.rawJobId;
        try {
          if (jobId != null && jobId.isNotEmpty) {
            await LocationSharingService.to.startForJobs([jobId]);
          }
          LocationSharingService.to.pause();
        } catch (_) {}
        _startLocationStream();
        _animateCameraToNavigation(latLng, 0);
      }
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // START NAVIGATION — begin live stream
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> startNavigation() async {
    final jobId = job.rawJobId;

    // ── PATCH /api/technician/jobs/:jobId/start-navigation ────────────────────
    // Fire before we flip the UI state; non-blocking on failure so the
    // technician can still navigate even if the server is temporarily unreachable.
    if (jobId != null && jobId.isNotEmpty) {
      await Get.find<ApiRepo>().startNavigationApi(jobId);
    }

    isNavigating.value = true;

    // Scope location sharing to this single job, then immediately pause the
    // background service so our own live stream below is the sole emitter.
    try {
      if (jobId != null && jobId.isNotEmpty) {
        await LocationSharingService.to.startForJobs([jobId]);
      }
      LocationSharingService.to.pause();
    } catch (_) {}

    _startLocationStream();
    if (currentPosition.value != null) {
      _fitBothPoints(currentPosition.value!, _dest ?? currentPosition.value!);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // LOCATION STREAM
  // ─────────────────────────────────────────────────────────────────────────────

  void _startLocationStream() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // only fire when moved ≥ 10 m
    );
    _locationSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen(_onPosition, onError: (_) {});
  }

  void _onPosition(Position pos) {
    if (hasReached.value) return;

    final latLng = LatLng(pos.latitude, pos.longitude);
    currentPosition.value = latLng;
    currentBearing.value = pos.heading;

    // Append to traveled trail — shown as a grey breadcrumb behind the technician.
    _traveledPoints.add(latLng);
    _updateTraveledTrail();

    _updateMyMarker(latLng);
    _maybeSendSocket(pos);
    _updateRouteAndInstructions(latLng, pos.heading);
    _animateCameraToNavigation(latLng, pos.heading);
  }

  /// Redraws the gray "path already traveled" polyline.
  void _updateTraveledTrail() {
    if (_traveledPoints.length < 2) return;
    // Re-assign so the Obx in the UI picks up the change.
    final current = polylines.toList();
    // Remove old trail layers before re-adding.
    current.removeWhere(
      (p) => p.polylineId.value == 'traveled' || p.polylineId.value == 'traveled_border',
    );
    polylines.assignAll([
      // ── Traveled border (slightly darker grey, wider) ────────────────────
      Polyline(
        polylineId: const PolylineId('traveled_border'),
        points: List<LatLng>.from(_traveledPoints),
        color: const Color(0xFF757575),
        width: 8,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
      // ── Traveled fill (light grey on top) ───────────────────────────────
      Polyline(
        polylineId: const PolylineId('traveled'),
        points: List<LatLng>.from(_traveledPoints),
        color: const Color(0xFFBDBDBD),
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
      ...current,
    ]);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // REAL-TIME ROUTE UPDATE
  // Two strategies:
  //   1. Still on route  → trim the polyline to start from nearest point,
  //      update distance/ETA from remaining points + current step instruction.
  //   2. Off route (>50 m from any polyline point) → re-fetch full route.
  // ─────────────────────────────────────────────────────────────────────────────

  void _updateRouteAndInstructions(LatLng from, double heading) {
    if (_routePoints.isEmpty) {
      // No route yet — fetch one.
      _fetchAndDrawRoute(from);
      return;
    }

    // Find the nearest point index on the current route.
    int nearestIdx = 0;
    double nearestDist = double.infinity;
    for (int i = 0; i < _routePoints.length; i++) {
      final d = _distanceMetres(from, _routePoints[i]);
      if (d < nearestDist) {
        nearestDist = d;
        nearestIdx = i;
      }
    }

    // ── Off-route check ───────────────────────────────────────────────────────
    if (nearestDist > _kOffRouteThresholdMetres && !_isFetchingRoute) {
      // Technician has left the road — re-fetch.
      _fetchAndDrawRoute(from);
      return;
    }

    // ── Trim polyline to remaining points ─────────────────────────────────────
    final remaining = _routePoints.sublist(nearestIdx);
    if (remaining.length >= 2) {
      polylines.assignAll([
        // ── Traveled trail layers (drawn first so route renders on top) ──────
        if (_traveledPoints.length >= 2) ...[
          Polyline(
            polylineId: const PolylineId('traveled_border'),
            points: List<LatLng>.from(_traveledPoints),
            color: const Color(0xFF757575),
            width: 8,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          ),
          Polyline(
            polylineId: const PolylineId('traveled'),
            points: List<LatLng>.from(_traveledPoints),
            color: const Color(0xFFBDBDBD),
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          ),
        ],
        // ── Remaining route border / shadow layer (dark blue, thicker) ──────
        Polyline(
          polylineId: const PolylineId('route_border'),
          points: remaining,
          color: const Color(0xFF1A3A8F),
          width: 10,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
        // ── Remaining route fill layer (bright blue-purple, thinner on top) ─
        Polyline(
          polylineId: const PolylineId('route'),
          points: remaining,
          color: const Color(0xFF4A6CF7),
          width: 7,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      ]);
    }

    // ── Update distance remaining ─────────────────────────────────────────────
    double totalMetres = 0;
    for (int i = 0; i < remaining.length - 1; i++) {
      totalMetres += _distanceMetres(remaining[i], remaining[i + 1]);
    }
    distanceKm.value = totalMetres / 1000;

    // ── Update current turn instruction ───────────────────────────────────────
    _updateCurrentStep(from);

    // ── Proactively re-fetch when moved > 100 m from last fetch origin ─────────
    if (_lastRouteFetchOrigin != null &&
        _distanceMetres(from, _lastRouteFetchOrigin!) >
            _kRefetchMinDistanceMetres &&
        !_isFetchingRoute) {
      _fetchAndDrawRoute(from);
    }
  }

  void _updateCurrentStep(LatLng from) {
    if (_steps.isEmpty) return;

    // Find the step whose end point is nearest ahead of us.
    _RouteStep? active;
    double closestDist = double.infinity;
    for (final step in _steps) {
      final d = _distanceMetres(from, step.endLocation);
      if (d < closestDist) {
        closestDist = d;
        active = step;
      }
    }

    if (active != null) {
      currentInstruction.value = _stripHtml(active.htmlInstruction);
      // ETA from this step's remaining duration (rough)
      etaMinutes.value = active.durationSeconds ~/ 60;

      // Next step
      final idx = _steps.indexOf(active);
      if (idx + 1 < _steps.length) {
        nextInstruction.value =
            'Then: ${_stripHtml(_steps[idx + 1].htmlInstruction)}';
      } else {
        nextInstruction.value = 'Arrive at destination';
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // GOOGLE DIRECTIONS API — fetches road-snapped route + step instructions
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> _fetchAndDrawRoute(LatLng origin) async {
    final dest = _dest;
    if (dest == null || _isFetchingRoute) return;

    _isFetchingRoute = true;
    isLoadingRoute.value = true;
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${dest.latitude},${dest.longitude}'
        '&mode=driving'
        '&key=$_kDirectionsApiKey',
      );

      final response =
          await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return;

      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') return;

      final routes = data['routes'] as List<dynamic>;
      if (routes.isEmpty) return;

      final leg = routes[0]['legs'][0] as Map<String, dynamic>;

      // Distance + ETA from API (accurate road values).
      distanceKm.value =
          (leg['distance']['value'] as num).toDouble() / 1000;
      etaMinutes.value =
          ((leg['duration']['value'] as num).toInt() / 60).ceil();

      // Decode steps for turn-by-turn instructions.
      final steps = leg['steps'] as List<dynamic>;
      _steps.clear();
      final allPoints = <LatLng>[];

      for (final step in steps) {
        final encoded = step['polyline']['points'] as String;
        final pts = _decodePolyline(encoded);
        allPoints.addAll(pts);

        _steps.add(_RouteStep(
          htmlInstruction: step['html_instructions'] as String? ?? '',
          durationSeconds:
              (step['duration']['value'] as num?)?.toInt() ?? 0,
          endLocation: LatLng(
            (step['end_location']['lat'] as num).toDouble(),
            (step['end_location']['lng'] as num).toDouble(),
          ),
        ));
      }

      _routePoints = allPoints;
      _lastRouteFetchOrigin = origin;

      // Update instruction banner immediately after fetch.
      _updateCurrentStep(origin);

      polylines.assignAll([
        // ── Traveled trail layers (drawn first so route renders on top) ──────
        if (_traveledPoints.length >= 2) ...[
          Polyline(
            polylineId: const PolylineId('traveled_border'),
            points: List<LatLng>.from(_traveledPoints),
            color: const Color(0xFF757575),
            width: 8,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          ),
          Polyline(
            polylineId: const PolylineId('traveled'),
            points: List<LatLng>.from(_traveledPoints),
            color: const Color(0xFFBDBDBD),
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          ),
        ],
        // ── Route border / shadow layer ──────────────────────────────────────
        Polyline(
          polylineId: const PolylineId('route_border'),
          points: allPoints,
          color: const Color(0xFF1A3A8F),
          width: 10,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
        // ── Route fill layer ─────────────────────────────────────────────────
        Polyline(
          polylineId: const PolylineId('route'),
          points: allPoints,
          color: const Color(0xFF4A6CF7),
          width: 7,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      ]);
    } catch (_) {
      _drawFallbackLine(origin);
    } finally {
      isLoadingRoute.value = false;
      _isFetchingRoute = false;
    }
  }

  void _drawFallbackLine(LatLng from) {
    final dest = _dest;
    if (dest == null) return;
    _routePoints = [from, dest];
    polylines.assignAll([
      // Fallback uses a single dashed line — no border layer needed
      Polyline(
        polylineId: const PolylineId('route_border'),
        points: [from, dest],
        color: const Color(0xFF1A3A8F),
        width: 10,
        patterns: [PatternItem.dash(20), PatternItem.gap(8)],
      ),
      Polyline(
        polylineId: const PolylineId('route'),
        points: [from, dest],
        color: const Color(0xFF4A6CF7),
        width: 7,
        patterns: [PatternItem.dash(20), PatternItem.gap(8)],
      ),
    ]);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // POLYLINE DECODER — Google encoded polyline algorithm
  // ─────────────────────────────────────────────────────────────────────────────

  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0, lng = 0;
    while (index < encoded.length) {
      int shift = 0, result = 0, b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;
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
  // SOCKET
  // ─────────────────────────────────────────────────────────────────────────────

  void _maybeSendSocket(Position pos) {
    final now = DateTime.now();
    if (now.difference(_lastSocketEmit) < _socketInterval) return;

    if (_lastEmittedLat == pos.latitude && _lastEmittedLng == pos.longitude) {
      return; // same coordinate — skip
    }

    _lastSocketEmit = now;
    _lastEmittedLat = pos.latitude;
    _lastEmittedLng = pos.longitude;

    final jobId = job.rawJobId;
    final techId = _technicianId;
    if (jobId == null || techId == null) return;

    SocketService.instance.emit('technician:location', {
      'jobId': jobId,
      'technicianId': techId,
      'lat': pos.latitude,
      'lng': pos.longitude,
    });
  }

  String? get _technicianId {
    try {
      return AuthService.to.user.value?.user?.id;
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // CAMERA
  // ─────────────────────────────────────────────────────────────────────────────

  void onMapCreated(GoogleMapController c) {
    _mapController = c;
    isMapReady.value = true;
    final cur = currentPosition.value;
    final dest = _dest;
    if (cur != null && dest != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _fitBothPoints(cur, dest);
      });
    } else if (dest != null) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: dest, zoom: 14),
        ),
      );
    }
  }

  /// During navigation: follow technician at zoom 17, tilt 50°, bearing = heading.
  void _animateCameraToNavigation(LatLng pos, double bearing) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: pos,
          zoom: 17,
          tilt: 50,
          bearing: bearing,
        ),
      ),
    );
  }

  void _fitBothPoints(LatLng a, LatLng b) {
    final bounds = LatLngBounds(
      southwest: LatLng(
        min(a.latitude, b.latitude),
        min(a.longitude, b.longitude),
      ),
      northeast: LatLng(
        max(a.latitude, b.latitude),
        max(a.longitude, b.longitude),
      ),
    );
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
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
    final pos = currentPosition.value;

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
        hasReached.value = true;

        // ── Stop live location stream ────────────────────────────────────────
        _locationSub?.cancel();
        _locationSub = null;

        // ── Clear traveled trail ─────────────────────────────────────────────
        _traveledPoints.clear();

        // ── Stop socket location emission from background service too ────────
        try {
          LocationSharingService.to.stop();
        } catch (_) {}

        // ── No socket reached event — API response is the source of truth ────
        // (removed technician:reached socket emit per new flow)

        AppSnackbar.success(
          result.message ?? 'You have reached the location.',
          title: 'Reached',
        );

        // ── Reset & start the elapsed timer on the job detail screen ─────────
        try {
          Get.find<ScheduleJobController>().resetAndStartElapsedTimer();
        } catch (_) {}

        // ── Navigate to ScheduleJobDetailScreen (replace navigation screen) ──
        Get.offNamed(
          AppRoutes.scheduleJobDetailScreen,
          arguments: job,
        );
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
    if (d < 1) return '${(d * 1000).toStringAsFixed(0)} m';
    return '${d.toStringAsFixed(1)} km';
  }

  String get etaText {
    final m = etaMinutes.value;
    if (m == 0) return '--';
    if (m < 60) return '$m min';
    return '${m ~/ 60}h ${m % 60}m';
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // UTILITIES
  // ─────────────────────────────────────────────────────────────────────────────

  /// Haversine distance in metres between two LatLng points.
  double _distanceMetres(LatLng a, LatLng b) {
    const R = 6371000.0; // Earth radius in metres
    final lat1 = a.latitude * pi / 180;
    final lat2 = b.latitude * pi / 180;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLng = (b.longitude - a.longitude) * pi / 180;
    final sinDLat = sin(dLat / 2);
    final sinDLng = sin(dLng / 2);
    final c =
        2 * asin(sqrt(sinDLat * sinDLat + cos(lat1) * cos(lat2) * sinDLng * sinDLng));
    return R * c;
  }

  /// Strip HTML tags from Directions API instruction strings.
  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  void onClose() {
    _locationSub?.cancel();
    _traveledPoints.clear();
    _mapController?.dispose();
    // Stop background location sharing entirely — it was scoped to this one
    // job and is no longer needed once the navigation screen closes.
    try {
      LocationSharingService.to.stop();
    } catch (_) {}
    super.onClose();
  }
}

// ─── Step model ───────────────────────────────────────────────────────────────

class _RouteStep {
  final String htmlInstruction;
  final int durationSeconds;
  final LatLng endLocation;

  const _RouteStep({
    required this.htmlInstruction,
    required this.durationSeconds,
    required this.endLocation,
  });
}

