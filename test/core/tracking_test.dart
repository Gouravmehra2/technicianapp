import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:technicianapp/core/services/location_sharing_service.dart';
import 'package:technicianapp/core/utils/route_progress.dart';

void main() {
  final now = DateTime.utc(2026, 9, 14, 12);
  Position fix({
    double lat = 0,
    double lng = 0,
    double accuracy = 10,
    DateTime? at,
  }) => Position(
    latitude: lat,
    longitude: lng,
    timestamp: at ?? now,
    accuracy: accuracy,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  test('valid equator/prime meridian coordinates are accepted', () {
    expect(LocationSharingService.isUsable(fix(), now), isTrue);
  });
  test('rejects stale, future, inaccurate and invalid fixes', () {
    for (final p in [
      fix(at: now.subtract(const Duration(seconds: 61))),
      fix(at: now.add(const Duration(seconds: 6))),
      fix(accuracy: 101),
      fix(lat: double.nan),
      fix(lng: 181),
      fix(lat: 91),
    ]) {
      expect(LocationSharingService.isUsable(p, now), isFalse);
    }
  });
  test('first fix sends immediately', () {
    expect(LocationSharingService.shouldSend(fix(), null, now, null), isTrue);
  });
  test('movement is throttled for five seconds', () {
    expect(
      LocationSharingService.shouldSend(
        fix(lat: .001),
        fix(),
        now,
        now.subtract(const Duration(seconds: 4)),
      ),
      isFalse,
    );
    expect(
      LocationSharingService.shouldSend(
        fix(lat: .001),
        fix(),
        now,
        now.subtract(const Duration(seconds: 5)),
      ),
      isTrue,
    );
  });
  test('small GPS jitter waits for heartbeat', () {
    expect(
      LocationSharingService.shouldSend(
        fix(lat: .00001),
        fix(),
        now,
        now.subtract(const Duration(seconds: 10)),
      ),
      isFalse,
    );
  });
  test(
    'stationary heartbeat sends at 30 seconds but never freshens stale GPS',
    () {
      expect(
        LocationSharingService.shouldSend(
          fix(),
          fix(),
          now,
          now.subtract(const Duration(seconds: 30)),
        ),
        isTrue,
      );
      expect(
        LocationSharingService.shouldSend(
          fix(at: now.subtract(const Duration(minutes: 2))),
          fix(),
          now,
          now.subtract(const Duration(seconds: 30)),
        ),
        isFalse,
      );
    },
  );
  test('middle of a sparse road segment is on route', () {
    final p = RouteProgress.calculate(const LatLng(0, .005), [
      const LatLng(0, 0),
      const LatLng(0, .01),
    ])!;
    expect(p.distanceFromRoute, lessThan(1));
    expect(p.remainingMetres, closeTo(556, 3));
  });
  test('off-road distance contributes to remaining distance', () {
    final p = RouteProgress.calculate(const LatLng(.001, .005), [
      const LatLng(0, 0),
      const LatLng(0, .01),
    ])!;
    expect(p.distanceFromRoute, greaterThan(100));
    expect(p.remainingMetres, closeTo(667, 4));
  });
  test('destination has zero remaining distance', () {
    final p = RouteProgress.calculate(const LatLng(0, .01), [
      const LatLng(0, 0),
      const LatLng(0, .01),
    ])!;
    expect(p.remainingMetres, closeTo(0, .01));
  });
  test('empty and repeated points do not divide by zero', () {
    expect(RouteProgress.calculate(const LatLng(0, 0), []), isNull);
    final p = RouteProgress.calculate(const LatLng(0, 0), [
      const LatLng(0, 0),
      const LatLng(0, 0),
    ])!;
    expect(p.remainingMetres, 0);
  });
}
