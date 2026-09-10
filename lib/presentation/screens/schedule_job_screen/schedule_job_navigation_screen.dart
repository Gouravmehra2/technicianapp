import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/navigation_controller.dart';
import 'package:technicianapp/presentation/screens/schedule_job_screen/schedule_job_controller.dart';

class ScheduleJobNavigationScreen extends GetView<NavigationController> {
  ScheduleJobNavigationScreen({super.key});

  @override
  // ignore: overridden_fields
  final NavigationController controller = Get.put(NavigationController());

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: Get.back,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F0F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chevron_left, color: Colors.black87),
          ),
        ),
        title: Obx(
          () => Text(
            controller.isNavigating.value ? 'Live Navigation' : 'Route Preview',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              fontFamily: 'Inter',
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: Get.find<ScheduleJobController>().pauseJob,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.brownAccentPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.pause, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Pause',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Live info strip ──────────────────────────────────────────────
          Obx(
            () => Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoChip(
                    icon: Icons.route_outlined,
                    value: controller.distanceText,
                    label: 'Distance',
                  ),
                  Container(width: 1, height: 36, color: Colors.grey.shade200),
                  _InfoChip(
                    icon: Icons.access_time_outlined,
                    value: controller.etaText,
                    label: 'ETA',
                    valueColor: const Color(0xFFA5732F),
                  ),
                  Container(width: 1, height: 36, color: Colors.grey.shade200),
                  // Route loading indicator or status
                  Obx(
                    () => controller.isLoadingRoute.value
                        ? const SizedBox(
                            width: 60,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFA5732F),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Route',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _InfoChip(
                            icon: controller.isNavigating.value
                                ? Icons.navigation
                                : Icons.map_outlined,
                            value: controller.isNavigating.value
                                ? 'LIVE'
                                : 'PREVIEW',
                            label: 'Mode',
                            valueColor: controller.isNavigating.value
                                ? Colors.green
                                : Colors.grey,
                          ),
                  ),
                ],
              ),
            ),
          ),

          // ── Google Map ───────────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                Obx(
                  () => GoogleMap(
                    onMapCreated: controller.onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target:
                          controller.job.lat != null &&
                              controller.job.lng != null
                          ? LatLng(controller.job.lat!, controller.job.lng!)
                          : const LatLng(28.6139, 77.2090),
                      zoom: 14,
                    ),
                    markers: controller.markers.toSet(),
                    polylines: controller.polylines.toSet(),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: true,
                    trafficEnabled: false,
                    buildingsEnabled: true,
                    tiltGesturesEnabled: true,
                    rotateGesturesEnabled: true,
                  ),
                ),

                // ── Turn-by-turn instruction banner (live navigation only) ──
                Obx(
                  () => controller.isNavigating.value &&
                          controller.currentInstruction.value.isNotEmpty
                      ? Positioned(
                          top: 10,
                          left: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A73E8),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.turn_right,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        controller.currentInstruction.value,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (controller.nextInstruction.value.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    controller.nextInstruction.value,
                                    style: const TextStyle(
                                      color: Color(0xCCFFFFFF),
                                      fontSize: 11,
                                      fontFamily: 'Inter',
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // Re-center FAB
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: GestureDetector(
                    onTap: controller.recenter,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.my_location,
                        color: Color(0xFFA5732F),
                        size: 22,
                      ),
                    ),
                  ),
                ),

                // Map loading overlay
                Obx(
                  () => !controller.isMapReady.value
                      ? Container(
                          color: Colors.white,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFA5732F),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // ── Bottom panel ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Obx(() {
              // ── REACHED state ──────────────────────────────────────────
              if (controller.hasReached.value) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: const Text(
                    '✅  Reached — Navigation Stopped',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      fontFamily: 'Inter',
                    ),
                  ),
                );
              }

              // ── PREVIEW state — show Start Navigation ──────────────────
              if (!controller.isNavigating.value) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Destination label
                    _DestinationRow(job: controller.job),
                    const SizedBox(height: 14),
                    // Start Navigation button
                    GestureDetector(
                      onTap: controller.startNavigation,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A73E8),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.navigation,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Start Navigation',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: Get.find<ScheduleJobController>().cancelJob,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEEEE),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          '✕  Cancel',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              // ── NAVIGATING state ───────────────────────────────────────
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DestinationRow(job: controller.job),
                  const SizedBox(height: 14),
                  // Reached button
                  GestureDetector(
                    onTap: controller.markReached,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA5732F),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        '📍  Reached',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: Get.find<ScheduleJobController>().cancelJob,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEEEE),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        '✕  Cancel Route',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}



// ─── Destination row ──────────────────────────────────────────────────────────

class _DestinationRow extends StatelessWidget {
  final ScheduledJobModel job;

  const _DestinationRow({required this.job});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFFAF0E6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.location_on_outlined,
            color: Color(0xFFA5732F),
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DESTINATION',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  letterSpacing: 1,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                job.distance.isNotEmpty ? job.distance : 'Client Location',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Info chip ────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? valueColor;

  const _InfoChip({
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: valueColor ?? Colors.grey),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            fontFamily: 'Inter',
            color: valueColor ?? Colors.black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
