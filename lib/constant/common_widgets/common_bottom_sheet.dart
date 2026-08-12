import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonBottomSheet {
  static void show({
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xffF6F6F6),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      // Allows the sheet to grow beyond half the screen height,
      // which is required for content-heavy sheets on small devices.
      isScrollControlled: true,
    );
  }

  static void close() {
    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }
  }
}

