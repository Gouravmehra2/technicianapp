import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/core/services/route_distance_service.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/new_jobs_model.dart';

class RouteDistanceLabel extends StatelessWidget {
  final Jobs job;
  final TextStyle? style;
  final Color iconColor;
  final bool showIcon;

  const RouteDistanceLabel({
    super.key,
    required this.job,
    this.style,
    this.iconColor = AppColor.brownAccentPrimary,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final service = Get.find<RouteDistanceService>();
    return Obx(() {
      final label = service.labelFor(job);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(Icons.route_outlined, size: 16, color: iconColor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(label, overflow: TextOverflow.ellipsis, style: style),
          ),
        ],
      );
    });
  }
}
