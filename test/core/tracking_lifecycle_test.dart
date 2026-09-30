import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technicianapp/core/models/user_model.dart';
import 'package:technicianapp/core/services/auth_service.dart';
import 'package:technicianapp/core/services/location_sharing_service.dart';
import 'package:technicianapp/core/services/socket_service.dart';

class FakeGps extends GeolocatorPlatform {
  final updates = StreamController<Position>.broadcast();
  int subscriptions = 0;
  Completer<Position>? pendingFix;
  Position get fix => Position(
    latitude: 30,
    longitude: 75,
    timestamp: DateTime.now(),
    accuracy: 10,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
  @override
  Future<bool> isLocationServiceEnabled() async => true;
  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;
  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async => pendingFix == null ? fix : pendingFix!.future;
  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    subscriptions++;
    return updates.stream;
  }
}

class FakeSocket implements SocketService {
  final sent = <Map<String, dynamic>>[];
  @override
  bool isConnected = true;
  @override
  void connectAndJoin({String? technicianId}) {}
  @override
  void emitWithAck(String event, dynamic data, void Function(dynamic) ack) {
    sent.add(Map<String, dynamic>.from(data as Map));
    ack({'success': true});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeGps gps;
  late FakeSocket socket;
  late LocationSharingService service;
  late GeolocatorPlatform original;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    original = GeolocatorPlatform.instance;
    gps = FakeGps();
    GeolocatorPlatform.instance = gps;
    socket = FakeSocket();
    service = LocationSharingService(socketService: socket);
    final auth = Get.put(AuthService());
    auth.token.value = 'test-token';
    auth.user.value = UserModel.fromJson({
      'data': {
        'user': {'_id': 'tech-1'},
      },
    });
  });
  tearDown(() async {
    await service.stop();
    await gps.updates.close();
    GeolocatorPlatform.instance = original;
    Get.reset();
  });

  test(
    'starting the same journey twice uses one stream and sends an acknowledged first fix',
    () async {
      await service.startForJobs(['job-1']);
      await service.startForJobs(['job-1']);
      expect(gps.subscriptions, 1);
      expect(socket.sent, hasLength(1));
      expect(socket.sent.single['jobId'], 'job-1');
      expect(service.lastAcknowledgedAt.value, isNotNull);
    },
  );

  test('stop prevents a late GPS request from resurrecting tracking', () async {
    gps.pendingFix = Completer<Position>();
    final start = service.startForJobs(['job-1']);
    // Allow permission and storage futures to settle, without waiting for GPS.
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await service.stop();
    gps.pendingFix!.complete(gps.fix);
    await start;
    expect(service.isSharing, isFalse);
    expect(service.position.value, isNull);
    expect(socket.sent, isEmpty);
  });

  test(
    'stopping one job retains the other and clears persistence after the last',
    () async {
      await service.startForJobs(['job-1', 'job-2']);
      expect(socket.sent, hasLength(2));
      await service.stopForJob('job-1');
      expect(service.isSharing, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('tracking_jobs_tech-1'), ['job-2']);
      await service.stopForJob('job-2');
      expect(service.isSharing, isFalse);
      expect(prefs.getStringList('tracking_jobs_tech-1'), isNull);
    },
  );
}
