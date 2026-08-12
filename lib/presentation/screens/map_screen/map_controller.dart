import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController extends GetxController {
  // ── Map controller ────────────────────────────────────────────────────────
  GoogleMapController? mapController;

  // ── State ─────────────────────────────────────────────────────────────────
  final Rx<LatLng?> currentPosition = Rx<LatLng?>(null);
  final Rx<LatLng?> selectedPosition = Rx<LatLng?>(null);
  final RxBool isLoadingLocation = false.obs;
  final RxBool isMapReady = false.obs;
  final RxString selectedAddress = ''.obs;

  static const LatLng _defaultPosition = LatLng(20.5937, 78.9629); // India center
  static const double _defaultZoom = 5.0;
  static const double _locationZoom = 15.0;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _fetchCurrentLocation();
  }

  @override
  void onClose() {
    mapController?.dispose();
    super.onClose();
  }

  // ── Map callbacks ─────────────────────────────────────────────────────────

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    isMapReady.value = true;
  }

  void onCameraIdle() {
    // Address lookup can be wired here with a geocoding package
  }

  void onTap(LatLng position) {
    selectedPosition.value = position;
    update(); // refreshes GetBuilder so markers param on GoogleMap updates
  }

  // ── Location ──────────────────────────────────────────────────────────────

  Future<void> goToCurrentLocation() async {
    await _fetchCurrentLocation(animateCamera: true);
  }

  Future<void> _fetchCurrentLocation({bool animateCamera = false}) async {
    isLoadingLocation.value = true;
    try {
      final position = await _determinePosition();
      final latLng = LatLng(position.latitude, position.longitude);
      currentPosition.value = latLng;
      selectedPosition.value = latLng;

      if (animateCamera || isMapReady.value) {
        _animateTo(latLng, zoom: _locationZoom);
      }
      update(); // refresh GetBuilder to pass updated markers to GoogleMap
    } catch (e) {
      Get.snackbar(
        'Location Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled. Please enable them.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permission was denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permission is permanently denied. Please enable it from settings.';
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  // ── Confirm ───────────────────────────────────────────────────────────────

  void confirmLocation() {
    final pos = selectedPosition.value;
    if (pos == null) {
      Get.snackbar(
        'No Location',
        'Please select a location on the map.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    // Navigate back with the selected position
    Get.back(result: pos);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  LatLng get initialCameraTarget =>
      currentPosition.value ?? _defaultPosition;

  double get initialZoom =>
      currentPosition.value != null ? _locationZoom : _defaultZoom;

  Set<Marker> get markers {
    final pos = selectedPosition.value;
    if (pos == null) return {};
    return {
      Marker(
        markerId: const MarkerId('selected'),
        position: pos,
        infoWindow: const InfoWindow(title: 'Selected Location'),
      ),
    };
  }

  void _animateTo(LatLng target, {double zoom = _locationZoom}) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }
}
