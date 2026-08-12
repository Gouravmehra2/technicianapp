
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:technicianapp/core/end_point/end_point.dart';

class SocketService {
  SocketService._();

  static final SocketService instance = SocketService._();

  late IO.Socket socket;

  bool _isInitialized = false;
  bool _isManuallyDisconnected = false;

  String? _technicianId;

  // =========================
  // Configuration
  // =========================

  static const String socketUrl = ApiEndpoints.socketUrl;

  // =========================
  // Initialize Socket
  // =========================

  void initialize() {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;
    _isManuallyDisconnected = false;

    socket = IO.io(
      socketUrl,
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

    _registerSocketListeners();
  }

  // =========================
  // Socket Listeners
  // =========================

  void _registerSocketListeners() {
    socket.onConnect((_) {
      print('[Socket] Connected');
      print('[Socket] Socket ID: ${socket.id}');

      // Rejoin technician room after reconnect
      if (_technicianId != null) {
        joinTechnician(_technicianId!);
      }
    });

    socket.onDisconnect((reason) {
      print('[Socket] Disconnected');
      print('[Socket] Reason: $reason');
    });

    socket.onConnectError((error) {
      print('[Socket] Connection Error: $error');
    });

    socket.onError((error) {
      print('[Socket] Error: $error');
    });

    socket.onReconnect((attempt) {
      print('[Socket] Reconnected');
      print('[Socket] Attempt: $attempt');

      if (_technicianId != null) {
        joinTechnician(_technicianId!);
      }
    });

    socket.onReconnectAttempt((attempt) {
      print('[Socket] Reconnect attempt: $attempt');
    });

    socket.onReconnectError((error) {
      print('[Socket] Reconnect error: $error');
    });

    socket.onReconnectFailed((_) {
      print('[Socket] Reconnection failed');
    });
  }

  // =========================
  // Connect
  // =========================

  void connect() {
    if (!_isInitialized) {
      initialize();
    }

    if (socket.connected) {
      print('[Socket] Already connected');
      return;
    }

    _isManuallyDisconnected = false;

    print('[Socket] Connecting...');

    socket.connect();
  }

  // =========================
  // Join Technician
  // =========================

  void joinTechnician(String technicianId) {
    _technicianId = technicianId;

    if (!socket.connected) {
      print(
        '[Socket] Cannot join technician room. Socket not connected.',
      );
      return;
    }

    socket.emit(
      'technician:join',
      technicianId,
    );

    print(
      '[Socket] Joined technician room: $technicianId',
    );
  }

  // =========================
  // Leave Technician
  // =========================

  void leaveTechnician() {
    if (_technicianId == null) {
      return;
    }

    if (socket.connected) {
      socket.emit(
        'technician:leave',
        _technicianId,
      );

      print(
        '[Socket] Left technician room: $_technicianId',
      );
    }

    _technicianId = null;
  }

  // =========================
  // Listen to Event
  // =========================

  void on(
      String event,
      Function(dynamic data) callback,
      ) {
    if (!_isInitialized) {
      print('[Socket] Cannot register listener for "$event". Socket not initialized.');
      return;
    }
    socket.on(event, callback);
  }

  // =========================
  // Remove Event Listener
  // =========================

  void off(
      String event,
      ) {
    if (!_isInitialized) {
      return;
    }
    socket.off(event);
  }

  // =========================
  // Emit Event
  // =========================

  void emit(
      String event,
      dynamic data,
      ) {
    if (!socket.connected) {
      print(
        '[Socket] Cannot emit "$event". Socket not connected.',
      );
      return;
    }

    socket.emit(
      event,
      data,
    );
  }

  // =========================
  // Retry Connection
  // =========================

  void retry() {
    print('[Socket] Manual retry');

    _isManuallyDisconnected = false;

    if (socket.connected) {
      print('[Socket] Already connected');
      return;
    }

    socket.connect();
  }

  // =========================
  // Reconnect if needed
  // (safe to call on app resume)
  // =========================

  void reconnectIfNeeded() {
    if (!_isInitialized) {
      print('[Socket] Not initialized — initializing before reconnect');
      initialize();
    }
    if (!socket.connected && !_isManuallyDisconnected) {
      print('[Socket] Reconnecting...');
      socket.connect();
    }
  }

  // =========================
  // Disconnect
  // =========================

  void disconnect() {
    print('[Socket] Disconnect');

    _isManuallyDisconnected = true;

    socket.disconnect();
  }

  // =========================
  // Close Socket
  // =========================

  void close() {
    print('[Socket] Closing socket');

    _isManuallyDisconnected = true;

    if (_technicianId != null) {
      leaveTechnician();
    }

    socket.dispose();

    _isInitialized = false;
    _technicianId = null;
  }

  // =========================
  // Connection Status
  // =========================

  bool get isConnected {
    if (!_isInitialized) {
      return false;
    }

    return socket.connected;
  }

  // =========================
  // Socket ID
  // =========================

  String? get socketId {
    if (!_isInitialized) {
      return null;
    }

    return socket.id;
  }

  // =========================
  // Technician ID
  // =========================

  String? get technicianId {
    return _technicianId;
  }
}