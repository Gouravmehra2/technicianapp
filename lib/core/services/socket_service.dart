import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:technicianapp/core/end_point/end_point.dart';
import 'package:technicianapp/core/services/auth_service.dart';

/// Singleton socket service.
///
/// Lifecycle:
///   - [initialize]        → creates the IO.Socket instance (idempotent).
///   - [connectAndJoin]    → connects + joins the technician room in one call.
///                           Safe to call on every app start / resume.
///   - [reconnectIfNeeded] → lightweight check; calls [connectAndJoin] only
///                           when not already connected. Use on app resume.
///   - [disconnect]        → graceful disconnect (keeps _technicianId so a
///                           later [reconnectIfNeeded] can rejoin).
///   - [close]             → full teardown on logout.
///
/// Room joining rules:
///   - A room join is sent only when:
///       1. The socket just connected (onConnect callback).
///       2. [joinTechnicianIfNeeded] is called explicitly and the stored
///          technicianId has changed or the room was never joined.
///   - [_hasJoinedRoom] prevents duplicate joins within the same connection.
class SocketService {
  SocketService._();

  static final SocketService instance = SocketService._();

  IO.Socket? _socket;

  bool _isInitialized = false;
  bool _isManuallyDisconnected = false;

  /// The technician ID we want to be in a room for.
  String? _technicianId;

  /// True once we've emitted `technician:join` for the current connection.
  /// Reset to false on every disconnect so the join fires again on reconnect.
  bool _hasJoinedRoom = false;

  // ── Configuration ──────────────────────────────────────────────────────────

  static const String _socketUrl = ApiEndpoints.socketUrl;

  // ── Public socket accessor (never null after initialize) ──────────────────

  IO.Socket get socket {
    assert(_isInitialized && _socket != null,
        'SocketService.initialize() must be called before accessing socket.');
    return _socket!;
  }

  // ── Initialize ─────────────────────────────────────────────────────────────

  /// Creates the IO.Socket instance once. Idempotent.
  void initialize() {
    if (_isInitialized) return;

    _isInitialized = true;
    _isManuallyDisconnected = false;

    _socket = IO.io(
      _socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setTimeout(10000)
          .build(),
    );

    _registerCoreListeners();
  }

  // ── Core socket event listeners (registered once at initialize) ────────────

  void _registerCoreListeners() {
    _socket!.onConnect((_) {
      print('[Socket] Connected  id=${_socket!.id}');
      _hasJoinedRoom = false; // reset so we (re-)join after every connect
      _tryJoinRoom();
    });

    _socket!.onDisconnect((reason) {
      print('[Socket] Disconnected  reason=$reason');
      _hasJoinedRoom = false;
    });

    _socket!.onConnectError((error) {
      print('[Socket] Connect error: $error');
    });

    _socket!.onError((error) {
      print('[Socket] Error: $error');
    });

    _socket!.onReconnect((attempt) {
      print('[Socket] Reconnected after $attempt attempt(s)');
      // _tryJoinRoom is called via onConnect which fires after every reconnect
    });

    _socket!.onReconnectAttempt((attempt) {
      print('[Socket] Reconnect attempt $attempt');
    });

    _socket!.onReconnectError((error) {
      print('[Socket] Reconnect error: $error');
    });

    _socket!.onReconnectFailed((_) {
      print('[Socket] All reconnect attempts exhausted');
    });
  }

  // ── Room join (internal) ───────────────────────────────────────────────────

  /// Emits `technician:join` once per connection, using [_technicianId].
  /// Falls back to [AuthService] if [_technicianId] is null (e.g. after
  /// cold-start where only local storage was loaded by AuthService).
  void _tryJoinRoom() {
    if (_hasJoinedRoom) {
      print('[Socket] Already joined room — skipping duplicate join');
      return;
    }

    // Resolve the ID: prefer the explicit one, fall back to auth cache.
    final id = _technicianId ?? _idFromAuth();

    if (id == null || id.isEmpty) {
      print('[Socket] No technician ID available — room join deferred');
      return;
    }

    if (!(_socket?.connected ?? false)) {
      print('[Socket] Not connected — room join deferred');
      return;
    }

    _technicianId = id; // persist so reconnects reuse it
    _hasJoinedRoom = true;

    _socket!.emit('technician:join', id);
    print('[Socket] Joined room: $id');
  }

  /// Reads the logged-in technician's ID from the in-memory AuthService cache
  /// (which is populated from SharedPreferences on app start).
  String? _idFromAuth() {
    try {
      final auth = AuthService.to;
      final token = auth.token.value;
      final userId = auth.user.value?.user?.id;
      if (token != null && token.isNotEmpty && userId != null) {
        return userId;
      }
    } catch (_) {
      // AuthService not yet registered — ignore
    }
    return null;
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Connect and join the technician room.
  ///
  /// Pass [technicianId] explicitly (e.g. right after login).
  /// If omitted, the ID is resolved from [AuthService] (e.g. on app resume).
  ///
  /// Safe to call multiple times — duplicate connects/joins are suppressed.
  void connectAndJoin({String? technicianId}) {
    if (!_isInitialized) initialize();

    // Store the ID if provided so onConnect can use it
    if (technicianId != null && technicianId.isNotEmpty) {
      _technicianId = technicianId;
    }

    _isManuallyDisconnected = false;

    if (_socket!.connected) {
      // Already connected — just make sure we've joined the room
      _tryJoinRoom();
      return;
    }

    print('[Socket] Connecting…');
    _socket!.connect();
    // _tryJoinRoom() will be called by onConnect
  }

  /// Lightweight resume helper — reconnects and rejoins only when needed.
  /// Call this from `onInit` of controllers that depend on socket events.
  void reconnectIfNeeded() {
    if (!_isInitialized) {
      print('[Socket] Not initialized — initializing before reconnect');
      initialize();
    }

    if (_isManuallyDisconnected) {
      print('[Socket] Manually disconnected — skipping auto-reconnect');
      return;
    }

    if (_socket!.connected) {
      // Connected but maybe not joined (e.g. new controller instance)
      _tryJoinRoom();
      return;
    }

    print('[Socket] Not connected — reconnecting…');
    _socket!.connect();
    // _tryJoinRoom() fires via onConnect
  }

  /// Explicitly set the technician ID without triggering a reconnect.
  /// Useful when the auth session is updated after the socket is already up.
  void updateTechnicianId(String technicianId) {
    if (_technicianId == technicianId) return; // no change
    _technicianId = technicianId;
    _hasJoinedRoom = false; // force re-join with new ID
    _tryJoinRoom();
  }

  /// Leave the current room and clear the stored ID.
  void leaveTechnician() {
    if (_technicianId == null) return;

    if (_socket?.connected ?? false) {
      _socket!.emit('technician:leave', _technicianId);
      print('[Socket] Left room: $_technicianId');
    }

    _technicianId = null;
    _hasJoinedRoom = false;
  }

  // ── Event subscription ─────────────────────────────────────────────────────

  void on(String event, Function(dynamic data) callback) {
    if (!_isInitialized) {
      print('[Socket] Cannot register "$event" — not initialized');
      return;
    }
    // Remove any previous listener for this event before adding to avoid
    // stacking listeners when a controller re-registers after reconnect.
    _socket!.off(event);
    _socket!.on(event, callback);
  }

  void off(String event) {
    if (!_isInitialized) return;
    _socket!.off(event);
  }

  // ── Emit ───────────────────────────────────────────────────────────────────

  void emit(String event, dynamic data) {
    if (!(_socket?.connected ?? false)) {
      print('[Socket] Cannot emit "$event" — not connected');
      return;
    }
    _socket!.emit(event, data);
  }

  // ── Disconnect / Close ─────────────────────────────────────────────────────

  /// Graceful disconnect. Keeps [_technicianId] so [reconnectIfNeeded] can
  /// rejoin later (e.g. after app resume from background).
  void disconnect() {
    print('[Socket] Disconnecting…');
    _isManuallyDisconnected = true;
    _socket?.disconnect();
  }

  /// Full teardown. Call on logout.
  void close() {
    print('[Socket] Closing socket');
    _isManuallyDisconnected = true;
    leaveTechnician();
    _socket?.dispose();
    _socket = null;
    _isInitialized = false;
    _technicianId = null;
    _hasJoinedRoom = false;
  }

  // ── Status ─────────────────────────────────────────────────────────────────

  bool get isConnected => _socket?.connected ?? false;

  String? get socketId => _isInitialized ? _socket?.id : null;

  String? get technicianId => _technicianId;
}
