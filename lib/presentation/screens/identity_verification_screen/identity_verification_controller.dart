import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DocumentItem {
  final IconData icon;
  final String name;
  final RxBool isVerified;

  DocumentItem({
    required this.icon,
    required this.name,
    required bool verified,
  }) : isVerified = verified.obs;
}

class IdentityVerificationController extends GetxController {
  final RxString lastChecked = 'Oct 24, 2023'.obs;
  final RxString verificationId = '88291'.obs;

  final documents = <DocumentItem>[
    DocumentItem(icon: Icons.credit_card_outlined, name: 'Aadhaar Card', verified: true),
    DocumentItem(icon: Icons.credit_card_outlined, name: 'PAN Card', verified: true),
    DocumentItem(icon: Icons.drive_eta_outlined, name: 'Driving License', verified: true),
    DocumentItem(icon: Icons.shield_outlined, name: 'Police Verification', verified: true),
  ];

  final RxBool selfieVerified = true.obs;
  final RxBool backgroundCheckCompleted = true.obs;
}
