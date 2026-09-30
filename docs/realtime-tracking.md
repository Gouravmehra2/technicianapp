# Real-time technician tracking

## Implemented in this Flutter repository

- A single LocationSharingService owns the GPS stream and Socket.IO emissions.
- Navigation subscribes to that stream; leaving the screen keeps the journey active.
- Immediate first fix, at most one new sample per five seconds after 10 m movement,
  and a 30-second stationary heartbeat. The heartbeat preserves GPS capture time.
- Invalid coordinates, accuracy worse than 100 m, fixes older than 60 seconds,
  and timestamps over five seconds in the future are rejected.
- One latest packet per job, with up to three attempts, five seconds apart.
  Each socket acknowledgement callback expires after five seconds. Newer samples
  replace older pending samples. Reconnection requests a fresh GPS fix.
- Android foreground location notification and wake lock; iOS background location
  settings and visible indicator. Tracking starts while the app is foregrounded.
- Job IDs, scoped to the signed-in user, are persisted; no location history is stored.
  Restore checks the backend job status before tracking. Active jobs are checked
  every minute. Arrival, completion, inactive-job acknowledgement and logout stop sharing.
- Navigation refreshes routes every 45 seconds while visible, with a 15-second
  minimum between attempts, including failures/off-route requests. Between calls,
  distance is estimated along the route segments and ETA scales the backend duration.
  The trail is capped at 1,000 points. Failed routes show approximate straight-line
  distance (≈) and no ETA, and are eligible for retry.
- Job details use the shared live fix when available, otherwise the saved location.

## Backend work required (server source is not in this repository)

The existing event name and original fields remain compatible. Additional fields:

```json
{
  "jobId": "job_123",
  "technicianId": "legacy_technician_id",
  "lat": 30.901,
  "lng": 75.8573,
  "accuracyMeters": 12,
  "recordedAt": "2026-09-14T10:30:00Z",
  "sessionId": "journey_session_id",
  "sequence": 42
}
```

1. Authenticate the socket using `handshake.auth.token`; derive the technician ID
   from the verified token. Ignore the submitted technicianId for authorization.
   Enforce assignment and active journey status for every update and room join.
2. Validate ranges, accuracy, timestamp age and plausible movement. Store server
   receivedAt separately. Deduplicate `(technicianId, jobId, sessionId, sequence)`;
   reject older recordedAt values even across reconnects/sessions. Acknowledge an
   already accepted duplicate successfully so retries do not cause extra work.
3. Acknowledge `technician:location` via its Socket.IO callback with
   `{ "success": true }` after accepting the sample. For an ended/unassigned job,
   return `{ "success": false, "code": "JOB_INACTIVE" }`.
   Without this server change, legacy updates still emit, but delivery is unconfirmed
   and identical payloads can arrive up to three times.
4. Keep the latest accepted technician location in your database/cache. Load the
   client's destination from the job, not from the technician's submitted payload.
5. Calculate straight-line distance cheaply per update if needed. Compute road
   distance/traffic ETA through the routing provider on a controlled cadence
   (start with 30–60 seconds per active journey), with caching and single-flight
   requests. Keep routing credentials server-side. Do this independently of the
   technician navigation screen so the client continues receiving updates.
6. Broadcast only to authorized job participants. Suggested `job:tracking` payload:
   jobId, lat, lng, distanceMeters, durationSeconds, recordedAt, receivedAt,
   routeUpdatedAt, distanceType (`road` / `straight_line`), and stale.
   Return the latest snapshot when a client subscribes/reconnects.
   The client app and this new server broadcast are not implemented here.
7. Expire stale positions, label them stale in client/admin UI after your chosen
   threshold (e.g. 60 seconds), and never imply that a heartbeat is a new GPS fix.
8. Continue supporting `/api/routes/directions` with origin/destination objects
   and `data.distanceMeters`, `data.duration` (seconds string), `data.encodedPolyline`.
   Enforce authentication and rate limits on that endpoint too.

## Device/integration verification still required

Run an actual journey on Android and iOS: foreground, screen lock, switching apps,
GPS disabled/re-enabled, permission revoked, poor accuracy, network loss/recovery,
stationary technician, app relaunch, server cancellation, arrival and logout.
Verify that the notification/indicator ends when sharing stops and backend
acknowledgements and client broadcasts work. OS force-stop/termination can prevent
tracking; app relaunch resumes only after server validation. Background timers and
network scheduling are OS-controlled, so five-second delivery is not guaranteed.

The main AndroidManifest.xml is intentionally git-ignored by this project. Its local
copy was updated with INTERNET, FOREGROUND_SERVICE and FOREGROUND_SERVICE_LOCATION;
ensure those declarations also reach the manifest used by CI/release builds.
Existing iOS Info.plist already contains the location background mode and permission
usage descriptions. Always/background permission behavior must be verified on device.

## References

- https://pub.dev/packages/geolocator
- https://socket.io/docs/v4/delivery-guarantees/
- https://developers.google.com/maps/documentation/routes/compute_route_directions
