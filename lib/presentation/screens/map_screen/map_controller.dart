import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:technicianapp/core/services/location_manager.dart';

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
    _fetchAddress(position);
    update();
  }

  Future<void> _fetchAddress(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        selectedAddress.value = [
          p.name,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
      }
    } catch (_) {
      selectedAddress.value = '';
    }
  }

  // ── Location ──────────────────────────────────────────────────────────────

  Future<void> goToCurrentLocation() async {
    await _fetchCurrentLocation(animateCamera: true);
  }

  Future<void> _fetchCurrentLocation({bool animateCamera = false}) async {
    isLoadingLocation.value = true;
    final result = await LocationManager.to.fetchLocation();
    isLoadingLocation.value = false;

    if (!result.success) return;

    final latLng = LatLng(result.lat, result.lng);
    currentPosition.value = latLng;
    selectedPosition.value = latLng;
    _fetchAddress(latLng);

    if (animateCamera || isMapReady.value) {
      _animateTo(latLng, zoom: _locationZoom);
    }
    update();
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
