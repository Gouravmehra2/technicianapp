import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:technicianapp/core/end_point/end_point.dart';
import 'package:technicianapp/core/services/auth_service.dart';

/// Singleton socket service.
///
/// Lifecycle:
///   - [initialize]        → creates the IO.Socket instance (idempotent).
///   - [connectAndJoin]    → connects + joins the technician room in one call.
///                           Safe to call on every app start / resume.
///   - [reconnectIfNeeded] → lightweight check; reconnects when not connected.
///                           Use on app resume / controller onInit.
///   - [disconnect]        → graceful disconnect (keeps _technicianId so a
///                           later [reconnectIfNeeded] can rejoin).
///   - [close]             → full teardown on logout.
///
/// Room joining:
///   The client automatically joins:
///     • `technician:<id>` room  — for verification & general technician events
///     • `request:<id>` rooms    — call [joinRequestRoom] when opening a
///                                  counter-offer / job-request screen.
///       Call [leaveRequestRoom] on screen close (controller.onClose).
class SocketService {
  SocketService._();

  static final SocketService instance = SocketService._();

  IO.Socket? _socket;
  final Set<void Function()> _connectionListeners = {};
  void addConnectionListener(void Function() listener) =>
      _connectionListeners.add(listener);
  void removeConnectionListener(void Function() listener) =>
      _connectionListeners.remove(listener);

  void emitWithAck(String event, dynamic data, void Function(dynamic) ack) {
    if (!isConnected) return;
    final socket = _socket!;
    final ackId = '${socket.ids}';
    late final Timer timeout;
    timeout = Timer(const Duration(seconds: 5), () {
      socket.acks.remove(ackId);
    });
    socket.emitWithAck(
      event,
      data,
      ack: (dynamic result) {
        timeout.cancel();
        ack(result);
      },
    );
  }

  bool _isInitialized = false;
  bool _isManuallyDisconnected = false;

  /// The technician ID we want to be in a room for.
  String? _technicianId;

  /// True once we've emitted `technician:join` for the current connection.
  bool _hasJoinedRoom = false;

  /// Request rooms the client has joined in the current connection.
  final Set<String> _joinedRequestRooms = {};

  // ── Configuration ──────────────────────────────────────────────────────────

  static const String _socketUrl = ApiEndpoints.socketUrl;

  // ── Public socket accessor ─────────────────────────────────────────────────

  IO.Socket get socket {
    assert(
      _isInitialized && _socket != null,
      'SocketService.initialize() must be called before accessing socket.',
    );
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
          .setAuth({'token': AuthService.to.token.value})
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

  // ── Core listeners ─────────────────────────────────────────────────────────

  void _registerCoreListeners() {
    _socket!.onConnect((_) {
      print('[Socket] Connected  id=${_socket!.id}');
      _hasJoinedRoom = false;
      _tryJoinRoom();
      _rejoinRequestRooms();
      for (final listener in _connectionListeners.toList()) {
        listener();
      }
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

    _socket!.onReconnectFailed((_) {
      print('[Socket] All reconnect attempts exhausted');
    });
  }

  // ── Technician room join ───────────────────────────────────────────────────

  void _tryJoinRoom() {
    if (_hasJoinedRoom) return;

    final id = _technicianId ?? _idFromAuth();

    if (id == null || id.isEmpty) {
      print('[Socket] No technician ID available — room join deferred');
      return;
    }

    if (!(_socket?.connected ?? false)) {
      print('[Socket] Not connected — room join deferred');
      return;
    }

    _technicianId = id;
    _hasJoinedRoom = true;

    _socket!.emit('technician:join', id);
    print('[Socket] Joined technician room: $id');
  }

  String? _idFromAuth() {
    try {
      final auth = AuthService.to;
      final token = auth.token.value;
      final userId = auth.user.value?.user?.id;
      if (token != null && token.isNotEmpty && userId != null) return userId;
    } catch (_) {}
    return null;
  }

  // ── Request room join / leave ──────────────────────────────────────────────

  /// Join a `request:<requestId>` room so the client receives events that
  /// the backend emits to that room (charge:reviewed, invoice:generated, etc.).
  ///
  /// Safe to call multiple times — duplicate joins are suppressed per connection.
  void joinRequestRoom(String requestId) {
    if (requestId.isEmpty) return;
    if (!_isInitialized) initialize();

    if (_joinedRequestRooms.contains(requestId)) {
      print('[Socket] Already in request room: $requestId');
      return;
    }

    if (!(_socket?.connected ?? false)) {
      // Store so it can be joined after connect
      _joinedRequestRooms.add(requestId);
      print('[Socket] Not connected — request:join for $requestId queued');
      return;
    }

    _joinedRequestRooms.add(requestId);
    _socket!.emit('request:join', requestId);
    print('[Socket] Joined request room: $requestId');
  }

  /// Leave a `request:<requestId>` room (call from controller.onClose).
  void leaveRequestRoom(String requestId) {
    if (requestId.isEmpty) return;
    if (!_isInitialized) return;

    _joinedRequestRooms.remove(requestId);

    if (_socket?.connected ?? false) {
      _socket!.emit('request:leave', requestId);
      print('[Socket] Left request room: $requestId');
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  void connectAndJoin({String? technicianId}) {
    if (!_isInitialized) initialize();

    if (technicianId != null && technicianId.isNotEmpty) {
      _technicianId = technicianId;
    }

    _isManuallyDisconnected = false;

    if (_socket!.connected) {
      _tryJoinRoom();
      // Re-join any queued request rooms after re-connect
      _rejoinRequestRooms();
      return;
    }

    print('[Socket] Connecting…');
    _socket!.auth = {'token': AuthService.to.token.value};
    _socket!.connect();
  }

  void reconnectIfNeeded() {
    if (!_isInitialized) {
      print('[Socket] Not initialized — initializing');
      initialize();
    }

    if (_isManuallyDisconnected) {
      print('[Socket] Manually disconnected — skipping auto-reconnect');
      return;
    }

    if (_socket!.connected) {
      _tryJoinRoom();
      _rejoinRequestRooms();
      return;
    }

    print('[Socket] Not connected — reconnecting…');
    _socket!.auth = {'token': AuthService.to.token.value};
    _socket!.connect();
  }

  /// Re-emit `request:join` for all rooms after a reconnect.
  void _rejoinRequestRooms() {
    for (final id in _joinedRequestRooms) {
      _socket!.emit('request:join', id);
      print('[Socket] Re-joined request room: $id');
    }
  }

  void updateTechnicianId(String technicianId) {
    if (_technicianId == technicianId) return;
    _technicianId = technicianId;
    _hasJoinedRoom = false;
    _tryJoinRoom();
  }

  void leaveTechnician() {
    if (_technicianId == null) return;
    if (_socket?.connected ?? false) {
      _socket!.emit('technician:leave', _technicianId);
      print('[Socket] Left technician room: $_technicianId');
    }
    _technicianId = null;
    _hasJoinedRoom = false;
  }

  // ── Event subscription ─────────────────────────────────────────────────────

  /// Register a listener for [event].
  ///
  /// Unlike the old implementation this does NOT remove the previous listener
  /// automatically — each caller is responsible for calling [off] in onClose.
  /// This prevents one controller from silently wiping another controller's
  /// listener for the same event name.
  void on(String event, Function(dynamic data) callback) {
    if (!_isInitialized) {
      print('[Socket] Cannot register "$event" — not initialized');
      return;
    }
    // Off first so we never stack duplicate listeners for the same event
    // within the SAME controller registration cycle (e.g. reconnect).
    _socket!.off(event, callback);
    _socket!.on(event, callback);
    print('[Socket] Listening to "$event"');
  }

  void off(String event, [Function(dynamic)? callback]) {
    if (!_isInitialized) return;
    _socket!.off(event, callback);
    print('[Socket] Stopped listening to "$event"');
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

  void disconnect() {
    print('[Socket] Disconnecting…');
    _isManuallyDisconnected = true;
    _socket?.disconnect();
  }

  void close() {
    print('[Socket] Closing socket');
    _isManuallyDisconnected = true;
    leaveTechnician();
    _socket?.dispose();
    _socket = null;
    _isInitialized = false;
    _technicianId = null;
    _hasJoinedRoom = false;
    _joinedRequestRooms.clear();
  }

  // ── Status ─────────────────────────────────────────────────────────────────

  bool get isConnected => _socket?.connected ?? false;
  String? get socketId => _isInitialized ? _socket?.id : null;
  String? get technicianId => _technicianId;
}
