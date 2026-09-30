import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/core/services/location_service.dart';
import 'package:technicianapp/core/services/location_sharing_service.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/new_jobs_model.dart';

/// Provides road distance labels while keeping directions requests bounded.
class RouteDistanceService extends GetxService {
  final ApiRepo _api = Get.find<ApiRepo>();
  final labels = <String, String>{}.obs;
  final Map<String, Future<void>> _inFlight = {};
  final Map<String, _CachedDistance> _cache = {};
  Worker? _positionWorker;

  @override
  void onInit() {
    super.onInit();
    _positionWorker = ever(LocationSharingService.to.position, (_) {
      labels.refresh();
    });
  }

  String labelFor(Jobs job) {
    final destination = job.coordinates;
    final jobKey = job.sId ?? _destinationKey(destination);
    if (destination?.lat == null || destination?.lng == null) {
      return 'Distance unavailable';
    }

    final origin = _origin;
    if (origin == null) return 'Location unavailable';

    final requestKey = _requestKey(origin, destination!);
    final cached = _cache[requestKey];
    if (cached != null &&
        DateTime.now().difference(cached.createdAt) <
            const Duration(minutes: 10)) {
      labels[jobKey] = cached.label;
      return cached.label;
    }

    if (!_inFlight.containsKey(requestKey)) {
      labels[jobKey] = _formatDistance(
        Geolocator.distanceBetween(
          origin.latitude,
          origin.longitude,
          destination.lat!,
          destination.lng!,
        ),
        approximate: true,
      );
      _inFlight[requestKey] = _fetchRoute(
        jobKey: jobKey,
        requestKey: requestKey,
        origin: origin,
        destination: destination,
      );
    }

    return labels[jobKey] ?? 'Calculating route...';
  }

  Position? get _origin {
    final live = LocationSharingService.to.position.value;
    if (live != null && LocationSharingService.isUsable(live, DateTime.now())) {
      return live;
    }

    final location = LocationService.to;
    if (location.latitude.value == 0.0 && location.longitude.value == 0.0) {
      return null;
    }
    return Position(
      latitude: location.latitude.value,
      longitude: location.longitude.value,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  Future<void> _fetchRoute({
    required String jobKey,
    required String requestKey,
    required Position origin,
    required Coordinates destination,
  }) async {
    try {
      final result = await _api.getDirectionsApi(
        originLat: origin.latitude,
        originLng: origin.longitude,
        destLat: destination.lat!,
        destLng: destination.lng!,
      );
      final meters = result.data?.distanceMeters;
      if (result.success && meters != null && meters > 0) {
        final label = _formatDistance(meters.toDouble());
        _cache[requestKey] = _CachedDistance(label);
        labels[jobKey] = label;
      } else {
        _cache[requestKey] = _CachedDistance(
          labels[jobKey] ?? 'Distance unavailable',
        );
      }
    } catch (_) {
      // Keep the straight-line estimate when routing is unavailable.
      _cache[requestKey] = _CachedDistance(
        labels[jobKey] ?? 'Distance unavailable',
      );
    } finally {
      _inFlight.remove(requestKey);
      labels.refresh();
    }
  }

  String _requestKey(Position origin, Coordinates destination) {
    final latBucket = (origin.latitude / 0.00225).round();
    final lngBucket = (origin.longitude / 0.00225).round();
    return '$latBucket:$lngBucket:${destination.lat}:${destination.lng}';
  }

  String _destinationKey(Coordinates? destination) =>
      '${destination?.lat}:${destination?.lng}';

  String _formatDistance(double meters, {bool approximate = false}) {
    final value = meters >= 1000
        ? '${(meters / 1000).toStringAsFixed(1)} km'
        : '${meters.toStringAsFixed(0)} m';
    return approximate ? '~$value' : value;
  }

  @override
  void onClose() {
    _positionWorker?.dispose();
    super.onClose();
  }
}

class _CachedDistance {
  final String label;
  final DateTime createdAt = DateTime.now();

  _CachedDistance(this.label);
}
