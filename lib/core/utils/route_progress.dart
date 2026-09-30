import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ─── Hard limits passed to Google Maps ────────────────────────────────────────
// Google Maps / GMSCore allocates a buffer proportional to point count.
// Keeping both under 500 prevents the PolylineSimplifier from blowing past
// the ~3 GB iOS memory watermark.
const int kMaxRoutePoints    = 400;  // remaining-route polyline
const int kMaxTraveledPoints = 150;  // breadcrumb trail

/// Projects onto route segments so sparse polylines do not cause false reroutes.
class RouteProgress {
  const RouteProgress(
    this.remainingPoints,
    this.distanceFromRoute,
    this.remainingMetres,
  );
  final List<LatLng> remainingPoints;
  final double distanceFromRoute;
  final double remainingMetres;

  static RouteProgress? calculate(LatLng position, List<LatLng> route) {
    if (route.length < 2) return null;
    double best = double.infinity;
    var segment = 0;
    var projected = route.first;
    final scale = cos(position.latitude * pi / 180).abs().clamp(0.000001, 1.0);
    for (var i = 0; i < route.length - 1; i++) {
      final a = route[i];
      final b = route[i + 1];
      final ax = (a.longitude - position.longitude) * scale;
      final ay = a.latitude - position.latitude;
      final dx = (b.longitude - a.longitude) * scale;
      final dy = b.latitude - a.latitude;
      final length = dx * dx + dy * dy;
      final t = length == 0
          ? 0.0
          : (-(ax * dx + ay * dy) / length).clamp(0.0, 1.0);
      final point = LatLng(
        a.latitude + t * (b.latitude - a.latitude),
        a.longitude + t * (b.longitude - a.longitude),
      );
      final distance = _distMetres(position, point);
      if (distance < best) {
        best = distance;
        segment = i;
        projected = point;
      }
    }
    final remaining = [projected, ...route.skip(segment + 1)];
    double metres = best;
    for (var i = 1; i < remaining.length; i++) {
      metres += _distMetres(remaining[i - 1], remaining[i]);
    }
    return RouteProgress(remaining, best, metres);
  }

  static double _distMetres(LatLng a, LatLng b) =>
      Geolocator.distanceBetween(
        a.latitude, a.longitude, b.latitude, b.longitude);
}

// ─────────────────────────────────────────────────────────────────────────────
// Douglas-Peucker polyline simplifier
//
// Reduces a list of LatLng points to at most [maxPoints] while preserving the
// visual shape of the route.  Operates in lat/lng space (good enough for the
// distances involved in navigation; no projection needed).
// ─────────────────────────────────────────────────────────────────────────────

class PolylineSimplifier {
  PolylineSimplifier._();

  /// Simplify [points] to at most [maxPoints].
  /// Returns the original list unchanged when it already fits.
  static List<LatLng> simplify(List<LatLng> points, int maxPoints) {
    if (points.length <= maxPoints) return points;

    // Iteratively increase the epsilon until we are under the budget.
    // We start with a small geographic epsilon and double it each pass.
    double epsilon = 1e-5; // ≈ 1 m in lat/lng degrees at the equator
    List<LatLng> result = points;
    while (result.length > maxPoints && epsilon < 1.0) {
      result = _douglasPeucker(points, epsilon);
      epsilon *= 2;
    }

    // Final safety clamp — keep uniform stride if still too many points.
    if (result.length > maxPoints) {
      result = _uniformSubsample(result, maxPoints);
    }
    return result;
  }

  // ── Douglas-Peucker recursion ─────────────────────────────────────────────

  static List<LatLng> _douglasPeucker(List<LatLng> pts, double epsilon) {
    if (pts.length < 3) return pts;
    final stack = <_Segment>[];
    final keep  = List<bool>.filled(pts.length, false);
    keep[0] = keep[pts.length - 1] = true;
    stack.add(_Segment(0, pts.length - 1));

    while (stack.isNotEmpty) {
      final seg = stack.removeLast();
      double maxDist = 0;
      int idx = seg.start;
      for (int i = seg.start + 1; i < seg.end; i++) {
        final d = _perpendicularDist(pts[i], pts[seg.start], pts[seg.end]);
        if (d > maxDist) { maxDist = d; idx = i; }
      }
      if (maxDist > epsilon) {
        keep[idx] = true;
        stack.add(_Segment(seg.start, idx));
        stack.add(_Segment(idx, seg.end));
      }
    }

    return [
      for (int i = 0; i < pts.length; i++)
        if (keep[i]) pts[i],
    ];
  }

  /// Perpendicular distance from [p] to the line segment [a]→[b], in degrees.
  static double _perpendicularDist(LatLng p, LatLng a, LatLng b) {
    final dx = b.longitude - a.longitude;
    final dy = b.latitude  - a.latitude;
    if (dx == 0 && dy == 0) {
      return sqrt(pow(p.longitude - a.longitude, 2) +
                  pow(p.latitude  - a.latitude,  2));
    }
    final t = ((p.longitude - a.longitude) * dx +
               (p.latitude  - a.latitude)  * dy) /
              (dx * dx + dy * dy);
    final tc = t.clamp(0.0, 1.0);
    return sqrt(pow(p.longitude - (a.longitude + tc * dx), 2) +
                pow(p.latitude  - (a.latitude  + tc * dy), 2));
  }

  /// Uniform stride subsample — last-resort safety net.
  static List<LatLng> _uniformSubsample(List<LatLng> pts, int max) {
    final step = pts.length / max;
    final out = <LatLng>[];
    for (int i = 0; i < max; i++) {
      out.add(pts[(i * step).round().clamp(0, pts.length - 1)]);
    }
    if (out.last != pts.last) out[out.length - 1] = pts.last;
    return out;
  }
}

class _Segment {
  final int start, end;
  const _Segment(this.start, this.end);
}
